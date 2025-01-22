""""""""""""""""""""""""""""""""""""""""""""""""""""""
" This file is auto generated, do not modify it.
""""""""""""""""""""""""""""""""""""""""""""""""""""""

"------------------------------------------------------
"" Import from Environment.vim
"------------------------------------------------------
if !exists("g:IDE_ENV_INS")
    if has("nvim")
        let g:IDE_ENV_INS = "nvim"
    else
        let g:IDE_ENV_INS = "vim"
    endif
endif
if !exists("g:IDE_ENV_OS")
    if has("macunix")
        let g:IDE_ENV_OS = "Darwin"
    elseif has("unix")
        let g:IDE_ENV_OS = "Linux"
    elseif has("win64") || has("win32") || has("win16")
        let g:IDE_ENV_OS = "Windows"
    else
        let g:IDE_ENV_OS = "Linux"
    endif
endif
let g:IDE_ENV_IDE_TITLE = get(g:, 'IDE_ENV_IDE_TITLE', "VIM")
let g:IDE_ENV_HEART_BEAT = get(g:, 'IDE_ENV_HEART_BEAT', 30000)
let g:IDE_ENV_CACHED_COLORSCHEME = get(g:, 'IDE_ENV_CACHED_COLORSCHEME', "autogen")
if g:IDE_ENV_INS == "nvim"
    let g:IDE_ENV_ROOT_PATH = get(g:, 'IDE_ENV_ROOT_PATH', $HOME."/.config/nvim")
else
    let g:IDE_ENV_ROOT_PATH = get(g:, 'IDE_ENV_ROOT_PATH', $HOME."/.vim")
endif
let g:IDE_ENV_CSCOPE_EXC = get(g:, 'IDE_ENV_CSCOPE_EXC', "cscope")
let g:IDE_ENV_CONFIG_PATH = get(g:, 'IDE_ENV_CONFIG_PATH', $HOME."/.vim")
let g:IDE_ENV_CLIP_PATH = get(g:, 'IDE_ENV_CLIP_PATH', g:IDE_ENV_CONFIG_PATH."/clip")
let g:IDE_ENV_PROJ_DATA_PATH = get(g:, 'IDE_ENV_PROJ_DATA_PATH', "./")
let g:IDE_ENV_PROJ_SCRIPT = get(g:, 'IDE_ENV_PROJ_SCRIPT', "")
let g:IDE_ENV_TAGS_DB = get(g:, 'IDE_ENV_TAGS_DB', "")
let g:IDE_ENV_CSCOPE_DB = get(g:, 'IDE_ENV_CSCOPE_DB', "")
let g:IDE_ENV_CCTREE_DB = get(g:, 'IDE_ENV_CCTREE_DB', "")
let g:IDE_ENV_SESSION_AUTOSAVE_PATH = get(g:, 'IDE_ENV_SESSION_AUTOSAVE_PATH', g:IDE_ENV_CONFIG_PATH."/session_autosave")
let g:IDE_ENV_SESSION_PATH = get(g:, 'IDE_ENV_SESSION_PATH', g:IDE_ENV_CONFIG_PATH."/session")
let g:IDE_ENV_REQ_TAG_UPDATE=0
let g:IDE_ENV_REQ_SESSION_RESTORE=""
let g:IDE_ENV_DEF_PAGE_WIDTH=80
let g:IDE_ENV_DEF_FILE_SIZE_THRESHOLD=100 * 1000 * 1000
"------------------------------------------------------
"" Import from Settings.vim
"------------------------------------------------------
set nocompatible                 " disable vi compatiable
set shortmess=I                  " Disable screen welcome message, Read :help shortmess for everything else.
set encoding=utf-8
set termencoding=utf-8
set formatoptions+=mM
set fileencodings=utf-8
if exists('&autochdir') 
    set autochdir
