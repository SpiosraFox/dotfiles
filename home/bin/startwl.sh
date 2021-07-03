#!/bin/sh
compositor="${1}"
gtk3_config="${XDG_CONFIG_HOME}/gtk-3.0/settings.ini"
profile="${XDG_CONFIG_HOME}/wlprofile"

[ -f "${profile}" ] && . "${profile}"

if [ -x /usr/bin/gsettings ] && [ -f "${gtk3_config}" ]; then
    gschema="org.gnome.desktop.interface"
    gsettings set "${gschema}" gtk-theme    "$(grep -e 'gtk-theme-name' "${gtk3_config}" | cut -d'=' -f2)"
    gsettings set "${gschema}" icon-theme   "$(grep -e 'gtk-icon-theme-name' "${gtk3_config}" | cut -d'=' -f2)"
    gsettings set "${gschema}" cursor-theme "$(grep -e 'gtk-cursor-theme-name' "${gtk3_config}" | cut -d'=' -f2)"
    gsettings set "${gschema}" font-name    "$(grep -e 'gtk-font-name' "${gtk3_config}" | cut -d'=' -f2)"
fi

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
