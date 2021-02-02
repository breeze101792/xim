""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Config vim env
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""    Config vim env
""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible " disable vi compatiable
" set autowrite " auto save when switch document
set number	" show line number
set ruler	" enable status bar ruler
" set nobackup	"no backup when overright
set showcmd    " show entered command
set ignorecase smartcase " search with ignore case
set mps+=<:> "hilighted matched ()
set incsearch " increamental search
set smartindent " smart indent
set backspace=indent,eol,start " when press backspace
set cmdheight=1 " Command line height
set scrolloff=3 " scroll offset, n line for scroll when in top/buttom line
set laststatus=2 " status bar height
set completeopt+=menu
set completeopt+=longest
set completeopt+=preview  " complete menu use list insdead of window
set switchbuf+=usetab,newtab "use new tab when open through quickfix

set t_ti= t_te= " leave content when vim exit
"set relativenumber " use relaaive number

set encoding=utf-8

" Interface Settings
" ===========================================
" Theme
" colorscheme murphy
" colorscheme industry
colorscheme pablo
highlight Pmenu ctermbg=gray "设置补全菜单的背景色
highlight PmenuSel ctermbg=blue 
highlight LineNr ctermfg=7 " set line color

" set statusline=\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ %{&encoding}\ %c:%l/%L%)\ 

" set mouse=
" set mouse=a
" set paste

" Editor Settings
" ===========================================


syntax enable " enable syntax hi
" show the matching part of the pair for [] {} and ()
set showmatch
filetype plugin indent on " base on file type do auto indend
filetype plugin on " auto check file type
" ignore case
set ignorecase
" set autochdir
" hightlight search word
" set hlsearch
" soft tab
set expandtab " extend tab to 4 space
set tabstop=4 "set tab len to 4
set shiftwidth=4 " set >> command width
set softtabstop=4 " let tab stop in 4

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

set clipboard=unnamed
" Language Settings
" ===========================================
" enable all Python syntax highlighting features
let python_highlight_all = 1

" Advance config
" ===========================================
" remove the trailing space
" autocmd FileType c,cpp,h,py,vim,sh,mk autocmd BufWritePre <buffer> %s/\s\+$//e
" auto retab
" autocmd FileType c,cpp,h,py,vim,sh autocmd BufWritePre <buffer> :retab
" Remove empty lines with space
" autocmd FileType c,cpp,h,py,vim autocmd BufWritePre <buffer> :%s/\($\n\s*\)\+\%$//e
" remove double next line
" autocmd FileType c,cpp,h,py,vim autocmd BufWritePre <buffer> :%s/\(\n\n\)\n\+/\1/e

" autocmd FileType c,cpp setlocal equalprg=clang-format
" memorize last open line
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

" set mouse mode when exit
autocmd VimLeave * :set mouse=c

" Tab
" Auto open tab in new window
" autocmd VimEnter * tab all
" autocmd BufAdd * exe 'tablast | tabe "' . expand( "<afile") .'"'
"
" Syntax
" Beautify settings
" set formatoptions 
" tag path
set tags=./tags,tags;/
" set tags=tags
set cscopetag
" set cscopeverbose
set nocscopeverbose
if $CSCOPE_DB != ''
    " echo "Open "$CSCOPE_DB
    cscope add $CSCOPE_DB
endif
" set foldmethod=syntax
set foldmethod=indent
" set nofoldenable
set foldlevel=99

" za: Toggle code folding at the current line. The block that the current line belongs to is folded (closed) or unfolded (opened).
" zo: Open fold.
" zc: Close fold.
" zR: Open all folds.
" zM: Close all folds.

" save debug msg to /tmp/vim-debug
" let g:vim_debug_enable = 1
