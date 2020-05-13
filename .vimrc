colo industry
syntax enable

set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab
set number

if argv(0) ==# '.'
    let g:netrw_browse_split = 0
else
    let g:netrw_browse_split = 4
endif

let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_winsize = 20

map! <F3> <C-R>=strftime('%Y-%m-%d %H:%M %z %Z')<CR>

filetype plugin indent on
