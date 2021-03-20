#!/bin/sh
# Derived from Dalton Nell (naelstrof).
# https://gist.github.com/naelstrof/f9b74b5221cdc324c0911c89a47b8d97

monitors="$(xrandr | grep -o '[0-9]*x[0-9]*[+-][0-9]*[+-][0-9]*')"
mouseloc="$(xdotool getmouselocation --shell | awk '{print $1,$2}' RS='')"
mousex="$(printf '%s' "${mouseloc}" | sed 's/X=\([0-9]\+\).*/\1/')"
mousey="$(printf '%s' "${mouseloc}" | sed 's/.*Y=\([0-9]\+\).*/\1/')"

printf '%s\n' "${monitors}" | while read -r mon; do
    monw="$(printf '%s' "${mon}" | awk '{print $1}' FS='[x+]')"
    monh="$(printf '%s' "${mon}" | awk '{print $2}' FS='[x+]')"
    monx="$(printf '%s' "${mon}" | awk '{print $3}' FS='[x+]')"
    mony="$(printf '%s' "${mon}" | awk '{print $4}' FS='[x+]')"

    if [ "${mousex}" -ge "${monx}" ] && [ "${mousex}" -le "$((monw+monx))" ]; then
        if [ "${mousey}" -ge "${mony}" ] && [ "${mousey}" -le "$((monh+mony))" ]; then
            maim -ug ""${monw}"x"${monh}"+"${monx}"+"${mony}"" "${HOME}/var/tmp/screen.png"
            exit 0
        fi
    fi
done
