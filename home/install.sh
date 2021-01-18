#!/bin/sh
export BASEDIR=$(cd $(dirname "$0") && pwd)

# Create directory tree.
find "$BASEDIR" -name '.git' -prune -o \! -path "$BASEDIR" -a -type d -exec sh -c '
    directory=$(echo "$0" | sed '\''s|'"$BASEDIR/"'||'\'')
    [ ! -d "$HOME/$directory" ] && mkdir -p "$HOME/$directory"
    ' '{}' \;

# Symlink files.
find "$BASEDIR" -name '.git' -prune -o \! -name $(basename "$0") -a -type f -exec sh -c '
    file=$(echo "$0" | sed '\''s|'"$BASEDIR/"'||'\'')
    ln -fs "$BASEDIR/$file" "$HOME/$file"
    ' '{}' \;
