# Shell-related.
export ENV="${HOME}/.shrc"

if [ "${PATH}" ]; then
    export PATH="${PATH}:${HOME}/bin"
else
    export PATH="/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:${HOME}/bin"
fi

# XDG Base Directory Specification.
export XDG_CACHE_HOME="${HOME}/var/cache"
export XDG_CONFIG_HOME="${HOME}/etc"
export XDG_DATA_HOME="${HOME}/share"
export XDG_LIB_HOME="${HOME}/lib"
export XDG_LOG_HOME="${HOME}/var/log"
export XDG_STATE_HOME="${HOME}/var/lib"

if [ -z "${XDG_RUNTIME_DIR}" ]; then
    if mkdir -m700 "/tmp/$(id -ru)_runtime"; then
        export XDG_RUNTIME_DIR="/tmp/$(id -ru)_runtime"
    else
        mkdir -p -m700 "${HOME}/run"
        export XDG_RUNTIME_DIR="${HOME}/run"
    fi
fi

# Browser.
if [ -z "${DISPLAY}" ]; then
    export BROWSER=lynx
else
    export BROWSER=firefox
fi

# Editors.
if [ ! -x /usr/bin/vim ] && [ -x /usr/bin/vi ]; then
    export EDITOR=vi
else
    export EDITOR=vim
fi
export VISUAL="${EDITOR}"

# GnuPG.
export GPG_TTY="$(tty)"
export GNUPGHOME="${XDG_STATE_HOME}/gnupg"

# less.
export PAGER=less
export LESSHISTFILE=-

# Password Store.
export PASSWORD_STORE_DIR="${XDG_STATE_HOME}/password-store"

# Xorg.
export XAUTHORITY="${XDG_RUNTIME_DIR}/Xauthority"

# Set umask.
umask 022
