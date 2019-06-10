" Config vim env
" disable vi compatiable
set nocp
set encoding=utf-8

" Interface Settings
" ===========================================
" Theme
" colorscheme murphy
" colorscheme industry
colorscheme pablo

" set mouse=
" set mouse=a
" set paste

" Editor Settings
" ===========================================
syntax on
filetype plugin indent on
" ignore case
set ignorecase
set number
" set autochdir
" hightlight search word
" set hlsearch
" soft tab
set expandtab
set tabstop=4
set shiftwidth=4
" set listchars=tab:>-
" show special char
" set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
set listchars=tab:>-,trail:~,extends:>,precedes:<
set list
" setup cursor
set cursorcolumn
hi cursorcolumn cterm=NONE ctermbg=233
set cursorline
hi CursorLine   cterm=NONE ctermbg=233

" Advance config
" ===========================================
" remove the trailing space
" autocmd FileType c,cpp,h,py,vim,sh,mk autocmd BufWritePre <buffer> %s/\s\+$//e
" remove double next line
" autocmd FileType c,cpp,h,py,vim autocmd BufWritePre <buffer> :%s/\(\n\n\)\n\+/\1/e
" auto retab
" autocmd FileType c,cpp,h,py,vim,sh autocmd BufWritePre <buffer> :retab
" TO be removed
" autocmd FileType c,cpp,h,py,vim autocmd BufWritePre <buffer> :%s/\($\n\s*\)\+\%$//e

" autocmd FileType c,cpp setlocal equalprg=clang-format
" memorize last open line
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

" Syntax
set tags=./tags,tags;/
" set tags=tags
set cscopetag cscopeverbose
set foldmethod=syntax
" set foldmethod=indent
" set nofoldenable
set foldlevel=99

" za: Toggle code folding at the current line. The block that the current line belongs to is folded (closed) or unfolded (opened).
" zo: Open fold.
" zc: Close fold.
" zR: Open all folds.
" zM: Close all folds.
