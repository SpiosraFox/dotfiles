# Source standard startup script.
[[ -f "$ENV" ]] && . "$ENV"

# Initialize modules.
autoload -U compinit
compinit

# Set prompt.
PS1='[%T %n@%m %~]%# > '

# Binds
bindkey -v
