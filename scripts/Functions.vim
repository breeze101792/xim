" Function Settings
" ===========================================
" -------------------------------------------
"  Mouse_on_off for cursor chage
" -------------------------------------------
let mouse_mode = 0 " 0 = a, 1 = c

func! Mouse_on_off()
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
function! Csc()
    cscope find c <cword>
    " copen
endfunction
command! Csc call Csc()
" -------------------------------------------
"  Beautify
" -------------------------------------------
function! Beautify()
    " Advance config
    " ===========================================
    " remove the trailing space
    autocmd BufWritePre <buffer> %s/\s\+$//e
    " auto retab
    " autocmd FileType c,cpp,h,py,vim,sh autocmd BufWritePre <buffer> :retab
    " Remove empty lines with space
    autocmd BufWritePre <buffer> :%s/\($\n\s*\)\+\%$//e
    " remove double next line
    autocmd BufWritePre <buffer> :%s/\(\n\n\)\n\+/\1/e

    " autocmd FileType c,cpp setlocal equalprg=clang-format
    
    " auto retab
    " set ff=unix

endfunction
command! Beautify call Beautify()
" -------------------------------------------
"  Test
" -------------------------------------------
function! Test() range
    '<,'> %s/\s\+$//e
endfunction
command! Test call Beautify()
" -------------------------------------------
"  PVupdate
" -------------------------------------------
function! Pvupdate()
    :silent !pvupdate
endfunction
command! Pvupdate call Pvupdate()
