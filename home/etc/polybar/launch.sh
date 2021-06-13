#!/bin/sh
cpu_hwmon_name="k10temp"
gpu_hwmon_name="amdgpu"

pkill polybar
while pgrep -xu "$(id -ru)" polybar >/dev/null; do
    sleep 1
done

for hwmon in /sys/class/hwmon/hwmon*; do
    name="$(cat "${hwmon}/name")"
    if [ "${name}" = "${cpu_hwmon_name}" ]; then
        cpu_temp_input="${hwmon}/temp1_input"
    fi
    if [ "${name}" = "${gpu_hwmon_name}" ]; then
        gpu_temp_input="${hwmon}/temp1_input"
    fi
done

MICROPHONE_SCRIPT="${XDG_CONFIG_HOME}/polybar/scripts/microphone.sh" \
NETWORK_SCRIPT="${XDG_CONFIG_HOME}/polybar/scripts/network.sh" \
WEATHER_SCRIPT="${XDG_CONFIG_HOME}/polybar/scripts/weather-wrapper.sh" \
CPU_HWMON="${cpu_temp_input}" \
GPU_HWMON="${gpu_temp_input}" exec polybar bar