endif
set showtabline=2
set hidden                       " can put buffer to the background without writing
set lazyredraw                   " don't update the display while executing macros
set updatetime=500               " how long wil vim wait after your interaction to start plugins/other event
set ttyfast                      " Send more characters at a given time.
set redrawtime=1000
set timeout
set timeoutlen=500
set ttimeoutlen=200
set report=0                     " Show all changes.
set smartindent                                   " smart indent
set showmatch                                     " show the matching part of the pair for [] {} and ()
set backspace=indent,eol,start                    " when press backspace
set undolevels=999                                " More undo (default=100)
set linebreak                                     " Avoid wrapping a line in the middle of a word.
set title                        " Show the filename in the window title bar.
set splitbelow splitright        " how to split new windows.
set number                                        " show line number
set ignorecase smartcase                          " search with ignore case
set incsearch                                     " increamental search
exec "set directory=" . get(g:, 'IDE_ENV_CONFIG_PATH', '~/.vim') . "/swp/"
set clipboard=unnamed                             " Access system clipboard
set clipboard+=unnamedplus                        " use systemc clip buffer instead
set history=1000                                  " Increase the undo limit.
set expandtab                                     " extend tab (soft tab)
set tabstop=4                                     " set tab len to 4
set softtabstop=4                                 " let tab stop in 4
set shiftround                                    " When shifting lines, round the indentation to the nearest multiple of  " shiftwidth.
set shiftwidth=4                                  " When shifting, indent using four spaces.
set smarttab                                      " Insert tabstop number of spaces when the tab key is pressed.
if get(g:, 'IDE_CFG_SPECIAL_CHARS', "n") == "y"
    set showbreak=↪\
    set listchars=tab:▸-,nbsp:␣,trail:·,precedes:←,extends:→
else
    set showbreak=->\
    set listchars=tab:>-,trail:~,extends:>,precedes:<
endif
set list
if exists('&nofixendofline') 
    set nofixendofline " enable this will cause vim add new line at the end of line
endif
syntax sync maxlines=50
if has('cscope')
    set cscopetag              " set tags=tags
    set nocscopeverbose        " set cscopeverbose
endif
set foldnestmax=10    " Only fold up to three nested levels.
set foldlevel=99
set nofoldenable
set t_Co=256                " force terminal use 256 color
set scroll=5                " scroll move for ctrl+u/d
set scrolloff=3             " scroll offset, n line for scroll when in top/buttom line
set sidescrolloff=5         " The number of screen columns to keep to the left and right of the cursor.
set display+=lastline       " Always try to show a paragraph’s last line.
set noerrorbells            " Disable beep on errors.
set wildmenu                " Display command line’s tab complete options as a menu.
set completeopt+=menu
set completeopt+=menuone
set completeopt+=longest
set wildignore+=*.so,*.swp,*.zip,*.o,*.a,*.d,*.img,*.tar.*
set showcmd      " show partial command on last line of screen.
set laststatus=2 " status bar always show
set cmdheight=1  " Command line height
set shortmess=aO " option to avoid hit enter, a for all, O for overwrite when reading file
set ruler        " enable status bar ruler
set mouse=c
if get(g:, 'IDE_CFG_HIGH_PERFORMANCE_HOST', 'n') == 'y'
    set cursorcolumn
endif
if exists('&colorcolumn') 
    set colorcolumn=81
endif
set cursorline
if exists('&cursorlineopt') 
    set cursorlineopt=number " only line number will be highlighted, dosen't
endif
if get(g:, 'IDE_CFG_SPECIAL_CHARS', "n") == "y"
    set fillchars+=vert:│
else
    set fillchars+=vert:\|
endif
set t_SI="\e[6 q"
set t_EI="\e[2 q"
set t_SR="\e[4 q"
let g:matchparen_timeout = 60
let g:matchparen_insert_timeout = 60
if 0
    let g:vim_debug_enable = 1
    Check syntax time
    syntime on
    syntime report
