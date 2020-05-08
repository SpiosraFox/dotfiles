# source standard startup script
[[ -f "$ENV" ]] && . "$ENV"

# initialize modules
autoload -U compinit
compinit

# set prompt
PS1='[%T %n@%m %~]%# > '
