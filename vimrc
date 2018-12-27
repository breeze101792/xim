set nocp
execute pathogen#infect()

syntax on
filetype plugin indent on
"colorscheme murphy
" soft tab
set expandtab
set tabstop=4
set shiftwidth=4
set nu
set listchars=tab:>-
set cursorline
set cursorcolumn 
set encoding=utf-8
"hi CursorLine   cterm=NONE ctermbg=DarkGray
"darkred ctermfg=white guibg=darkred guifg=white

" map shortkey
map <C-Left> <Esc>:tabprev<CR>
map <C-Right> <Esc>:tabnext<CR>
map <S-Left> <Esc>:tabmove -1 <CR>
map <S-Right> <Esc>:tabmove +1 <CR>
map <C-n> <Esc>:tabnew 


" show special char
" set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
" set list
" set hlsearch
