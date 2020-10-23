#!/bin/sh
monitors="$(xrandr | grep -o '[0-9]*x[0-9]*[+-][0-9]*[+-][0-9]*')"
mouseloc="$(xdotool getmouselocation --shell | awk '{print $1,$2}' RS='')"
mousex="$(echo "$mouseloc" | sed 's/X=\([0-9]\+\).*/\1/')"
mousey="$(echo "$mouseloc" | sed 's/.*Y=\([0-9]\+\).*/\1/')"

for mon in $monitors; do
    monw="$(echo "$mon" | awk '{print $1}' FS='[x+]')"
    monh="$(echo "$mon" | awk '{print $2}' FS='[x+]')"
    monx="$(echo "$mon" | awk '{print $3}' FS='[x+]')"
    mony="$(echo "$mon" | awk '{print $4}' FS='[x+]')"

    if [ "$mousex" -ge "$monx" ] && [ "$mousex" -le "$((monw+monx))" ]; then
        if [ "$mousey" -ge "$mony" ] && [ "$mousey" -le "$((monh+mony))" ]; then
            maim -ug ""$monw"x"$monh"+"$monx"+"$mony"" "$HOME/var/tmp/screen.png"
            exit 0
        fi
    fi
done