endif
"------------------------------------------------------
"" Import from KeyMaps.vim
"------------------------------------------------------
nnoremap q: <nop>
nnoremap q/ <nop>
map q <nop>
nnoremap <leader>wqa :wqa<CR>
nnoremap <leader>wa :wa<CR>
nnoremap <leader>qq :q!<CR>
nnoremap <leader>qa :qa<CR>
nnoremap <leader>qe :exit()<CR>
nnoremap qq :q!<CR>
nnoremap qa :qa<CR>
nnoremap <leader>sh :tab terminal<CR>
map <C-a> <Esc>ggVG<CR>
map <leader>a <Esc>ggVG<CR>
nnoremap <S-k> <Esc>dd<Up>P
nnoremap <S-j> <Esc>dd<Down>P
nnoremap <leader><CR> o<Esc>
map <leader>d <Esc>:tab split<CR>
map <C-h> <Esc>:tabprev<CR>
map <C-l> <Esc>:tabnext<CR>
map <S-h> <Esc>:tabmove -1 <CR>
map <S-l> <Esc>:tabmove +1 <CR>
map <C-Left> <Esc>:tabprev<CR>
map <C-Right> <Esc>:tabnext<CR>
map <S-Left> <Esc>:tabmove -1 <CR>
map <S-Right> <Esc>:tabmove +1 <CR>
map <C-o> <Esc>:tabnew<SPACE>
nnoremap "" viw<esc>a"<esc>hbi"<esc>wwl
nnoremap '' viw<esc>a'<esc>hbi'<esc>wwl
nnoremap <C-W>M <C-W>\| <C-W>_
nnoremap <C-W>m <C-W>=
nnoremap <silent> <Leader>l ml:execute 'match Search /\%'.line('.').'l/'<CR>
nnoremap <silent> <Leader>v :execute 'match Search /\%'.virtcol('.').'v/'<CR>
"------------------------------------------------------
"" Import from Autocmd.vim
"------------------------------------------------------
augroup mouse_gp
    autocmd!
    autocmd VimEnter * :set mouse=c
    autocmd VimLeave * :set mouse=c
augroup END
augroup menu_gp
    autocmd!
    autocmd CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
augroup END
augroup syntax_hi_gp
    autocmd!
    autocmd Syntax * call matchadd(
                \ 'Debug',
                \ '\v\W\zs<(NOTE|HACK)>'
                \ )
    autocmd Syntax * call matchadd(
                \ 'Todo',
                \ '\v\W\zs<(BUG)>'
                \ )
augroup END
"------------------------------------------------------
"" Import from Tools.vim
"------------------------------------------------------
command! MouseToggle call MouseToggle()
function! MouseToggle()
    if &mouse == 'c'
        set mouse=a
    else
        set mouse=c
    endif
    return
endfunc
command! LineNumToggle call LineNumToggle()
function! LineNumToggle()
    if &relativenumber
        set norelativenumber
    else
        set relativenumber
    endif
    return
endfunc
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
    if flag_comment == 1
        call execute(a:firstline.','.a:lastline.'s/^/'.b:comment_pattern.'/g')
    else
        call execute(a:firstline.','.a:lastline.'g/^\s*'.b:comment_leader.'/s/'.b:comment_leader.'[ ]\?//')
    endif
endfunction
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
"------------------------------------------------------
"" Import from lite.vim
"------------------------------------------------------
let g:IDE_ENV_OS = "Linux"
let g:IDE_ENV_INS = "vim"
let g:IDE_ENV_IDE_TITLE = "LITE"
try
    colorscheme industry
    syntax on
endtry
set listchars=tab:>-,trail:~,extends:>,precedes:<
set noswapfile
if exists('&colorcolumn') 
    set colorcolumn=""
endif
noremap <C-_> :SimpleCommentCode<CR>
map <leader>b <Esc>:buffers<CR>
nnoremap <leader>m :call HighlightWordsToggle(expand('<cword>'))<CR>
if has("nvim")
    cnoremap <expr> <up> wildmenumode() ? "\<left>" : "\<up>"
    cnoremap <expr> <down> wildmenumode() ? "\<right>" : "\<down>"
endif
function! TabsOrSpaces()
    let numTabs=len(filter(getbufline(bufname("%"), 1, 250), 'v:val =~ "^\\t"'))
    let numSpaces=len(filter(getbufline(bufname("%"), 1, 250), 'v:val =~ "^  "'))
    if numTabs > numSpaces
        setlocal noexpandtab
    else
        setlocal expandtab
    endif
