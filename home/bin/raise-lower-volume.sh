#!/bin/sh
if [ "$1" = "raise" ] || [ "$1" = "lower" ]; then
    audio="$XDG_DATA_HOME/media/audio/beep.wav"
    current="$(pacmd dump-volumes | awk 'NR==1 {print $8}' | sed 's/\%//')"
    if [ "$1" = "raise" ]; then
        if [ "$current" -lt 100 ]; then
            [ "$current" -lt 99 ] && pactl set-sink-volume @DEFAULT_SINK@ +2% || pactl set-sink-volume @DEFAULT_SINK@ +1%
            [ -f "$audio" ] && exec paplay "$audio"
        fi
    else
        if [ "$current" -gt 0 ]; then
            pactl set-sink-volume @DEFAULT_SINK@ -2%
            [ -f "$audio" ] && exec paplay "$audio"
        fi
    fi
fi
