#!/bin/sh
# Backup data to a locally connected device and to a remote server.
#
# Digital signatures require 'minisign', and individual backup encryption
# requires the 'age' encryption tool.
#
# Parameters.
#   $1: Source path following rsync conventions.
#   $2: Repository pathname relative to repository roots.
#   $3: Path to file containing age public keys to encrypt remote backups to.
#   $4: Path to secret signing key to sign remote backups with.
#   $5: Local repository root.
#   $6: If given, remote backup host and repository root. E.g. host:/srv/backup
#   $7: If given, path to file containing rsync exclusions.
#   $8: If given, path to file containing rsync inclusions.

# Include shared functions.
. /usr/local/lib/backup_lib.sh

# Compression utility.
compress="/usr/bin/gzip"

# Encryption utility.
encrypt="/usr/bin/age"

# Signing utility.
sign="/usr/bin/minisign"

# Backup archive and signature suffixes.
archive_suffix=".tar.gz.age"
signature_suffix=".minisig"

# Daily and weekly backup directories relative to repository root.
daily_dir="daily"
weekly_dir="weekly"

# Links to latest backups performed relative to repository root.
latest="latest"
latest_weekly="latest_weekly"

# Identify remote host.
remote_host="${6%%:*}"

# Full paths to local and remote repositories.
local_repository="${5}/${2}"
remote_repository="${6##*:}/${2}_remote"

# Path to local and remote output directories for copies of digital signatures.
local_signature_output_directory="/srv/backup/${2}/sigs"
remote_signature_output_directory="${remote_repository}/sigs"

# Functions.
do_remote_backup()
{
    # Archive, compress, encrypt, and digitally sign a weekly backup and copy to remote repository.
    #
    # Parameters.
    #   $1: Filename of weekly backup.
    #   $2: Path to file containing age public keys to encrypt to.
    #   $3: Path to secret signing key to sign with.

    archive_name="${1}${archive_suffix}"
    signature_name="${archive_name}${signature_suffix}"

    # Set full path to local temporary archive.
    temp_archive="/tmp/${archive_name}"

    # Archive, compress, and encrypt to temporary path.
    if ! do_tar "${1}" | "${encrypt}" -R "${2}" > "${temp_archive}"; then
        print_error "Failed to create encrypted archive ${temp_archive}."
        rm -rf "${temp_archive}"
        return 1
    fi

    # Digitally sign archive.
    temp_signature="/tmp/${signature_name}"
    if ! printf '\n' | "${sign}" -SHx "${temp_signature}" -s "${3}" -m "${temp_archive}" > /dev/null 2>&1; then
        print_error "Failed to digitally sign encrypted archive ${temp_archive}."
        rm -rf "${temp_archive}"
        return 1
    fi

    # Delete former weekly backup from remote repository.
    ssh "${remote_host}" "rm -rf ${remote_repository}/${weekly_dir}/* ${remote_signature_output_directory}/*"

    # Copy archive to remote repository.
    print_message "Securely copying encrypted archive to ${remote_host}:${remote_repository}/${weekly_dir} ..."
    make_remote_repository_maybe
    if ! scp -pq "${temp_archive}" "${remote_host}:${remote_repository}/${weekly_dir}"; then
        print_error "Failed to copy encrypted archive to ${remote_host}."
        rm -rf "${temp_archive}" "${temp_signature}"
        return 1
    fi

    # We don't need the temporary archive anymore.
    rm -rf "${temp_archive}"

    # Secure permissions on remote archive.
    ssh "${remote_host}" "chmod 600 ${remote_repository}/${weekly_dir}/${archive_name}"

    print_message "Create remote backup -> ${remote_host}:${remote_repository}/${weekly_dir}/${archive_name}."

    # Copy signature to remote host.
    if ! scp -pq "${temp_signature}" "${remote_host}:${remote_signature_output_directory}"; then
        print_error "Failed to copy encrypted archive signature to ${remote_host}. Consider manually signing the archive."
    else
        print_message "Remote copy of encrypted archive signature created at ${remote_host}:${remote_signature_output_directory}/${signature_name}."
    fi

    # Copy signature locally.
    if ! cp -a "${temp_signature}" "${local_signature_output_directory}"; then
        print_error "Failed to create local copy of encrypted archive signature. Consider manually signing the archive."
    else
        print_message "Local copy of encrypted archive signature created at ${local_signature_output_directory}/${signature_name}."
    fi

    # We don't need the temporary signature anymore.
    rm -rf "${temp_signature}"
}

do_rsync()
{
    # Parameters.
    #   $1: Source path.
    #   $2: Local output destination.
    #   $3: If not empty, hard link destination directory.
    #   $4: If given, path to file containing rsync exclusions.
    #   $5: If given, path to file containing rsync inclusions.

    src="${1}"
    dest="${2}"
    link_dest="${3}"
    rsync_exclusions="${4}"
    rsync_inclusions="${5}"

    # Set standard rsync options and rules.
    set -- \
        --archive \
        --hard-links \
        --acls \
        --xattrs \
        --numeric-ids \
        --rsh=ssh \
        --quiet \
        --delete \
        --exclude="/dev/*" \
        --exclude="/media/*" \
        --exclude="/mnt/*" \
        --exclude="/proc/*" \
        --exclude="/run/*" \
        --exclude="/sys/*" \
        --exclude="/tmp/*" \
        --exclude=lost+found

    if [ "${link_dest}" ]; then
        set -- "$@" --link-dest="${link_dest}"
    fi

    if [ "${rsync_inclusions}" ]; then
        set -- "$@" --include-from="${rsync_inclusions}"
    fi

    if [ "${rsync_exclusions}" ]; then
        set -- "$@" --exclude-from="${rsync_exclusions}"
    fi

    rsync "$@" "${src}" "${dest}"
}

