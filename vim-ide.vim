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
set cursorcolumn
hi cursorcolumn cterm=NONE ctermbg=233
set cursorline
hi CursorLine   cterm=NONE ctermbg=233

" map shortkey
map <C-Left> <Esc>:tabprev<CR>
map <C-Right> <Esc>:tabnext<CR>
map <S-Left> <Esc>:tabmove -1 <CR>
map <S-Right> <Esc>:tabmove +1 <CR>
map <C-o> <Esc>:tabnew 
map <C-a> <Esc>ggVG<CR>
map <C-_> :Commentary<CR>

" IDE map
" Open and close all the three plugins on the same time
" nmap <F8>  :TrinityToggleAll<CR>
" Open and close the Source Explorer separately
nmap <F8>  :TrinityToggleSourceExplorer<CR>
" Open and close the Taglist separately
nmap <F7> :TrinityToggleTagList<CR>
" Open and close the NERD Tree separately
nmap <F6> :TrinityToggleNERDTree<CR>

" remove the trailing space 
autocmd FileType c,cpp,h,bash,sh autocmd BufWritePre <buffer> %s/\s\+$//e
