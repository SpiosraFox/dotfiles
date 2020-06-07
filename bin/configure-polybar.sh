#!/bin/sh
[ ! -z "$XDG_CONFIG_HOME" ] && config="$XDG_CONFIG_HOME/polybar/config" || config="$HOME/.config/polybar/config"

# configure for temperature hwmon
line_no="$(grep -n 'hwmon-path' $config | awk '{print $1}' FS=:)"
hwmon="$($HOME/bin/get-temp-hwmon.sh)"
new_config="$(sed $line_no's:.*:hwmon-path = '$hwmon':' $config)"
echo "$new_config" > "$config"
