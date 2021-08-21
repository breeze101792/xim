""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Config vim env                            """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""    Basic Config vim env
""""""""""""""""""""""""""""""""""""""""""""""""""""""
set encoding=utf-8
set nocompatible " disable vi compatiable
set autochdir
set showtabline=2
" set noswapfile
" set t_ti= t_te= " leave content when vim exit

""     performance / buffer ---
set hidden      " can put buffer to the background without writing
                "   to disk, will remember history/marks.
set lazyredraw  " don't update the display while executing macros
set updatetime=500
set ttyfast     " Send more characters at a given time.
set switchbuf+=usetab,newtab "use new tab when open through quickfix

""   regexp
set gdefault                " RegExp global by default
set magic                   " Enable extended regexes.

""    Others
set report=0                " Show all changes.
set title                   " Show the filename in the window title bar.
set splitbelow splitright   " how to split new windows.
" Show ^M windows
" :e ++ff=unix


""""    Editor Settings (inside buffer)
""""""""""""""""""""""""""""""""""""""""""""""""""""""
set smartindent " smart indent
" set mps+=<:> "hilighted matched ()
set showmatch " show the matching part of the pair for [] {} and ()
set backspace=indent,eol,start " when press backspace
set undolevels=999  " More undo (default=100)
set linebreak " Avoid wrapping a line in the middle of a word.
set wrap " Enable line wrapping.
" set virtualedit=block " in visal mode can select empty space


" Number
set number  " show line number
" set relativenumber " use relaaive number
" set numberwidth=5           " width of numbers line (default on gvim is 4)

" Search
set ignorecase smartcase " search with ignore case
set incsearch " increamental search
" set hlsearch " hightlight search word

""    Spelling options
" set spelllang=en_us " spell checking
" set spell " Enable spellchecking.

""    file options
" set autowrite " auto save when switch document
" set nobackup  "no backup when overright
" set autoread                " reload files if changed externally
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.o,*.a

""    clipboard options
set clipboard=unnamed " Access system clipboard
set clipboard+=unnamedplus " use systemc clip buffer instead
set history=1000 " Increase the undo limit.

" soft tab
set expandtab " extend tab to 4 space
set tabstop=4 "set tab len to 4
set softtabstop=4 " let tab stop in 4
set shiftround " When shifting lines, round the indentation to the nearest multiple of "shiftwidth.
set shiftwidth=4 " When shifting, indent using four spaces.
set smarttab " Insert tabstop number of spaces when the tab key is pressed.

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
syntax enable " enable syntax hi, cann't be place after theme settings
filetype plugin indent on " base on file type do auto indend

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

set foldmethod=indent " set foldmethod=syntax
set foldnestmax=3 " Only fold up to three nested levels.
set foldlevel=99
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
set t_Co=256 " force terminal use 256 color
set scroll=5 " scroll move for ctrl+u/d
set scrolloff=3 " scroll offset, n line for scroll when in top/buttom line
set sidescrolloff=5 " The number of screen columns to keep to the left and right of the cursor.
set display+=lastline " Always try to show a paragraph’s last line.
set noerrorbells " Disable beep on errors.

" Menu
set wildmenu " Display command line’s tab complete options as a menu.
set completeopt+=menu
set completeopt+=menuone
set completeopt+=longest
" set completeopt+=preview " complete menu use list insdead of window, this will move main window(stable-window may fix)

" Status/Command
set showcmd                 " show partial command on last line of screen.
set cmdheight=1 " Command line height
set ruler   " enable status bar ruler
set laststatus=2 " status bar height
" set statusline=\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ %{&encoding}\ %c:%l/%L%)\ 
set showcmd    " show entered command

" Other settings
" set mouse=
" set mouse=a
" set paste

"" Theme
" theme should be the start of all interface settings
" colorscheme desert

" setup column cursor line, this will slow down vim speed
" set cursorcolumn
" hi cursorcolumn cterm=NONE ctermbg=233

" setup row cursor line
set cursorline
if version >= 802
    set cursorlineopt=number " only line number will be highlighted, dosen't
endif

" split separator
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
autocmd VimLeave * :set mouse=c

""""    Other Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" save debug msg to /tmp/vim-debug
" let g:vim_debug_enable = 1
