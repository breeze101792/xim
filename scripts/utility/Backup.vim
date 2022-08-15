" Test
" if exists('$TMUX')
"     let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
"     let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
" else
"     let &t_SI = "\<Esc>]50;CursorShape=1\x7"
"     let &t_EI = "\<Esc>]50;CursorShape=0\x7"
" endif
" -------------------------------------------
"  Session test
" -------------------------------------------
function! MakeSession(overwrite)
    let b:sessiondir = $HOME . "/.vim/sessions" . getcwd()
    if (filewritable(b:sessiondir) != 2)
        exe 'silent !mkdir -p ' b:sessiondir
        redraw!
    endif
    let b:filename = b:sessiondir . '/session.vim'
    if a:overwrite == 0 && !empty(glob(b:filename))
        return
    endif
    exe "mksession! " . b:filename
endfunction

function! LoadSession()
    let b:sessiondir = $HOME . "/.vim/sessions" . getcwd()
    let b:sessionfile = b:sessiondir . "/session.vim"
    if (filereadable(b:sessionfile))
        exe 'source ' b:sessionfile
    else
        echo "No session loaded."
    endif
endfunction

" " Adding automatons for when entering or leaving Vim
" if(argc() == 0)
"     au VimEnter * nested :call LoadSession()
"     au VimLeave * :call MakeSession(1)
" else
"     au VimLeave * :call MakeSession(0)
" endif

" -------------------------------------------
"  Reopen test
" -------------------------------------------
 augroup bufclosetrack
   au!
   autocmd WinLeave * let g:lastWinName = @%
 augroup END
 function! LastWindow()
   exe "split " . g:lastWinName
 endfunction
 command -nargs=0 LastWindow call LastWindow()



" -------------------------------------------
"  Tabline override
" -------------------------------------------
set tabline=%!MyTabLine()

" Set the entire tabline
function! MyTabLine()
    echo 'test'
    let s = ''
    for i in range(tabpagenr('$'))
        " select the highlighting
        if i + 1 == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif

        " set the tab page number (for mouse clicks)
        let s .= '%' . (i + 1) . 'T'

        " the label is made by MyTabLabel()
        let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
    endfor

    " after the last tab fill with TabLineFill and reset tab page nr
    let s .= '%#TabLineFill#%T'

    " right-align the label to close the current tab page
    if tabpagenr('$') > 1
        let s .= '%=%#TabLine#%999Xclose'
    endif

    return s
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

" -------------------------------------------
"  Visual mode test
" -------------------------------------------
function! CursorLineNrColorVisual()
    echo "test"
    return ''   " Return nothing to make the map-expr a no-op.
endfunction
vnoremap <expr> <SID>CursorLineNrColorVisual CursorLineNrColorVisual()
nnoremap <script> v v<SID>CursorLineNrColorVisual
nnoremap <script> V V<SID>CursorLineNrColorVisual
nnoremap <script> <C-v> <C-v><SID>CursorLineNrColorVisual

" Colorize line numbers in insert and visual modes
" ------------------------------------------------
function! SetCursorLineNrColorInsert(mode)
    " Insert mode: blue
    if a:mode == "i"
        highlight CursorLineNr ctermfg=4 guifg=#268bd2

    " Replace mode: red
    elseif a:mode == "r"
        highlight CursorLineNr ctermfg=1 guifg=#dc322f

    endif
endfunction


function! SetCursorLineNrColorVisual()
    set updatetime=0

    " Visual mode: orange
    highlight CursorLineNr cterm=none ctermfg=9 guifg=#cb4b16
endfunction


function! ResetCursorLineNrColor()
    set updatetime=4000
    highlight CursorLineNr cterm=none ctermfg=0 guifg=#073642
endfunction


vnoremap <silent> <expr> <SID>SetCursorLineNrColorVisual SetCursorLineNrColorVisual()
nnoremap <silent> <script> v v<SID>SetCursorLineNrColorVisual
nnoremap <silent> <script> V V<SID>SetCursorLineNrColorVisual

" -------------------------------------------
"  Mylog
" -------------------------------------------
function! Mylog(message, file)
  new
  setlocal buftype=nofile bufhidden=hide noswapfile nobuflisted
  put=a:message
  execute 'w >>' a:file
  q
endfun
