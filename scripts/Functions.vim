" Function Settings
" ===========================================
" -------------------------------------------
"  Mouse_on_off for cursor chage
" -------------------------------------------
let mouse_mode = 0 " 0 = a, 1 = c

func! Mouse_toggle()
    if g:mouse_mode == 0
        let g:mouse_mode = 1
        set mouse=c
    else
        let g:mouse_mode = 0
        set mouse=a
    endif
    return
endfunc

" -------------------------------------------
"  Reverse search function
" -------------------------------------------
function! Back_trace()
    cscope find c <cword>
    " copen
endfunction
command! Bt call Back_trace()
