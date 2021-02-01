#!/bin/sh
export WINEARCH=win64
export WINEDEBUG=-all
export WINEPREFIX="$HOME/var/lib/wine/prefix/$PREFIX"

if [ ! -z "$DXVK" ] && [ "$DXVK" -eq 1 ]; then
    export DXVK_LOG_LEVEL=none
    export DXVK_STATE_CACHE_PATH="$XDG_CACHE_HOME/dxvk"
fi