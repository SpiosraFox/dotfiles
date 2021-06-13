#!/bin/sh
status="$(amixer sget "${ALSA_DEFAULT_CAPTURE_CONTROL}" | awk -F"[][]" '/Mono:/ {print $12}')"
if [ "${status}" = "on" ]; then
    printf ''
else
    printf ''
fi
