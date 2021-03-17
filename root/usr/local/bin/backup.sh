#!/bin/sh
# Backup data to a locally connected and encrypted device and to
# a remote server.
#
# Digital signatures require 'minisign', and individual backup encryption
# requires the 'age' encryption tool.
#
# Parameters.
#   $1: LUKS device UUID.
#   $2: Opened LUKS device UUID.
#   $3: LUKS key.
#   $4: Mapper name to assign to opened LUKS device. This option is ignored
#       if LUKS device is already opened.
#   $5: Mount point for LUKS device. This option is ignored if LUKS device
#       is already mounted. Should probably be an absolute path.

# Include shared functions.
. /usr/local/lib/backup_lib.sh

# We need to keep track of the mount point and mapper name globally for the functions.
# Let's sanitize mount point location first, just in case?
mapper_name="${4}"
mount_point="$(realpath -ms "${5}")"

# Functions.
finish()
{
    # Unmount and close LUKS device accordingly, depending on if it was already
    # opened and/or mounted.
    #
    # Parameters.
    #   $1: Mapper name of opened LUKS device.

    if [ -z "${already_mounted}" ]; then
        if ! umount "${mount_point}"; then
            print_error "Failed to unmount LUKS device."
            exit 1
        fi

        print_message "Unmounted LUKS device."
    fi

    if [ -z "${already_opened}" ]; then
        if ! cryptsetup close "${1}"; then
            print_error "Failed to close LUKS device."
            exit 1
        fi

        print_message "Closed LUKS device."
    fi
}

prepare()
{
    # Open and mount LUKS device as required.
    #
    # Parameters.
    #   $1: LUKS device UUID.
    #   $2: Opened LUKS device UUID.
    #   $3: LUKS key.

    print_message "Initializing backups..."

    # Check if LUKS device is present.
    if [ ! "$(findfs UUID="${1}")" ]; then
        print_error "LUKS device ${1} not found."
        exit 1
    fi

    # Check if device is already opened and/or mounted.
    if [ "$(findfs UUID="${2}" 2> /dev/null)" ]; then
        already_opened=1

        # Check if mounted.
        if [ "$(findmnt -S UUID="${2}")" ]; then
            already_mounted=1

            # Adjust mount point accordingly.
            mount_point="$(findmnt -no TARGET -S UUID="${2}")"
            print_message "Using already mounted LUKS device at ${mount_point}."
        else
            print_message "Using already opened LUKS device."
        fi
    fi

    # Open LUKS device is it isn't already opened.
    if [ -z "${already_opened}" ]; then
        if ! cryptsetup -d "${3}" open UUID="${1}" "${mapper_name}"; then
            print_error "Failed to open LUKS device."
            exit 1
        fi

        print_message "Opened LUKS device ${1}."
    fi

    # Mount LUKS device if not already mounted.
    if [ -z "${already_mounted}" ]; then
        if ! mount UUID="${2}" "${mount_point}"; then
            print_error "Failed to mount LUKS device."
            exit 1
        fi

        print_message "Mounted LUKS device at ${mount_point}."
    fi
}

# Begin here.
prepare "${1}" "${2}" "${3}"

# Call /usr/local/bin/do_backup.sh for each data set to backup.
#   $1: Source path following rsync conventions.
#   $2: Repository pathname relative to repository roots.
#   $3: Path to file containing age public keys to encrypt remote backups to.
#   $4: Path to secret signing key to sign remote backups with.
#   $5: Local repository root.
#   $6: If given, remote backup host and repository root. E.g. host:/srv/backup
#   $7: If given, path to file containing rsync exclusions.
#   $8: If given, path to file containing rsync inclusions.

# Input here...

# The end.
finish "${4}"
