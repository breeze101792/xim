""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Autocmd vim env                           """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""

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

" set mouse mode when exit
augroup mouse_gp
    autocmd!
    autocmd VimEnter * :set mouse=c
    " autocmd BufReadPost * :set mouse=c
    autocmd VimLeave * :set mouse=c
augroup END

" automatically open and close the popup menu / preview window
augroup menu_gp
    autocmd!
    autocmd CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
augroup END

"  Auto change relativenumber
" augroup numbertoggle
"   autocmd!
"   autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
"   autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
" augroup END

" Open qf windows on other window
" autocmd FileType qf nnoremap <buffer> <Enter> <C-W><Enter><C-W>T

""""    Highlight Variable
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Highlight KeyWords etc.
augroup syntax_hi_gp
    autocmd!
    " NOTE|TODO|HACK|FIXME|XXX|BUG|IDEA
    autocmd Syntax * call matchadd(
                \ 'Debug',
                \ '\v\W\zs<(NOTE|HACK)>'
                \ )
    autocmd Syntax * call matchadd(
                \ 'Todo',
                \ '\v\W\zs<(BUG|IDEA)>'
                \ )
augroup END
