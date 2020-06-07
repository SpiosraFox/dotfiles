#!/bin/sh
name="amdgpu"
for hwmon in /sys/class/hwmon/*; do
    grep "$name" "$hwmon/name" 1>/dev/null
    if [ "$?" -eq 0 ]; then
        echo "$hwmon/temp1_input"
        break
    fi
done
