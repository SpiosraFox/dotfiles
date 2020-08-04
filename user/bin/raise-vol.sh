#!/bin/sh
current="$(pacmd dump-volumes | awk 'NR==1 {print $8}' | sed 's/\%//')"
if [ "$current" -lt 100 ]; then
    [ "$current" -lt 99 ] && pactl set-sink-volume @DEFAULT_SINK@ +2% || pactl set-sink-volume @DEFAULT_SINK@ +1%
fi
