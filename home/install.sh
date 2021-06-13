#!/bin/sh
# Symbolically link personal dotfiles to under home directory.

cd "$(dirname "$(realpath "${0}")")"

# Create directory structure.
find . -name '.git' -prune -o ! -path '.' -a -type d |
while IFS= read -r dir; do
    dir="${dir#./}"; mkdir -p "${HOME}/${dir}" &&
    printf 'Create directory %s.\n' "'${HOME}/${dir}'"
done

# Symlink files.
find . -name '.git' -prune -o ! -name 'install.sh' -a -type f -o -type l |
while IFS= read -r file; do
    file="${file#./}";
    depth="$(printf "${file}" | sed 's/[^\/]//g' | awk '{print length}')";
    dotdots=""; i=0;
    while [ "${i}" -lt "${depth:-0}" ]; do
        dotdots="${dotdots}../"
        i=$((i+1))
    done
    ln -sf "${dotdots}.dotfiles/home/${file}" "${HOME}/${file}" &&
    printf 'Create symlink %s -> %s.\n' "'${HOME}/${file}'" "'${dotdots}.dotfiles/home/${file}'"
done
