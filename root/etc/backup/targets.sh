#!/bin/sh
# Add targets for backup.sh here.
#
# Parameters.
#   $1: Mount point of LUKS device.
#   $2: If 'remote', do remote backup after local backup.

# Functions.
do_local_backup()
{
    # Do a local backup.
    #
    # Parameters.
    #   $1: Source path.
    #   $2: Repository path.
    #   $3: If given, path to file containing rsync exclusions.
    #   $4: If given, path to file containing rsync inclusions.

    /usr/local/bin/backup-rsync.sh "${1}" "${2}" "${3}" "${4}"
}

do_remote_backup()
{
    # Do a remote backup.
    #
    # Parameters.
    #   $1: Repository path.
    #   $2: Remote destination. E.g. user@host:/path
    #   $3: Archive name.
    #   $4: Compression utility to use. Pass empty string to disable compression.
    #   $5: Age public keys to encrypt to. Pass empty string to disable encryption.
    #   $6: If 'DELETE', delete contents of remote destination before copying.

    /usr/local/bin/remote-backup.sh "${1}/latest" "${2}" "${3}" "${4}" "${5}" "${6}"
}

# Call do_local_backup() for each data set to backup to LUKS device.
if [ "${2}" = "remote" ]; then
    # Call do_remote_backup() for each data set to backup to a remote repository.
fi
