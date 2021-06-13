#!/bin/sh
resources="${XDG_CONFIG_HOME}/Xresources"
profile="${XDG_CONFIG_HOME}/xprofile"

[ -f "${resources}" ] && xrdb -merge "${resources}"
[ -f "${profile}" ] && . "${profile}"

setxkbmap -model pc104 -layout us,se -variant ,, -option grp:rctrl_rshift_toggle
xbindkeys
feh --no-fehbg --bg-max "${XDG_CONFIG_HOME}/background.png"
exec dwm
