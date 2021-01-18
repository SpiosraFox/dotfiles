#!/bin/sh
. /usr/local/lib/sign-kernel-env.sh
while read -r kernel; do
    sbverify --cert "$PUBLIC_KEY" /boot/vmlinuz-"$kernel" >/dev/null 2>&1
    if [ "$?" -ne 0 ]; then
        sudo -u "$SUSER" sh -c "gpg -o- -d $PRIVATE_KEY 2>/dev/null" | sbsign --output /boot/vmlinuz-"$kernel" --key /dev/stdin --cert "$PUBLIC_KEY" /boot/vmlinuz-"$kernel" 2>/dev/null
    fi
done
