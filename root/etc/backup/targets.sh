#!/bin/sh
# Add targets for backup.sh here.
#
# Parameters.
#   $1: Mount point of LUKS device.
#   $2: If 'remote', do remote backup after local backup.

# Functions.
do_local_backup()
{
    # Do a local backup with backup-rsync.sh.
    #
    # Parameters.
    #   $1: Source path.
    #   $2: Mount point of LUKS device.
    #   $3: Repository root name.
    #   $4: If given, path to file containing rsync exclusions.
    #   $5: If given, path to file containing rsync inclusions.

    # Create daily day of week directories as required.
    if [ ! -d "${2}"/"${3}"/daily ]; then
        mkdir -p "${2}"/"${3}"/daily && chmod 700 "${2}"/"${3}"/daily
    fi
    for day in 0 1 2 3 4 5 6; do
        mkdir -p "${2}"/"${3}"/daily/"${day}"
    done
    # Call backup-rsync.sh
    /usr/local/bin/backup-rsync.sh \
        "${1}" \
        "${2}"/"${3}"/daily/"${day_of_week}"/ \
        "${2}"/"${3}"/latest \
        "${4}" \
        "${5}"
    # Set latest backup.
    ln -snf daily/"${day_of_week}" "${2}"/"${3}"/latest
}

do_remote_backup()
{
    # Do a remote backup with remote-backup.sh.
    #
    # Parameters.
    #   $1: Mount point of LUKS device.
    #   $2: Repository root name.
    #   $3: Remote destination. E.g. user@host:/path
    #   $4: Archive name.
    #   $5: Compression utility to use. Pass empty string to disable compression.
    #   $6: Age public keys to encrypt to. Pass empty string to disable encryption.
    #   $7: If 'DELETE', delete contents of remote repository before copying. Default
    #       is to leave existing files as they are and not delete anything.

    /usr/local/bin/remote-backup.sh \
        "${1}"/"${2}"/daily/"${day_of_week}" \
        "${3}" \
        "${4}" \
        "${5}" \
        "${6}" \
        "${7}"
}

today="$(date -u '+%Y%m%d')"
day_of_week="$(date '+%w')"
# Call do_local_backup() for each data set to backup to LUKS device.
if [ "${2}" = "remote" ]; then
    # Call do_remote_backup() for each data set to backup to remote repository.
fi
