#!/bin/sh
export LIBVIRT_DEFAULT_URI='qemu:///system'

[ "$1" = "start" ]    && exec virsh start windows
[ "$1" = "shutdown" ] && exec virsh shutdown windows
[ "$1" = "destroy" ]  && exec virsh destroy windows
[ "$1" = "edit" ]     && exec virsh edit windows
