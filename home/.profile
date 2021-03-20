# Shell-Related.
export ENV="${HOME}/.shrc"
export PATH="${PATH}:${HOME}/bin:${HOME}/local/bin"

# XDG Base Directory Specification.
export XDG_CACHE_HOME="${HOME}/var/cache"
export XDG_CONFIG_HOME="${HOME}/etc"
export XDG_DATA_HOME="${HOME}/local/share"

# Browser.
if [ -z "${DISPLAY}" ]; then
    export BROWSER=lynx
else
    export BROWSER=firefox
fi

# Editors.
export EDITOR=vim
export VISUAL="${EDITOR}"

# GnuPG.
export GPG_TTY="$(tty)"

# less.
export LESSHISTFILE="-"
export PAGER=less

# ledger.
export LEDGER_FILE="${HOME}/share/docs/ledger/ledger"

# Source standard startup script.
[ -f "${ENV}" ] && . "${ENV}"

# Set umask.
umask 0022
