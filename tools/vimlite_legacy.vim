#!/bin/vim
""""    Overview
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Settings
" AutoCmd
" KeyMap
" Function

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""

" COPY Start
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Disable cscope, due to nvim

""""    Basic Config vim env
""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible                 " disable vi compatiable
set shortmess=I                  " Disable screen welcome message, Read :help shortmess for everything else.
set encoding=utf-8
set termencoding=utf-8
set formatoptions+=mM
set fencs=utf-8
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
set redrawtime=1000
"" Command timeout, only affect on mapping command
"" timeout and timeoutlen apply to mappings
set timeout
set timeoutlen=500
set ttimeoutlen=200
"" ttimeout and ttimeoutlen apply to key codes.

""   regexp
" set gdefault                     " RegExp global by default, will add g in the sed
set magic                          " Enable extended regexes.
set regexpengine=1                 " use old reg eng, this may disable some reg syntax


""    Others
set report=0                     " Show all changes.
set title                        " Show the filename in the window title bar.
set splitbelow splitright        " how to split new windows.
" :e ++ff=unix " Show ^M windows

""    Old/Compatiable options
" set re=1 " this force vim use old rex engine


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
" set cscopetag              " set tags=tags
" set nocscopeverbose        " set cscopeverbose

" Folding
set foldmethod=syntax " can be set to syntax, indent, manual
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
" set statusline=\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ %{&encoding}\ %c:%l/%L%)\

" Other settings
" use group to set it
set mouse=c
" set mouse=a
" set paste

" setup column cursor line, this will slow down vim speed
" set cursorcolumn
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

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" COPY End

