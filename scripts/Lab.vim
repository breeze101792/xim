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
" augroup bufclosetrack
"   au!
"   autocmd WinLeave * let g:lastWinName = @%
" augroup END
" function! LastWindow()
"   exe "split " . g:lastWinName
" endfunction
" command -nargs=0 LastWindow call LastWindow()
"
