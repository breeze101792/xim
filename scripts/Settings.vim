""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Config vim env                            """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""    Basic Config vim env
""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible                 " disable vi compatiable
set shortmess=I                  " Disable screen welcome message, Read :help shortmess for everything else.
set encoding=utf-8
set autochdir
set showtabline=2
" set t_ti= t_te=                " leave content when vim exit

""     performance / buffer ---
set hidden                       " can put buffer to the background without writing
                                 " to disk, will remember history/marks.
set lazyredraw                   " don't update the display while executing macros
set updatetime=500
set ttyfast                      " Send more characters at a given time.
set switchbuf+=usetab,newtab     " use new tab when open through quickfix
" set redrawtime=10000

""   regexp
" set gdefault                     " RegExp global by default, will add g in the sed
set magic                        " Enable extended regexes.

""    Others
set report=0                     " Show all changes.
set title                        " Show the filename in the window title bar.
set splitbelow splitright        " how to split new windows.
" :e ++ff=unix " Show ^M windows


""""    Editor Settings (inside buffer)
""""""""""""""""""""""""""""""""""""""""""""""""""""""
set smartindent                                   " smart indent
" set mps+=<:>                                    " hilighted matched ()
set showmatch                                     " show the matching part of the pair for [] {} and ()
set backspace=indent,eol,start                    " when press backspace
set undolevels=999                                " More undo (default=100)
set linebreak                                     " Avoid wrapping a line in the middle of a word.
" set wrap                                          " Enable line wrapping.
" set virtualedit=block                           " in visal mode can select empty space


" Number
set number                                        " show line number
" set relativenumber                                " use relaaive number
" set numberwidth=5                               " width of numbers line (default on gvim is 4)
"  Auto change relativenumber
" augroup numbertoggle
"   autocmd!
"   autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
"   autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
" augroup END

" Search
set ignorecase smartcase                          " search with ignore case
set incsearch                                     " increamental search
" set hlsearch                                    " hightlight search word

""    Spelling options
" set spelllang=en_us                             " spell checking
" set spell                                       " Enable spellchecking.

""    file options
" set autowrite                                   " auto save when switch document
" set noswapfile
set directory=~/.vim/swp//
" set nobackup                                    " no backup when overright
" set backupdir=~/.vim/backup//
" set autoread                                    " reload files if changed externally
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.o,*.a,*.d

""    clipboard options
set clipboard=unnamed                             " Access system clipboard
set clipboard+=unnamedplus                        " use systemc clip buffer instead
set history=1000                                  " Increase the undo limit.

" soft tab
set expandtab                                     " extend tab (soft tab)
set tabstop=4                                     " set tab len to 4
set softtabstop=4                                 " let tab stop in 4
set shiftround                                    " When shifting lines, round the indentation to the nearest multiple of  " shiftwidth.
set shiftwidth=4                                  " When shifting, indent using four spaces.
set smarttab                                      " Insert tabstop number of spaces when the tab key is pressed.

" show special char
" set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
" set listchars=tab:>-,trail:~,extends:>,precedes:<
set showbreak=↪\
set listchars=tab:▸-,nbsp:␣,trail:·,precedes:←,extends:→
" set listchars=tab:▸\ ,nbsp:␣,trail:·,precedes:←,extends:→,eol:↲
set list

""""    IDE Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Syntax one
syntax enable              " enable syntax hi, cann't be place after theme settings
syntax sync maxlines=50
" syntax sync minlines=200
" set synmaxcol=100        " arbitrary number < 3000 (default value)
filetype plugin indent on  " base on file type do auto indend

" set formatoptions
set tags=./tags,tags;/     " tag path
set cscopetag              " set tags=tags
set nocscopeverbose        " set cscopeverbose

" Tag setup
if $CSCOPE_DB != ''
    " echo "Open "$CSCOPE_DB
    cscope add $CSCOPE_DB
endif
if $PROJ_VIM != ''
    " echo "Source "$PROJ_VIM
    so $PROJ_VIM
endif
if $CCTREE_DB != ''
    " echo "Open "$CCTREE_DB
    " autocmd VimEnter * CCTreeLoadXRefDBFromDisk $CCTREE_DB
    autocmd VimEnter * CCTreeLoadXRefDB $CCTREE_DB
    " autocmd VimEnter * CCTreeLoadDB $CSCOPE_DB
endif

" Folding
set foldmethod=indent " can be set to syntax, indent, manual
set foldnestmax=10    " Only fold up to three nested levels.
set foldlevel=99
" set foldminlines=3    " show the min line of folded code
set nofoldenable

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

""""    Interface Settings (Out side buffer)
""""""""""""""""""""""""""""""""""""""""""""""""""""""
set t_Co=256                " force terminal use 256 color
set scroll=5                " scroll move for ctrl+u/d
set scrolloff=3             " scroll offset, n line for scroll when in top/buttom line
set sidescrolloff=5         " The number of screen columns to keep to the left and right of the cursor.
set display+=lastline       " Always try to show a paragraph’s last line.
set noerrorbells            " Disable beep on errors.

" Menu
set wildmenu                " Display command line’s tab complete options as a menu.
set completeopt+=menu
set completeopt+=menuone
set completeopt+=longest
" set completeopt+=preview  " complete menu use list insdead of window, this will move main window(stable-window may fix)

" Status/Command
set showcmd      " show partial command on last line of screen.
set cmdheight=1  " Command line height
set laststatus=2 " status bar height
set shortmess=aO  " option to avoid hit enter, a for all, O for overwrite when reading file
set ruler        " enable status bar ruler
" set statusline=\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ %{&encoding}\ %c:%l/%L%)\ 

" Other settings
" use group to set it
" set mouse=c
" set mouse=a
" set paste

" setup column cursor line, this will slow down vim speed
" set cursorcolumn

" setup row cursor line
set cursorline
if version >= 802
    set cursorlineopt=number " only line number will be highlighted, dosen't
endif

" Windows fill chars
" set fillchars=stl:^,stlnc:=,vert:\ ,fold:-,diff:-
set fillchars+=vert:│


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
autocmd BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

" set mouse mode when exit
augroup mouse_gp
    autocmd!
    autocmd VimEnter * :set mouse=c
    autocmd VimLeave * :set mouse=c
augroup END

""""    Other Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" save debug msg to /tmp/vim-debug
" let g:vim_debug_enable = 1
" Check syntax time
" syntime on
" syntime report
