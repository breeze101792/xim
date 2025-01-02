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
set termencoding=utf-8
set formatoptions+=mM
set fileencodings=utf-8
set autochdir
set showtabline=2
" set t_ti= t_te=                " leave content when vim exit

""     performance / buffer ---
set hidden                       " can put buffer to the background without writing
                                 " to disk, will remember history/marks.
set lazyredraw                   " don't update the display while executing macros
set updatetime=500               " how long wil vim wait after your interaction to start plugins/other event
set ttyfast                      " Send more characters at a given time.
" set switchbuf+=usetab,newtab     " use new tab when open through quickfix
set redrawtime=1000
"" Command timeout, only affect on mapping command
"" timeout and timeoutlen apply to mappings
set timeout
set timeoutlen=500
set ttimeoutlen=200
"" ttimeout and ttimeoutlen apply to key codes.

""   regexp
" set gdefault                     " RegExp global by default, will add g in the sed
" set magic                          " Enable extended regexes.
" set regexpengine=1                 " use old reg eng, this may disable some reg syntax

""    Others
set report=0                     " Show all changes.
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
set title                        " Show the filename in the window title bar.
set splitbelow splitright        " how to split new windows.
" FIXME. this will affect Quickfix, so disable it for now.
" set splitkeep=topline                             " keeps the same screen screen lines in all split windows


" Number
set number                                        " show line number
" set relativenumber                                " use relaaive number
" set numberwidth=5                               " width of numbers line (default on gvim is 4)

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
" set directory=~/.vim/swp//
exec "set directory=" . g:IDE_ENV_CONFIG_PATH . "/swp/"
" set nobackup                                    " no backup when overright
" set backupdir=~/.vim/backup//
" set autoread                                    " reload files if changed externally

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
if get(g:, 'IDE_CFG_SPECIAL_CHARS', "n") == "y"
    set showbreak=↪\
    set listchars=tab:▸-,nbsp:␣,trail:·,precedes:←,extends:→
else
    set showbreak=→\
    set listchars=tab:▸-,nbsp:␣,trail:·,precedes:←,extends:→
endif
" set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
" set listchars=tab:>-,trail:~,extends:>,precedes:<
" set listchars=tab:▸\ ,nbsp:␣,trail:·,precedes:←,extends:→,eol:↲
set list

"" Smart edit
set nofixendofline " enable this will cause vim add new line at the end of line

""""    IDE Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Syntax one
" set synmaxcol=100        " arbitrary number < 3000 (default value)
syntax sync maxlines=50
" syntax sync minlines=200
" since vim-plug will auto enable the following 2 lines, don't enable it
" syntax enable              " Enable syntax at theme, otherwise it will source to may file, enable syntax hi, cann't be place after theme settings
" filetype plugin indent on  " base on file type do auto indend

" set formatoptions
" set tags=./tags,tags;/     " tag path, this will be setted on auto function
if has('cscope')
    " Nvim 0.9 remove cscope support
    set cscopetag              " set tags=tags
    set nocscopeverbose        " set cscopeverbose
endif

" Folding
" set foldmethod=syntax " can be set to syntax, indent, manual
set foldnestmax=10    " Only fold up to three nested levels.
set foldlevel=99
" set foldminlines=3    " show the min line of folded code
set nofoldenable

" OmniCppComplete
" let OmniCpp_GlobalScopeSearch = 0
" let OmniCpp_DisplayMode = 0
" let OmniCpp_ShowScopeInAbbr = 1
" let OmniCpp_NamespaceSearch = 2
" let OmniCpp_ShowAccess = 1
" let OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
" let OmniCpp_MayCompleteDot = 1 " autocomplete after .
" let OmniCpp_MayCompleteArrow = 1 " autocomplete after ->
" let OmniCpp_MayCompleteScope = 1 " autocomplete after ::
" let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]

""""    Interface Settings (Out side buffer)
""""""""""""""""""""""""""""""""""""""""""""""""""""""
set t_Co=256                " force terminal use 256 color
set scroll=5                " scroll move for ctrl+u/d
set scrolloff=3             " scroll offset, n line for scroll when in top/buttom line
set sidescrolloff=5         " The number of screen columns to keep to the left and right of the cursor.
set display+=lastline       " Always try to show a paragraph’s last line.
set noerrorbells            " Disable beep on errors.

" Menu
" set wildmode=longest,list:list
set wildmenu                " Display command line’s tab complete options as a menu.
set completeopt+=menu
set completeopt+=menuone
set completeopt+=longest
set wildignore+=*.so,*.swp,*.zip,*.o,*.a,*.d,*.img,*.tar.*
" set completeopt+=preview  " complete menu use list insdead of window, this will move main window(stable-window may fix)

" Status/Command
set showcmd      " show partial command on last line of screen.
set laststatus=2 " status bar always show
set cmdheight=1  " Command line height
set shortmess=aO " option to avoid hit enter, a for all, O for overwrite when reading file
set ruler        " enable status bar ruler
" set statusline=[%{mode()}]\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ %{&encoding}\ %c:%l/%L%)

" Other settings
" use group to set it
set mouse=c
" set mouse=a
" set paste

" setup column cursor line, this will slow down vim speed
if g:IDE_CFG_HIGH_PERFORMANCE_HOST == 'y'
    set cursorcolumn
endif
" This is for linux, we should not let our code length beyound 80 chars
set colorcolumn=81

" setup row cursor line
set cursorline
if version >= 802
    set cursorlineopt=number " only line number will be highlighted, dosen't
endif

" Windows fill chars
" set fillchars=stl:^,stlnc:=,vert:\ ,fold:-,diff:-
set fillchars+=vert:│

" Set cursor shape on different mode
" "Cursor settings:
"  1 -> blinking block
"  2 -> solid block 
"  3 -> blinking underscore
"  4 -> solid underscore
"  5 -> blinking vertical bar
"  6 -> solid vertical bar
set t_SI="\e[6 q"
set t_EI="\e[2 q"
set t_SR="\e[4 q"

""""    Patch For vim Plugins
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Match paren
" let g:loaded_matchparen = 1 " do this will not load plugin
let g:matchparen_timeout = 60
let g:matchparen_insert_timeout = 60

""""    Other Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" save debug msg to /tmp/vim-debug
if 0
    let g:vim_debug_enable = 1
    Check syntax time
    syntime on
    syntime report
endif
