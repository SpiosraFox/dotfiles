#!/bin/sh
user="spiosra"
public_key="/home/spiosra/.secureboot/db.crt"
private_key="/home/spiosra/.secureboot/db.key.gpg"

sbverify --cert "$public_key" /boot/vmlinuz-linux >/dev/null 2>&1
if [ "$?" -ne 0 ]; then
    sudo -u "$user" sh -c "gpg -o- -d $private_key 2>/dev/null" | sbsign --output /boot/vmlinuz-linux --key /dev/stdin --cert "$public_key" /boot/vmlinuz-linux 2>/dev/null
fi