""""    Lite setting
""""""""""""""""""""""""""""""""""""""""""""""""""""""
colorscheme industry
set noswapfile
syntax on
" FIXME, remove this line
" -------->
set listchars=tab:>-,nbsp:␣,trail:·,precedes:←,extends:→
set hlsearch
" <--------

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    KeyMap
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Patch for disable anoying key mapping
""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap q: <nop>
nnoremap q/ <nop>
map q <nop>

" for quick save and exit
nnoremap <leader>wa :wa<CR>
nnoremap <leader>qa :qa<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>qq :q!<ENTER>
nnoremap <leader>wqa :wqa<CR>
nnoremap qq :q!<ENTER>
nnoremap qa :qa<CR>

" open an shell without close vim
nnoremap <leader>sh :sh<CR>

" select all content
map <C-a> <Esc>ggVG<CR>

" Edit
nmap <S-k> <Esc>dd<Up>p
nnoremap <S-j> <Esc>dd<Down>p
" inseart an line below
nnoremap <leader><CR> o<Esc>

" duplicate current tab
map <leader>d <Esc>:tab split<CR>

" tab manipulation with hjkl
map <C-h> <Esc>:tabprev<CR>
map <C-l> <Esc>:tabnext<CR>
map <S-h> <Esc>:tabmove -1 <CR>
map <S-l> <Esc>:tabmove +1 <CR>

" tab manipulation with arror keys
map <C-Left> <Esc>:tabprev<CR>
map <C-Right> <Esc>:tabnext<CR>
map <S-Left> <Esc>:tabmove -1 <CR>
map <S-Right> <Esc>:tabmove +1 <CR>
map <C-o> <Esc>:tabnew<SPACE>

" Add hilighted word with " or '
nnoremap "" viw<esc>a"<esc>hbi"<esc>wwl
nnoremap '' viw<esc>a'<esc>hbi'<esc>wwl

"" Lite settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" comments
noremap <C-_> :SimpleCommentCode<CR>

" buff list
map <leader>b <Esc>:buffers<CR>
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Auto Groups
""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup file_open_gp
    autocmd!
    " memorize last open line
    autocmd BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif
augroup END

" Call the function after opening a buffer
augroup tab_gp
    autocmd!
    autocmd BufReadPost * call TabsOrSpaces()
augroup END

augroup syntax_hi_gp
    autocmd!
    autocmd Syntax * call matchadd(
                \ 'Debug',
                \ '\v\W\zs<(NOTE|CHANGED|BUG|HACK|TRICKY)>'
                \ )
augroup END
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    UI Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -------------------------------------------
"  Status line override
" -------------------------------------------
function! GetCurrentMode()
    let l:mode = mode()
    let l:mode_name = ''
    if l:mode == 'n'
        let l:mode_name = 'Normal '
    elseif l:mode == 'no'
        let l:mode_name = 'N·Operator Pending '
    elseif l:mode == 'v'
        let l:mode_name = 'Visual '
    elseif l:mode == 'V'
        let l:mode_name = 'V·Line '
    elseif l:mode ==# "\<C-V>"
        let l:mode_name = 'V·Block '
    elseif l:mode == 'i'
        let l:mode_name = 'Insert '
    elseif l:mode == 'R'
        let l:mode_name = 'Replace '
    elseif l:mode == 'Rv'
        let l:mode_name = 'V·Replace '
    elseif l:mode == 'c'
        let l:mode_name = 'Command '
    elseif l:mode == 'ce'
        let l:mode_name = 'Ex '
    else
        let l:mode_name = l:mode
    endif
    return l:mode_name
endfunction
function! GetReadOnly()
    if &readonly || !&modifiable
        return ''
    else
        return ''
endfunction
function! UpdateStatuslineColor()
    let currentmode=GetCurrentMode()
    " exe 'hi! StatusLine ctermbg=008' 
    if (mode() ==# 'i')
        exe 'hi! User1 ctermfg=000 ctermbg=001' 
    elseif (mode() =~# '\v(v|V)' || currentmode ==# 'V·Block' || currentmode ==# 't')
        exe 'hi! User1 ctermfg=000 ctermbg=002' 
    elseif (mode() ==# 'R')
        exe 'hi! User1 ctermfg=000 ctermbg=006' 
    " elseif (mode() =~# '\v(n|no)' || currentmode ==# 'N')
    "     exe 'hi! User1 ctermfg=000 ctermbg=003' 
    else
        exe 'hi! User1 ctermfg=000 ctermbg=003' 
    endif
    return ''
endfunction
" status line %n defined color.
" Color Idx. 0~7 Dark, 9~16 Bright
" Black     : 0
" Red       : 1
" Green     : 2
" Yellow    : 3
" Blue      : 4
" Magenta   : 5
" Cyan      : 6
" White     : 7
hi! StatusLine  ctermfg=000 ctermbg=003
hi User1 ctermfg=000 ctermbg=003
hi User2 ctermfg=007 ctermbg=000
" Right
hi User3 ctermfg=007 ctermbg=236
hi User4 ctermfg=007 ctermbg=240
hi User5 ctermfg=007 ctermbg=008
" Left
hi User7 ctermfg=007 ctermbg=240
hi User8 ctermfg=007 ctermbg=236
hi User9 ctermfg=015 ctermbg=232

set statusline=
set statusline+=%{UpdateStatuslineColor()}               " Changing the statusline color
set statusline+=%1*\ %{toupper(GetCurrentMode())}        " Current mode
set statusline+=%8*\ %<%F\ %{GetReadOnly()}\ %m\ %w\     " File+path
set statusline+=%*
set statusline+=%8*\ %=                                  " Space
" Right
set statusline+=%5*\ %{&filetype}                        " FileType
set statusline+=%5*\ \[%{(&fenc!=''?&fenc:&enc)}\|%{&ff}]\ " Encoding & Fileformat
set statusline+=%1*\ %-2c\ %2l:%2p%%\                   " Col, Rownumber/total (%)

" -------------------------------------------
"  Tabline override
" -------------------------------------------
set tabline=%!MyTabLine()

" Color theme
hi TabLine cterm=None ctermfg=007 ctermbg=240
hi TabLineSel cterm=None ctermfg=000 ctermbg=003
hi TabLineFill cterm=None ctermfg=007 ctermbg=236
hi TabTitle cterm=bold ctermfg=000 ctermbg=014

" Set the entire tabline
function! MyTabLine() " acclamation to avoid conflict
    let s = '' " complete tabline goes here
    " Title
    let s .= '%#TabTitle# VIM '
    " loop through each tab page
    for t in range(tabpagenr('$'))
        " set highlight
        if t + 1 == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif
        " set the tab page number (for mouse clicks)
        let s .= '%' . (t + 1) . 'T'
        let s .= ' '

        " set page number string
        let s .= t + 1 . ' '

        let s .= TabLineLabel(t + 1) . ' '
        " let s .= '%{MyTabLabel(' . (t + 1) . ')} '
    endfor

    " after the last tab fill with TabLineFill and reset tab page nr
    let s .= '%#TabLineFill#%T'
    " right-align the label to close the current tab page
    " if tabpagenr('$') > 1
    "     let s .= '%=%#TabLineFill#%999Xclose'
    " endif
    let s .= '%=%#TabLine# %n '
    return s
endfunction"

" Set the label for a single tab
function! TabLineLabel(n)

    let t = a:n
    let bname = ''
    " get buffer names and statuses
    let tmp_str = ''      " temp string for buffer names while we loop and check buftype
    let modify_cnt = 0       " &modified counter
    let buf_cnt = len(tabpagebuflist(t))     " counter to avoid last ' '
    " loop through each buffer in a tab
    for each_buf_in_tab in tabpagebuflist(t)
        " buffer types: quickfix gets a [Q], help gets [H]{base fname}
        " others get 1dir/2dir/3dir/fname shortened to 1/2/3/fname
        if getbufvar( each_buf_in_tab, "&buftype"  ) == 'help'
            let tmp_str .= '[H]' . fnamemodify( bufname(each_buf_in_tab), ':t:bname/.txt$//'  )
        elseif getbufvar( each_buf_in_tab, "&buftype"  ) == 'quickfix'
            let tmp_str .= '[Q]'
        else
            let tmp_str .= pathshorten(bufname(each_buf_in_tab))
        endif
        " check and ++ tab'bname &modified count
        if getbufvar( each_buf_in_tab, "&modified"  )
            let modify_cnt += 1
        endif
        " no final ' ' added...formatting looks better done later
        if buf_cnt > 1
            let tmp_str .= ' '
        endif
        let buf_cnt -= 1
    endfor
    " select the highlighting for the buffer names
    " my default highlighting only underlines the active tab
    " buffer names.
    if t == tabpagenr()
        let bname .= '%#TabLineSel#'
    else
        let bname .= '%#TabLine#'
    endif
    " add buffer names
    if tmp_str == ''
        let bname.= '[New]'
    else
        let bname .= tmp_str
    endif

    " add modified label [tmp_str+] where tmp_str pages in tab are modified
    if modify_cnt > 0
        " let bname .= ' [' . modify_cnt . '+]'
        let bname .= ' +'
    endif
    return bname
endfunction

" Set the label for a single tab
function! MyTabLabel(n)

    " This is run in the scope of the active tab, so t:name
    " won't work.
    let l:tabname = gettabvar(a:n, 'name', '')

    " This variable exists!
    if l:tabname != ''
        return l:tabname
    endif

    " If it's not found fall back to the buffer name
    let buflist = tabpagebuflist(a:n)
    let winnr = tabpagewinnr(a:n)
    let l:bname = bufname(buflist[winnr - 1])

    " Unnamed buffer, scratch buffer, etc. Could be more detailed.
    if l:bname == ''
        let l:bname = '[No Name]'
    endif

    return l:bname
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Function
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -------------------------------------------
"  Mouse_on_off for cursor chage
" -------------------------------------------
command! Reload call Reload()

function! Reload()
    if !empty(glob($MYVIMRC))
        source $MYVIMRC
    else
        echo 'No RC file found.'. $MYVIMRC
    endif
endfunc

" -------------------------------------------
"  Mouse_on_off for cursor chage
" -------------------------------------------
command! MouseToggle call MouseToggle()

function! MouseToggle()
    if &mouse == 'c'
        set mouse=a
    else
        set mouse=c
    endif
    return
endfunc

" -------------------------------------------
"  Tab op
" -------------------------------------------
function! TabCloseOthers(bang)
    let cur=tabpagenr()
    while cur < tabpagenr('$')
        exe 'tabclose' . a:bang . ' ' . (cur + 1)
    endwhile
    while tabpagenr() > 1
        exe 'tabclose' . a:bang . ' 1'
    endwhile
endfunction

function! TabCloseRight(bang)
    let cur=tabpagenr()
    while cur < tabpagenr('$')
        exe 'tabclose' . a:bang . ' ' . (cur + 1)
    endwhile
endfunction

function! TabCloseLeft(bang)
    while tabpagenr() > 1
        exe 'tabclose' . a:bang . ' 1'
    endwhile
endfunction

command! -bang Tabcloseothers call TabCloseOthers('<bang>')
command! -bang Tabcloseright call TabCloseRight('<bang>')
command! -bang Tabcloseleft call TabCloseLeft('<bang>')
" -------------------------------------------
"  TabsOrSpaces
" -------------------------------------------
function! TabsOrSpaces()
    " Determines whether to use spaces or tabs on the current buffer.
    " if getfsize(bufname("%")) > 256000
    "     " File is very large, just use the default.
    "     setlocal expandtab
    "     return
    " endif

    let numTabs=len(filter(getbufline(bufname("%"), 1, 250), 'v:val =~ "^\\t"'))
    let numSpaces=len(filter(getbufline(bufname("%"), 1, 250), 'v:val =~ "^  "'))
    " echo 'Tabs Or Spaces: '.numTabs.', '.numSpaces

    if numTabs > numSpaces
        setlocal noexpandtab
    else
        setlocal expandtab
    endif
endfunction

" -------------------------------------------
"  SimpleCommenCodet
" -------------------------------------------
command! -range -nargs=? SimpleCommentCode <line1>,<line2>call SimpleCommentCode(<q-args>)
function! SimpleCommentCode(pattern) range
    let b:comment_padding = ' '
    let b:comment_leader = '#'
    if a:pattern != ''
        let b:comment_leader = '#'
    elseif &filetype ==# 'c' || &filetype ==# 'cpp'
        let b:comment_leader = '\/\/'
    elseif &filetype ==# 'sh' || &filetype ==# 'conf' || &filetype ==# 'bash'
        let b:comment_leader = '#'
    elseif &filetype ==# 'python' || &filetype ==# 'ruby'
        let b:comment_leader = '#'
    elseif &filetype ==# 'vim'
        let b:comment_leader = '"'
    endif
    let flag_comment=0
    let match_ret=0

    let b:comment_pattern = b:comment_leader.b:comment_padding
    try
        let match_ret=execute(a:firstline.','.a:lastline.'s/^\s*'.b:comment_leader.'/ /n')

        let token=split(match_ret[1:], ' ')
        if len(token) < 4
            let flag_comment=1
        else
            let pattern_matches=token[0]
            let line_matches=token[3]
            let test=char2nr(pattern_matches[0])

            if a:lastline - a:firstline + 1== pattern_matches
                let flag_comment=0
            else
                let flag_comment=1
            endif
        endif
    catch
        let flag_comment=1
    endtry

    echom "Comment Code: '".b:comment_leader."', comment: ".flag_comment.", cnt:".match_ret
    " Toggle
    if flag_comment == 1
        " Do comment
        call execute(a:firstline.','.a:lastline.'s/^/'.b:comment_pattern.'/g')
    else
        " Do uncomment
        call execute(a:firstline.','.a:lastline.'g/^\s*'.b:comment_leader.'/s/'.b:comment_leader.'[ ]\?//')
    endif

endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Modules
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Map to toggle highlighting
nnoremap <leader>m :call ToggleHighlightWords(expand('<cexpr>'))<CR>

" Map to clear all highlights
" nnoremap <leader>ch :call ClearAllHighlightedWords(expand('<cword>'))<CR>

" Define a function to toggle highlighting of specified words with different colors
function! ToggleHighlightWords(...) abort
  " If no arguments are provided, prompt the user to enter words
  if a:0 == 0
    let l:input = input('Enter words to toggle highlight (separate with spaces): ')
    let l:words = split(l:input)
  else
    " Use the provided arguments as the list of words
    let l:words = a:000
  endif

  " Ensure the global variable for tracking highlighted words exists
  if !exists('g:highlighted_words')
    let g:highlighted_words = {}
  endif

  " Define a list of color schemes
  let l:color_list = [
        \ ['White', 'Red',    '#ffffff', '#ff0000'],
        \ ['Black', 'Yellow', '#000000', '#ffff00'],
        \ ['White', 'Blue',   '#ffffff', '#0000ff'],
        \ ['Black', 'Green',  '#000000', '#00ff00'],
        \ ['White', 'Magenta','#ffffff', '#ff00ff'],
        \ ['Black', 'Cyan',   '#000000', '#00ffff'],
        \ ['White', 'Black',  '#ffffff', '#000000'],
        \ ['Black', 'White',  '#000000', '#ffffff'],
        \ ]
  " let l:color_list = [['White', 'Red',    '#ffffff', '#ff0000']]

  " Initialize color index
  let l:color_index = len(g:highlighted_words) % len(color_list)

  " Iterate over each word to toggle its highlight
  for l:word in l:words
    " Generate a unique highlight group name based on the word
    let l:group_name = 'UserHL_' . substitute(l:word, '\W', '_', 'g')

    " Check if the highlight group already exists
    if has_key(g:highlighted_words, l:group_name)
      " If it exists, remove the highlight
      execute 'syntax clear ' . l:group_name
      execute 'highlight clear ' . l:group_name
      " Remove the entry from the tracking list
      call remove(g:highlighted_words, l:group_name)
      echo 'Removed highlight for "' . l:word . '".'
    else
      " If it does not exist, add the highlight
      " Get the color scheme for the current word
      let l:ctermfg = l:color_list[l:color_index][0]
      let l:ctermbg = l:color_list[l:color_index][1]
      let l:guifg   = l:color_list[l:color_index][2]
      let l:guibg   = l:color_list[l:color_index][3]

      " Increment color index and wrap around if necessary
      let l:color_index = (l:color_index + 1) % len(l:color_list)

      " Define the highlight group style
      execute 'highlight ' . l:group_name .
            \ ' ctermfg=' . l:ctermfg .
            \ ' ctermbg=' . l:ctermbg .
            \ ' guifg='   . l:guifg .
            \ ' guibg='   . l:guibg .
            \ ' cterm=bold gui=bold'

      " Define the syntax match to highlight the whole word, case-sensitive
      execute 'syntax match ' . l:group_name . ' /\<'. escape(l:word, '/\') . '\>/ containedin=ALL'
      " execute 'syntax match ' . l:group_name . ' /\V' . escape(l:word, '/\') . '/ containedin=ALL'

      " Add the highlight group to the tracking list
      let g:highlighted_words[l:group_name] = l:word
      " echo 'Added highlight for "' . l:word . '".'
    endif
  endfor
endfunction

" Define a function to clear all highlighted words
function! ClearAllHighlightedWords() abort
  if exists('g:highlighted_words')
    for l:group_name in keys(g:highlighted_words)
      " Remove syntax and highlight settings for each group
      execute 'syntax clear ' . l:group_name
      execute 'highlight clear ' . l:group_name
    endfor
    unlet g:highlighted_words
    echo 'All highlights cleared.'
  else
    echo 'No highlights to clear.'
  endif
endfunction
