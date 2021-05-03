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
    #   $3: User to execute as.
    #   $4: If given, path to file containing rsync exclusions.
    #   $5: If given, path to file containing rsync inclusions.

    runuser -l "${3}" -c "/usr/local/bin/backup-rsync.sh ${1} ${2} ${4} ${5}"
}

do_remote_backup()
{
    # Do a remote backup.
    #
    # Parameters.
    #   $1: Repository path.
    #   $2: Remote destination. E.g. user@host:/path
    #   $3: User to execute as.
    #   $4: Private SSH key.
    #   $5: Archive name.
    #   $6: Compression utility to use. Pass empty string to disable compression.
    #   $7: Age public keys to encrypt to. Pass empty string to disable encryption.
    #   $8: If 'DELETE', delete contents of remote destination before copying.

    runuser -l "${3}" -c "/usr/local/bin/remote-backup.sh ${1}/latest ${2} ${4} ${5} ${6} ${7} ${8}"
}

# Call do_local_backup() for each data set to backup to LUKS device.
if [ "${2}" = "remote" ]; then
    # Call do_remote_backup() for each data set to backup to a remote repository.
fi
