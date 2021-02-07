""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Config vim env                            """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""    Config vim env
""""""""""""""""""""""""""""""""""""""""""""""""""""""
set encoding=utf-8
set nocompatible " disable vi compatiable
set showcmd    " show entered command
set switchbuf+=usetab,newtab "use new tab when open through quickfix
set clipboard=unnamed
set autochdir
" set t_ti= t_te= " leave content when vim exit
" set relativenumber " use relaaive number
" set hlsearch " hightlight search word


""    save options
" set autowrite " auto save when switch document
" set nobackup  "no backup when overright


""""    Editor Settings (inside buffer)
""""""""""""""""""""""""""""""""""""""""""""""""""""""
set number  " show line number
set ruler   " enable status bar ruler
set ignorecase smartcase " search with ignore case
set smartindent " smart indent
set mps+=<:> "hilighted matched ()
set showmatch " show the matching part of the pair for [] {} and ()
set incsearch " increamental search
set backspace=indent,eol,start " when press backspace

" soft tab
set expandtab " extend tab to 4 space
set tabstop=4 "set tab len to 4
set shiftwidth=4 " set >> command width
set softtabstop=4 " let tab stop in 4

syntax enable " enable syntax hi, can be place after theme settings

filetype plugin indent on " base on file type do auto indend

" show special char
" set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
" set listchars=tab:>-,trail:~,extends:>,precedes:<
set showbreak=↪\ 
set listchars=tab:▸\ ,nbsp:␣,trail:·,precedes:←,extends:→
" set listchars=tab:▸\ ,nbsp:␣,trail:·,precedes:←,extends:→,eol:↲
set list

""""    Interface Settings (Out side buffer)
""""""""""""""""""""""""""""""""""""""""""""""""""""""
set cmdheight=1 " Command line height
set scrolloff=3 " scroll offset, n line for scroll when in top/buttom line
set laststatus=2 " status bar height

" Other settings
" set mouse=
" set mouse=a
" set paste

"" Theme
" theme should be the start of all interface settings
" colorscheme murphy
" colorscheme industry
" colorscheme koehler
" colorscheme slate
colorscheme pablo
" colorscheme peachpuff
" colorscheme torte
highlight Pmenu ctermbg=gray "menu background color
highlight PmenuSel ctermbg=blue
highlight LineNr ctermfg=7 ctermbg=NONE" set line color

" set statusline=\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ %{&encoding}\ %c:%l/%L%)\ 

" setup column cursor line, this will slow down vim speed
" set cursorcolumn
" hi cursorcolumn cterm=NONE ctermbg=233
" setup row cursor line
set cursorline
highlight CursorLine   cterm=NONE ctermbg=233
highlight CursorLineNR cterm=NONE ctermbg=233


""""    IDE Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
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

" OmniCppComplete
" let OmniCpp_NamespaceSearch = 1
" let OmniCpp_GlobalScopeSearch = 1
" let OmniCpp_ShowAccess = 1
" let OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
" let OmniCpp_MayCompleteDot = 1 " autocomplete after .
" let OmniCpp_MayCompleteArrow = 1 " autocomplete after ->
" let OmniCpp_MayCompleteScope = 1 " autocomplete after ::
" let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]

" automatically open and close the popup menu / preview window
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
set completeopt+=menu
set completeopt+=menuone
set completeopt+=longest
set completeopt+=preview  " complete menu use list insdead of window


""""    Advance Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
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

""""    Other Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Tab
" Auto open tab in new window
" autocmd VimEnter * tab all
" autocmd BufAdd * exe 'tablast | tabe "' . expand( "<afile") .'"'
"

" za: Toggle code folding at the current line. The block that the current line belongs to is folded (closed) or unfolded (opened).
" zo: Open fold.
" zc: Close fold.
" zR: Open all folds.
" zM: Close all folds.

" save debug msg to /tmp/vim-debug
" let g:vim_debug_enable = 1
