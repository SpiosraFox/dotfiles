#!/bin/sh
# Symbolically link personal dotfiles to under home directory.

basedir="$(dirname "$(realpath "${0}")")"

# Create directory tree.
find "${basedir}" -name '.git' -prune -o ! -path "${basedir}" -a -type d -printf '%P\n' | xargs -I'{}' mkdir -p "${HOME}/{}"

# Symlink files.
find "${basedir}" -name '.git' -prune -o ! -path "${basedir}/$(basename "${0}")" -a -type f -printf '%P\n' | xargs -I'{}' ln -sf "${basedir}/{}" "${HOME}/{}"
