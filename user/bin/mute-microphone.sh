#!/bin/sh
pactl set-source-mute @DEFAULT_SOURCE@ toggle
exec polybar-msg -p "$(pidof polybar)" hook microphone 1
