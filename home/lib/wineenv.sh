export WINEARCH=win64
export WINEDEBUG=-all
export WINEPREFIX="${XDG_STATE_HOME}/wine/prefix/${PREFIX}"

if [ "${DXVK}" ]; then
    export DXVK_LOG_LEVEL=none
    export DXVK_STATE_CACHE_PATH="${XDG_CACHE_HOME}/dxvk"
fi
