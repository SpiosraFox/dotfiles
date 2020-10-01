#!/bin/sh
pactl set-source-mute @DEFAULT_SOURCE@ toggle
muted="$(pacmd list-sources | grep -A11 '*' | grep 'muted' | tr -d '\t' | awk '{print $2}')"
if [ "$muted" = "no" ]; then
    audio="$XDG_DATA_HOME/media/audio/toggle_on.wav"
else
    audio="$XDG_DATA_HOME/media/audio/toggle_off.wav"
fi
polybar-msg -p "$(pidof polybar)" hook microphone 1
exec paplay "$audio"
