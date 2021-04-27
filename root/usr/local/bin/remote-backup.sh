#!/bin/sh
# Archive and backup data to a remote repository.
#
# Individual backup encryption requires age.
#
# Parameters.
#   $1: Source directory.
#   $2: Remote destination. E.g. user@host:/path
#   $3: Archive name.
#   $4: Compression utility to use. Pass empty string to disable compression.
#   $5: Age public keys to encrypt to. Pass empty string to disable encryption.
#   $6: If 'DELETE', delete contents of remote destination before copying.

if [ -z "${1}" ] || [ -z "${2}" ] || [ -z "${3}" ] \
|| [ -z "${4}" ] || [ -z "${5}" ]; then
    printf "Usage: remote-backup.sh SRC REMOTE_DEST ARCHIVE_NAME COMPRESS_UTIL PUBKEYS ['DELETE']\n" 1>&2
    exit 1
fi

# Functions.
create_archive()
{
    # Create an archive of the contents of source directory.
    #
    # Parameters.
    #   $1: Source directory.
    #   $2: Compression utility to use. Pass empty string to disable compression.
    #   $3: Age public keys to encrypt to. Pass empty string to disable encryption.

    src="${1}"
    compress="${2}"
    encrypt="${3}"
    set -- \
        --create \
        --preserve-permissions \
        --numeric-owner \
        --same-owner \
        --acls \
        --xattrs
    if [ -n "${compress}" ]; then
        set -- "$@" \
            --use-compress-program="${compress}"
    fi
    if [ -n "${encrypt}" ]; then
        if ! (cd "${src}" || exit 1; tar "$@" -f - -- * | age -R "${encrypt}"); then
            exit 1
        fi
    else
        if ! (cd "${src}" || exit 1; tar "$@" -f - -- *); then
            exit 1
        fi
    fi
}

# Create remote repository path as required.
if ! ssh "${2%%:*}" "mkdir -p ${2##*:}"; then
    printf 'remote-backup.sh: Failed to create remote repository path.\n' 1>&2
    exit 1
fi
# Delete files from remote repository.
if [ "${6}" = "DELETE" ]; then
    if ! ssh "${2%%:*}" "rm -rf ${2##*:}/*"; then
        printf 'remote-backup.sh: Failed to delete files from remote repository.\n' 1>&2
        exit 1
    fi
fi
# Create archive and securely copy to remote repository.
printf 'remote-backup.sh: Securely copying archive to remote repository %s...\n' "'${2##*@}'"
if ! create_archive "${1}" "${4}" "${5}" | ssh "${2%%:*}" "umask 0077; cat > ${2##*:}/${3}"; then
    printf 'remote-backup.sh: Failed to create or copy archive.\n' 1>&2
    exit 1
fi
printf 'remote-backup.sh: Archive copied to remote repository.\n'
