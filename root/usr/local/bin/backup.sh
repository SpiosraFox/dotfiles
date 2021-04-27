#!/bin/sh
# Open and mount LUKS device for backing up data to and call user-defined
# script for executing backup logic.
#
# Parameters.
#   $1: LUKS device UUID.
#   $2: Opened LUKS device UUID.
#   $3: LUKS key.
#   $4: Mapper name to assign to opened LUKS device. This option is ignored
#       if LUKS device is already opened.
#   $5: Mount point for LUKS device. This option is ignored if LUKS device
#       is already mounted.
#   $6: Script containing backup logic to execute.
#   $n: Variable arguments to pass to script containing backup logic.

if [ -z "${1}" ] || [ -z "${2}" ] || [ -z "${3}" ] || [ -z "${4}" ] || [ -z "${5}" ]; then
    printf 'Usage: backup.sh LUKS_UUID OPENED_UUID KEY MAPPER_NAME MOUNT_POINT BACKUP_SCRIPT [VARARGS]\n' 1>&2
    exit 1
fi
# We need to keep the mount point and mapper name globally for the functions.
mapper_name="${4}"
mount_point="$(realpath "${5}")"

# Functions.
finish()
{
    # Unmount and close LUKS device accordingly, depending on if it was already
    # opened and/or mounted.

    if [ -z "${already_mounted}" ]; then
        if ! umount "${mount_point}"; then
            printf 'backup.sh: Failed to unmount LUKS device.\n' 1>&2
            exit 1
        fi
        printf 'backup.sh: Unmounted LUKS device.\n'
    fi
    if [ -z "${already_opened}" ]; then
        if ! cryptsetup close "${mapper_name}"; then
            printf 'backup.sh: Failed to close LUKS device.\n' 1>&2
            exit 1
        fi
        printf 'backup.sh: Closed LUKS device.\n'
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

    # Check if LUKS device is present.
    if [ ! "$(findfs UUID="${1}")" ]; then
        printf 'backup.sh: LUKS device %s not found.\n' "${1}" 1>&2
        exit 1
    fi
    # Check if device is already opened and/or mounted.
    if [ "$(findfs UUID="${2}" 2> /dev/null)" ]; then
        already_opened=1
        # Adjust mapper name accordingly.
        mapper_name="$(basename "$(findfs UUID="${2}")")"
        # Check if mounted.
        if [ "$(findmnt -S UUID="${2}")" ]; then
            already_mounted=1
            # Adjust mount point accordingly.
            mount_point="$(findmnt -no TARGET -S UUID="${2}")"
            printf 'backup.sh: Using already mounted LUKS device at %s.\n' "${mount_point}"
        else
            printf 'backup.sh: Using already opened LUKS device %s.\n' "${1}"
        fi
    fi
    # Open LUKS device is it isn't already opened.
    if [ -z "${already_opened}" ]; then
        if ! cryptsetup -d "${3}" open UUID="${1}" "${mapper_name}"; then
            printf 'backup.sh: Failed to open LUKS device %s.\n' "${1}" 1>&2
            exit 1
        fi
        printf 'backup.sh: Opened LUKS device %s.\n' "${1}"
    fi
    # Mount LUKS device if not already mounted.
    if [ -z "${already_mounted}" ]; then
        if ! mount UUID="${2}" "${mount_point}"; then
            printf 'backup.sh: Failed to mount LUKS device at %s.\n' "${mount_point}" 1>&2
            exit 1
        fi
        printf 'backup.sh: Mounted LUKS device at %s.\n' "${mount_point}"
    fi
}

prepare "${1}" "${2}" "${3}"
script="${6}"
shift 6
"${script}" "${mount_point}" "${@}"
finish
