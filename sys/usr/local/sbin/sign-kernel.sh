#!/bin/sh
. /usr/local/lib/sign-kernel-env.sh
sbverify --cert "$PUBLIC_KEY" /boot/vmlinuz-linux >/dev/null 2>&1
if [ "$?" -ne 0 ]; then
    sudo -u "$SUSER" sh -c "gpg -o- -d $PRIVATE_KEY 2>/dev/null" | sbsign --output /boot/vmlinuz-linux --key /dev/stdin --cert "$PUBLIC_KEY" /boot/vmlinuz-linux 2>/dev/null
fi
