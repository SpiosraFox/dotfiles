#!/bin/sh
muted="$(pacmd list-sources | grep -A11 '*' | grep 'muted' | tr -d '\t' | awk '{print $2}')"
[ "$muted" = "no" ] && echo  || echo 
