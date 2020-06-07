#!/bin/sh
# Kill existing instances
pkill polybar
while pgrep -u "$UID" -x polybar > /dev/null; do
    sleep 1
done

# No thermal zones and hwmon files change? Working around it...
name="amdgpu"
for hwmon in /sys/class/hwmon/*; do
    grep "$name" "$hwmon/name" > /dev/null
    if [ "$?" -eq 0 ]; then
        hwmon="$hwmon/temp1_input"
        break
    fi
done

NETWORK_SCRIPT="$XDG_CONFIG_HOME/polybar/scripts/network.sh" HWMON="$hwmon" polybar bar &
