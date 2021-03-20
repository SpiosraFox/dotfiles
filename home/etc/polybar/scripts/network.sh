#!/bin/sh
interface_type="$(ip link show | awk '/state UP/ {print substr($2,0,1)}')"
if [ ! -z "${interface_type}" ]; then
    if [ "${interface_type}" = "e" ]; then
        echo " Network "
    else
        echo " Network"
    fi
else
    echo "No Network"
fi
