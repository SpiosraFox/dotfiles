#!/bin/sh
userresources="$HOME/.Xresources"
usermodmap="$HOME/.Xmodmap"
userprofile="$HOME/.xprofile"
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# Merge in defaults and keymaps.
if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# Source xprofile.
if [ -f "$userprofile" ]; then
    . "$userprofile"
fi

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# Start.
setxkbmap -model pc104 -layout us,no,se -variant ,, -option grp:rctrl_rshift_toggle
xbindkeys
feh --no-fehbg --bg-max "$XDG_DATA_HOME/media/img/background.png"
exec i3