do_tar()
{
    # Archives and compresses a weekly backup.
    #
    # Parameters.
    #   $1: Filename of weekly backup.
    #
    # Returns: Compressed archive of weekly backup.

    filename="${1}"

    # Set tar options.
    set -- \
        --numeric-owner \
        --preserve-permissions \
        --same-owner \
        --acls \
        --xattrs \
        --use-compress-program="${compress}"

    tar -C "${local_repository}/${weekly_dir}" -c "$@" -f - "${filename}"
}

make_remote_repository_maybe()
{
    ssh "${remote_host}" "[ ! -d ${remote_repository} ] && mkdir -p ${remote_repository}" && print_message "Create remote directory -> ${remote_repository}."
    ssh "${remote_host}" "[ ! -d ${remote_repository}/${weekly_dir} ] && mkdir -p ${remote_repository}/${weekly_dir}" && print_message "Create remote directory -> ${remote_repository}/${weekly_dir}."
    ssh "${remote_host}" "[ ! -d ${remote_signature_output_directory} ] && mkdir -p ${remote_signature_output_directory}" && print_message "Create remote directory -> ${remote_signature_output_directory}."
}

make_repository_maybe()
{
    [ ! -d "${local_repository}" ] && mkdir -p "${local_repository}" && print_message "Create directory -> ${local_repository}."
    [ ! -d "${local_repository}/${daily_dir}" ] && mkdir -p "${local_repository}/${daily_dir}" && print_message "Create directory -> ${local_repository}/${daily_dir}."

    for i in 0 1 2 3 4 5; do
        [ ! -d "${local_repository}/${daily_dir}/daily${i}" ] && mkdir -p "${local_repository}/${daily_dir}/daily${i}" && print_message "Create directory -> ${local_repository}/${daily_dir}/daily${i}."
    done

    [ ! -d "${local_repository}/${weekly_dir}" ] && mkdir -p "${local_repository}/${weekly_dir}" && print_message "Create directory -> ${local_repository}/${weekly_dir}."
    [ ! -d "${local_signature_output_directory}" ] && mkdir -p "${local_signature_output_directory}" && print_message "Create directory -> ${local_signature_output_directory}."
}

# Begin.
backup_data_directory="data"

make_repository_maybe

print_message "Backing up ${1} ..."

filename="$(datetime | sed 's/-//g; s/://g')"
out="${filename}/${backup_data_directory}"

if [ -h "${local_repository}/${latest}" ]; then
    link_dest="$(realpath "${local_repository}/${latest}")"
fi

# Check less than seven days since weekly backup copy to perform daily backup.
if [ "$(find -L "${local_repository}/${latest_weekly}" -mtime -6 -print 2> /dev/null)" ]; then
    # Increment latest daily output directory index, or start at 0.
    latest_resolved="$(readlink -n "${local_repository}/${latest}")"

    if [ "${latest_resolved%%/*}" = "${weekly_dir}" ]; then
        daily="daily0"
    else
        daily_i="$(basename "${latest_resolved%/*/*}")"
        daily_i="${daily#${daily%?}}"
        daily="daily$((daily_i + 1))"
    fi

    relout="${daily_dir}/${daily}/${out}"
    out="${local_repository}/${relout}"
else
    relout="${weekly_dir}/${out}"
    out="${local_repository}/${relout}"
fi

# Create backup output directory.
if [ "${daily}" ]; then
    rm -rf "${local_repository:?}/${daily_dir}/${daily}/"*
else
    rm -rf "${local_repository:?}/${weekly_dir}/"*
fi

mkdir -p "${out}"

# Backup.
if ! do_rsync "${1}" "${out}" "${link_dest}" "${7}" "${8}"; then
    print_error "Failed to backup from ${1} to local repository."
    exit 1
fi

print_message "Create backup -> ${out%/*}."

# Link to new latest backup.
export latest local_repository relout
if ! (cd "${local_repository}" || exit; ln -snf "${relout}" "${latest}"); then
    print_error "Failed to change directory to ${local_repository}. Latest symbolic link not set."
    exit
fi

# If we did a weekly backup, link to new weekly backup and optionally perform remote backup.
if [ -z "${daily}" ]; then
    export latest_weekly
    if ! (cd "${local_repository}" || exit; ln -snf "${relout}" "${latest_weekly}"); then
        print_error "Failed to change directory to ${local_repository}. Latest weekly symbolic link not set."
        exit
    fi

    # Remote backups are optional, so check if the appropriate parameter has
    # been set.
    if [ -n "${6}" ]; then
        if ! do_remote_backup "${filename}" "${3}" "${4}"; then
            print_error "Failed to backup to ${remote_host}."
            exit 1
        fi
    fi
fi
