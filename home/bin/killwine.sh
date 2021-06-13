#!/bin/sh
prefix_dir="${XDG_STATE_HOME}/wine/prefix"
for prefix in "${prefix_dir}/"*; do
    WINEPREFIX="${prefix}" wineserver -k
done
