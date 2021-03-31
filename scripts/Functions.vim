" Function Settings
" ===========================================
" -------------------------------------------
"  Mouse_on_off for cursor chage
" -------------------------------------------
let mouse_mode = 0 " 0 = a, 1 = c

func! MouseToggle()
    if g:mouse_mode == 0
        let g:mouse_mode = 1
        set mouse=c
    else
        let g:mouse_mode = 0
        set mouse=a
    endif
    return
endfunc
command! MouseToggle call MouseToggle()

" -------------------------------------------
"  Reverse search function
" -------------------------------------------
function! BackTrace()
    cscope find c <cword>
    " copen
endfunction
command! BackTrace call BackTrace()

" -------------------------------------------
"  Toggle Debug message
" -------------------------------------------
function! DebugToggle()
    if !&verbose
        set verbosefile=~/.vim/verbose.log
        set verbose=15
    else
        set verbose=0
        set verbosefile=
    endif
endfunction
command! DebugToggle call DebugToggle()
