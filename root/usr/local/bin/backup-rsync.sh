#!/bin/sh
# Backup files to an rsync repository.
#
# Parameters.
#   $1: Source path.
#   $2: Destination path.
#   $3: If given, path to rsync hard link destination.
#   $4: If given, path to file containing rsync exclusions.
#   $5: If given, path to file containing rsync inclusions.

if [ -z "${1}" ] || [ -z "${2}" ]; then
    printf 'Usage: backup-rsync.sh SRC DEST [LINK_DEST] [EXCLUDE_FILE] [INCLUDE_FILE]\n' 1>&2
    exit 1
fi
src="${1}"
dest="${2}"
link_dest="${3}"
exclude_file="${4}"
include_file="${5}"
set -- \
    --archive \
    --hard-links \
    --acls \
    --xattrs \
    --numeric-ids \
    --rsh=ssh \
    --mkpath \
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
if [ "${include_file}" ]; then
    set -- "$@" --include-from="${include_file}"
fi
if [ "${exclude_file}" ]; then
    set -- "$@" --exclude-from="${exclude_file}"
fi
printf 'backup-rsync.sh: Backing up %s...\n' "'${src}'"
if rsync "$@" "${src}" "${dest}"; then
    printf 'backup-rsync.sh: Create backup %s.\n' "'${dest}'"
else
    printf 'backup-rsync.sh: Backup of %s failed.\n' "'${src}'" 1>&2
fi
