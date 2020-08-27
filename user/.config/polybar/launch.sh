#!/bin/sh
# Kill existing instances.
pkill polybar
while pgrep -xu "$(id -ru)" polybar > /dev/null; do
    sleep 1
done

# No thermal zones and hwmon files change? Working around it...
cpu_name="k10temp"
gpu_name="amdgpu"
for hwmon in /sys/class/hwmon/*; do
    name="$(cat "$hwmon/name")"
    [ "$name" = "$cpu_name" ] && cpu_hwmon="$hwmon/temp1_input"
    [ "$name" = "$gpu_name" ] && gpu_hwmon="$hwmon/temp1_input"
done

MICROPHONE_SCRIPT="$XDG_CONFIG_HOME/polybar/scripts/microphone.sh" \
NETWORK_SCRIPT="$XDG_CONFIG_HOME/polybar/scripts/network.sh" \
WEATHER_SCRIPT="$XDG_CONFIG_HOME/polybar/scripts/weather-wrapper.sh" \
CPU_HWMON="$cpu_hwmon" \
GPU_HWMON="$gpu_hwmon" exec polybar bar
