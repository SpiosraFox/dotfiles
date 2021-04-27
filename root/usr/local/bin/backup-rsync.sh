#!/bin/sh
# Backup files to a locally accessible rsync repository.
#
# Parameters.
#   $1: Source path.
#   $2: Repository path.
#   $3: If given, path to file containing rsync exclusions.
#   $4: If given, path to file containing rsync inclusions.

if [ -z "${1}" ] || [ -z "${2}" ]; then
    printf 'Usage: backup-rsync.sh SRC REPO [EXCLUDE_FILE] [INCLUDE_FILE]\n' 1>&2
    exit 1
fi
src="${1}"
repo="${2}"
exclude_file="${3}"
include_file="${4}"
set -- \
    --archive \
    --hard-links \
    --acls \
    --xattrs \
    --numeric-ids \
    --mkpath \
    --quiet \
    --delete \
    --link-dest="${repo}/latest" \
    --exclude="/dev/*" \
    --exclude="/media/*" \
    --exclude="/mnt/*" \
    --exclude="/proc/*" \
    --exclude="/run/*" \
    --exclude="/sys/*" \
    --exclude="/tmp/*" \
    --exclude=lost+found
if [ "${include_file}" ]; then
    set -- "$@" --include-from="${include_file}"
fi
if [ "${exclude_file}" ]; then
    set -- "$@" --exclude-from="${exclude_file}"
fi
# Create daily day of week directories as required.
if [ ! -d "${repo}/daily" ]; then
    mkdir -p "${repo}/daily" && chmod 700 "${repo}/daily"
fi
for day in 0 1 2 3 4 5 6; do
    mkdir -p "${repo}/daily/${day}"
done
day_of_week="$(date '+%w')"
printf 'backup-rsync.sh: Backing up %s...\n' "'${src}'"
if rsync "$@" "${src}" "${repo}/daily/${day_of_week}"; then
    printf 'backup-rsync.sh: Create backup %s.\n' "'${repo}/daily/${day_of_week}'"
    # Set latest backup.
    ln -snf "daily/${day_of_week}" "${repo}/latest"
else
    printf 'backup-rsync.sh: Backup of %s failed.\n' "'${src}'" 1>&2
    exit 1
fi
