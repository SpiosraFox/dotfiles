#!/bin/sh
# Sign kernel files for secure boot.
#
# Parameters.
#   $1: Secret key.
#   $2: Public key.

while read -r kernel; do
    if ! sbverify --cert "${2}" /boot/vmlinuz-"${kernel}" > /dev/null 2>&1; then
        sbsign --output /boot/vmlinuz-"${kernel}" --key "${1}" --cert "${2}" /boot/vmlinuz-"${kernel}" 2> /dev/null
    fi
done
