#!/bin/sh
compositor="${1}"
profile="${XDG_CONFIG_HOME}/wlprofile"

[ -f "${profile}" ] && . "${profile}"

case "${compositor}" in
    "dwl")
        exec dwl -s "${XDG_CONFIG_HOME}/dwl/init.sh"
        ;;
    "sway")
        exec sway
        ;;
    *)
        printf 'Execution of %s is unimplemented.\n' "'${compositor}'" 1>&2
        exit 1
        ;;
esac
