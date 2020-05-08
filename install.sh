#!/bin/sh
export BASEDIR=$(cd $(dirname "$0") && pwd)

# create directory tree
find "$BASEDIR" -name '.git' -prune -o \! -path "$BASEDIR" -a -type d -exec sh -c '
    directory=$(echo "$0" | sed '\''s|'"$BASEDIR/"'||'\'')
    [ ! -d "$HOME/$directory" ] && mkdir -p "$HOME/$directory"
    ' '{}' \;

# symlink files
find "$BASEDIR" -name '.git' -prune -o \! -name $(basename "$0") -a -type f -exec sh -c '
    file=$(echo "$0" | sed '\''s|'"$BASEDIR/"'||'\'')
    ln -fs "$BASEDIR/$file" "$HOME/$file"
    ' '{}' \;
