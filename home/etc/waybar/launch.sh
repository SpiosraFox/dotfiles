#!/bin/sh
config="$(cat "${XDG_CONFIG_HOME}/waybar/config.template")"

network_interface="enp3s0"
microphone_script="${XDG_CONFIG_HOME}/waybar/scripts/microphone.sh"
audio_script="${XDG_CONFIG_HOME}/waybar/scripts/audio.sh"
cpu_hwmon_name="k10temp"
gpu_hwmon_name="amdgpu"

pkill waybar
while pgrep -xu "$(id -ru)" waybar >/dev/null; do
    sleep 1
done

get_line()
{
    pattern="${1}"
    printf '%s' "${config}" | grep -n "${pattern}" | cut -d: -f1
}

set_var()
{
    var="${1}"
    config="$(printf '%s' "${config}" | sed "${line}s-{}-${var}-")"
}

for hwmon in /sys/class/hwmon/hwmon*; do
    name="$(cat "${hwmon}/name")"
    if [ "${name}" = "${cpu_hwmon_name}" ]; then
        cpu_temp_input="${hwmon}/temp1_input"
    fi
    if [ "${name}" = "${gpu_hwmon_name}" ]; then
        gpu_temp_input="${hwmon}/temp1_input"
    fi
done

line="$(get_line 'interface')"
set_var "${network_interface}"

line="$(get_line 'microphone": {')"
line="$((line+1))"
set_var "${microphone_script}"

line="$(get_line 'audio": {')"
line="$((line+1))"
set_var "${audio_script}"

line="$(get_line 'temperature#cpu": {')"
line="$((line+1))"
set_var "${cpu_temp_input}"

line="$(get_line 'temperature#gpu": {')"
line="$((line+1))"
set_var "${gpu_temp_input}"

printf '%s' "${config}" >"${XDG_CONFIG_HOME}/waybar/config"

exec waybar
