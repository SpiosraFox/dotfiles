# define variables
[ -z "$DISPLAY" ] && export BROWSER=lynx || export BROWSER=brave
export EDITOR=vim
export ENV="$HOME/.shrc"
export GPG_TTY="$(tty)"
export PAGER=less
export PATH="$PATH:$HOME/bin"
export VISUAL="$EDITOR"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

# source standard startup script
[ -f "$ENV" ] && . "$ENV"

# set umask
umask 0022
