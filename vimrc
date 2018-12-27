" Config vim env
" disable vi compatiable
set nocp
set encoding=utf-8
" Load pathogen
execute pathogen#infect()

" Editor Settings
syntax on
filetype plugin indent on
" colorscheme murphy
" colorscheme industry
colorscheme pablo
set nu
set hlsearch
" soft tab
set expandtab
set tabstop=4
set shiftwidth=4
set listchars=tab:>-
" show special char
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
set list
" setup cursor
"set cursorcolumn 
"hi cursorcolumn cterm=NONE ctermbg=DarkGray
set cursorline
"hi CursorLine   cterm=NONE ctermbg=DarkGray

" map shortkey
map <C-Left> <Esc>:tabprev<CR>
map <C-Right> <Esc>:tabnext<CR>
map <S-Left> <Esc>:tabmove -1 <CR>
map <S-Right> <Esc>:tabmove +1 <CR>
map <C-n> <Esc>:tabnew 