endfunction
if !exists("Reload")
    command! Reload call Reload()
    function! Reload()
        if !empty(glob($MYVIMRC))
            source $MYVIMRC
            echo 'Lite reloaded.'
        else
            echo 'No RC file found.'. $MYVIMRC
        endif
    endfunc
end
command! PureToggle call PureToggle()
function! PureToggle()
    if &paste
        echo 'Disable Pure mode'
        setlocal nopaste
        setlocal number
        setlocal list
    else
        echo 'Enable Pure mode'
        setlocal paste
        setlocal nonumber
        setlocal nolist
    endif
endfunc
"------------------------------------------------------
"" Import from StatusLine.vim
"------------------------------------------------------
function! StatusLineGetCurrentMode()
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
function! StatusLineUpdateColor()
    let currentmode=StatusLineGetCurrentMode()
    if (mode() ==# 'i')
        exe 'hi! User1 ctermfg=000 ctermbg=001' 
    elseif (mode() =~# '\v(v|V)' || currentmode ==# 'V·Block')
        exe 'hi! User1 ctermfg=000 ctermbg=002' 
    elseif (mode() ==# 'R')
        exe 'hi! User1 ctermfg=000 ctermbg=006' 
    else
        exe 'hi! User1 ctermfg=000 ctermbg=003' 
    endif
    return ''
endfunction
function! StatusLineGetReadOnly()
    if &readonly || !&modifiable
        return ''
    else
        return ''
endfunction
function! StatusLineGetFilePositon()
    return printf('%.2f%%', ( 100.0 * line('.') / line('$') ))
endfunction
hi! StatusLine  ctermfg=000 ctermbg=003
hi User1 ctermfg=000 ctermbg=003
hi User2 ctermfg=007 ctermbg=000
hi User3 ctermfg=007 ctermbg=236
hi User4 ctermfg=007 ctermbg=240
hi User5 ctermfg=007 ctermbg=008
hi User7 ctermfg=007 ctermbg=240
hi User8 ctermfg=007 ctermbg=236
hi User9 ctermfg=015 ctermbg=232
set statusline=
set statusline+=%{StatusLineUpdateColor()}                 " Changing the statusline color
set statusline+=%1*\ %{toupper(StatusLineGetCurrentMode())}          " Current mode
set statusline+=%8*\ %<%F\ %{StatusLineGetReadOnly()}\ %m\ %w\       " File+path
set statusline+=%*
set statusline+=%8*\ %=                                    " Space
set statusline+=%5*\ %{(&filetype!=''?&filetype:'None')}   " FileType
set statusline+=%5*\ \[%{(&fenc!=''?&fenc:&enc)}\|%{&ff}]\ " Encoding & Fileformat
set statusline+=%1*\ %2l:%-2c\ %{StatusLineGetFilePositon()}\                     " Col, Rownumber/total (%)
set tabline=%!TabLineCompose()
hi TabLine cterm=None ctermfg=007 ctermbg=240
hi TabLineSel cterm=None ctermfg=000 ctermbg=003
hi TabLineFill cterm=None ctermfg=007 ctermbg=236
hi TabTitle cterm=bold ctermfg=000 ctermbg=014
function! TabLineCompose() " acclamation to avoid conflict
    let s = '' " complete tabline goes here
    let title = get(g:, 'IDE_ENV_IDE_TITLE', "VIM")
    let s .= '%#TabTitle# ' . title . ' '
    for t in range(tabpagenr('$'))
        if t + 1 == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif
        let s .= '%' . (t + 1) . 'T'
        let s .= ' '
        let s .= t + 1 . ' '
        let s .= TabLineLabel(t + 1) . ' '
    endfor
    let s .= '%#TabLineFill#%T'
    let s .= '%=%#TabLine# %n '
    return s
endfunction"
function! TabLineLabel(n)
    let t = a:n
    let bname = ''
    let tmp_str = ''      " temp string for buffer names while we loop and check buftype
    let modify_cnt = 0       " &modified counter
    let buf_cnt = len(tabpagebuflist(t))     " counter to avoid last ' '
    for each_buf_in_tab in tabpagebuflist(t)
        if getbufvar( each_buf_in_tab, "&buftype"  ) == 'help'
            let tmp_str .= '[H]' . fnamemodify( bufname(each_buf_in_tab), ':t:bname/.txt$//'  )
        elseif getbufvar( each_buf_in_tab, "&buftype"  ) == 'quickfix'
            let tmp_str .= '[Q]'
        else
            let tmp_str .= pathshorten(bufname(each_buf_in_tab))
        endif
        if getbufvar( each_buf_in_tab, "&modified"  )
            let modify_cnt += 1
        endif
        if buf_cnt > 1
            let tmp_str .= ' '
        endif
        let buf_cnt -= 1
    endfor
    if t == tabpagenr()
        let bname .= '%#TabLineSel#'
    else
        let bname .= '%#TabLine#'
    endif
    if tmp_str == ''
        let bname.= '[New]'
    else
        let bname .= tmp_str
    endif
    if modify_cnt > 0
        let bname .= ' +'
    endif
    return bname
endfunction
"------------------------------------------------------
"" Import from HighlightWord.vim
"------------------------------------------------------
nnoremap <leader>th :call HighlightWordsToggle(expand('<cword>'))<CR>
nnoremap <leader>ch :call HighlightedAllWordsToggle()<CR>
command! -nargs=1 HighlightWordsToggle call HighlightWordsToggle(<q-args>)
command! HighlightedAllWordsToggle call HighlightedAllWordsToggle()
let g:highlighted_words = {}
function! HighlightWordsToggle(...) abort
  if a:0 == 0
    let l:input = input('Enter words to toggle highlight (separate with spaces): ')
    let l:words = split(l:input)
  else
    let l:words = a:000
  endif
  if !exists('g:highlighted_words')
    let g:highlighted_words = {}
  endif
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
  let l:color_index = len(g:highlighted_words) % len(color_list)
  for l:word in l:words
    let l:group_name = 'UserHL_' . substitute(l:word, '\W', '_', 'g')
    if has_key(g:highlighted_words, l:group_name)
      execute 'syntax clear ' . l:group_name
      execute 'highlight clear ' . l:group_name
      call remove(g:highlighted_words, l:group_name)
      echo 'Removed highlight for "' . l:word . '".'
    else
      let l:ctermfg = l:color_list[l:color_index][0]
      let l:ctermbg = l:color_list[l:color_index][1]
      let l:guifg   = l:color_list[l:color_index][2]
      let l:guibg   = l:color_list[l:color_index][3]
      let l:color_index = (l:color_index + 1) % len(l:color_list)
      execute 'highlight ' . l:group_name .
            \ ' ctermfg=' . l:ctermfg .
            \ ' ctermbg=' . l:ctermbg .
            \ ' guifg='   . l:guifg .
            \ ' guibg='   . l:guibg .
            \ ' cterm=bold gui=bold'
      execute 'syntax match ' . l:group_name . ' /\V' . escape(l:word, '/\') . '/ containedin=ALL'
      let g:highlighted_words[l:group_name] = l:word
      echo 'Added highlight for "' . l:word . '".'
    endif
  endfor
endfunction
function! HighlightedAllWordsToggle() abort
  if exists('g:highlighted_words')
    for l:group_name in keys(g:highlighted_words)
      execute 'syntax clear ' . l:group_name
      execute 'highlight clear ' . l:group_name
    endfor
    unlet g:highlighted_words
    echo 'All highlights cleared.'
  else
    echo 'No highlights to clear.'
  endif
endfunction
"------------------------------------------------------
"" Import from Bookmark.vim
"------------------------------------------------------
nnoremap mt :call MarkingToggle()<CR>
nnoremap mp :call MarkJumpToPrev()<CR>
nnoremap mn :call MarkJumpToNext()<CR>
nnoremap mm :call MarkToggleLine()<CR>
nnoremap ml :call MarkJumpToMarkList()<CR>
command! MarkingToggle call MarkingToggle()
command! MarkJumpToMarkList call MarkJumpToMarkList()
let g:bookmark_marking_enabled = 1
let g:bookmark_marked_lines = {}
let g:bookmark_center_jumped_line = 0
highlight MarkedLine cterm=bold ctermbg=DarkGrey gui=bold guibg=DarkGrey
function! MarkingToggle()
    if g:bookmark_marking_enabled
        let g:bookmark_marking_enabled = 0
        echo "Marking functionality disabled."
        call ClearAllMarks()
    else
        let g:bookmark_marking_enabled = 1
        echo "Marking functionality enabled."
    endif
endfunction
function! MarkLine()
    if !g:bookmark_marking_enabled
        echo "Please enable marking functionality first."
        return
    endif
    let l:lnum = line('.')
    if !has_key(g:bookmark_marked_lines, l:lnum)
        let l:matchid = matchadd('MarkedLine', '\%' . l:lnum . 'l')
        let g:bookmark_marked_lines[l:lnum] = l:matchid
        echo "Marked line " . l:lnum . "."
    else
        echo "Line " . l:lnum . " is already marked."
    endif
endfunction
function! UnmarkLine()
    let l:lnum = line('.')
    if has_key(g:bookmark_marked_lines, l:lnum)
        let l:matchid = g:bookmark_marked_lines[l:lnum]
        call matchdelete(l:matchid)
        call remove(g:bookmark_marked_lines, l:lnum)
        echo "Unmarked line " . l:lnum . "."
    else
        echo "Line " . l:lnum . " is not marked."
    endif
endfunction
function! MarkToggleLine()
    if !g:bookmark_marking_enabled
        echo "Please enable marking functionality first."
        return
    endif
    let l:lnum = line('.')
    if has_key(g:bookmark_marked_lines, l:lnum)
        call UnmarkLine()
    else
        call MarkLine()
    endif
endfunction
function! ClearAllMarks()
    for l:lnum in keys(g:bookmark_marked_lines)
        let l:matchid = g:bookmark_marked_lines[l:lnum]
        call matchdelete(l:matchid)
    endfor
    let g:bookmark_marked_lines = {}
endfunction
function! MarkJumpToMarkList()
    if empty(keys(g:bookmark_marked_lines))
        echo "No marked lines."
        return
    endif
    let l:marked_lnums = sort(map(keys(g:bookmark_marked_lines), 'str2nr(v:val)'))
    let l:choices = []
    for l:lnum in l:marked_lnums
        let l:line_text = getline(l:lnum)
        call add(l:choices, l:lnum . ': ' . substitute(l:line_text, '^\s*', '', ''))
    endfor
    let l:choice = inputlist(['Select a line to jump to:'] + l:choices)
    if l:choice > 0 && l:choice <= len(l:marked_lnums)
        execute l:marked_lnums[l:choice - 1]
        if g:bookmark_center_jumped_line == 1
            normal! zz " Center the jumped line
        endif
    else
        echo "Invalid choice."
    endif
endfunction
function! MarkJumpToPrev()
    if empty(keys(g:bookmark_marked_lines))
        echo "No marked lines."
        return
    endif
    let l:current_line = line('.')
    let l:marked_lnums = sort(map(keys(g:bookmark_marked_lines), 'str2nr(v:val)'))
    let l:prev_marks = filter(copy(l:marked_lnums), 'v:val < l:current_line')
    if !empty(l:prev_marks)
        let l:target_line = l:prev_marks[-1]
        execute l:target_line
        if g:bookmark_center_jumped_line == 1
            normal! zz " Center the jumped line
        endif
        echo "Jumped to previous marked line " . l:target_line . "."
    else
        echo "No previous marked line."
    endif
endfunction
function! MarkJumpToNext()
    if empty(keys(g:bookmark_marked_lines))
        echo "No marked lines."
        return
    endif
    let l:current_line = line('.')
    let l:marked_lnums = sort(map(keys(g:bookmark_marked_lines), 'str2nr(v:val)'))
    let l:next_marks = filter(copy(l:marked_lnums), 'v:val > l:current_line')
    if !empty(l:next_marks)
        let l:target_line = l:next_marks[0]
        execute l:target_line
        if g:bookmark_center_jumped_line == 1
            normal! zz " Center the jumped line
        endif
        echo "Jumped to next marked line " . l:target_line . "."
    else
        echo "No next marked line."
    endif
endfunction
"------------------------------------------------------
"" End of Importing.
"------------------------------------------------------
