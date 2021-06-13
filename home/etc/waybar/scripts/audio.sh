#!/bin/sh
status="$(amixer sget "${ALSA_DEFAULT_PLAYBACK_CONTROL}" | awk -F"[][]" '/Left:/ {print $2$6}')"
if [ "${status#*%}" = "off" ]; then
    printf ''
else
    printf '%s' " ${status%\%*}"
fi
