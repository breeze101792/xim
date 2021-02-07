" Test

if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" -------------------------------------------
"  Test
" -------------------------------------------
function! Test() range
    :'<,'> %s/\s\+$//e
endfunction
command! Test call Test()

" function! SuperTab()
"   let l:part = strpart(getline('.'),col('.')-2,1)
"   if (l:part =~ '^\W\?$')
"       return "\<Tab>"
"   else
"       return "\<C-n>"
"   endif
" endfunction

" imap <Tab> <C-R>=SuperTab()<CR>

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
