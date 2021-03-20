#!/bin/sh
prefix_dir="${HOME}/var/lib/wine/prefix"
for prefix in "${prefix_dir}/"*; do
    WINEPREFIX="${prefix}" wineserver -k
done
