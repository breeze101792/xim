""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Autocmd vim env                           """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""    Auto function
""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! IDE_PostInit(timer) abort
    call IDE_EnvSetup()
    if g:IDE_CFG_PLUGIN_ENABLE == "y"
        call IDE_PlugInDealyLoading()
    endif
    " echo 'Post Init finished'
endfunction

augroup init_gp
    autocmd!
    if version >= 800
        " Call loadPlug after 500ms
        " all init shuld be done after vim enter 100ms
        autocmd VIMEnter * call timer_start(100, 'IDE_PostInit')
    else
        autocmd VIMEnter * call IDE_PostInit(0)
    endif
augroup END

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
augroup file_open_gp
    autocmd!
    " memorize last open line
    autocmd BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif
augroup END

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

""""    Env Variable
""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup environment_gp
    autocmd!
    autocmd CursorHold * :call IDE_UpdateEnv_CursorHold()
    " bufread will have issue on the new file(don't need to read buffer)
    " bufenter will have issue on vimdiff, sice only one window we be entered.
    autocmd BufEnter * :call IDE_UpdateEnv_BufOpen()
augroup END

""""    Edictor Variable
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Call the function after opening a buffer
augroup tab_gp
    autocmd!
    autocmd BufReadPost * call TabsOrSpaces()
augroup END

augroup filetype_gp
    autocmd!
    au BufRead,BufNewFile *.log set filetype=log
augroup END

""""    Plugins cmd
""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup plugin_gp
    autocmd!
    autocmd FileType nerdtree setlocal nocursorline

    "" vim-comment
    autocmd FileType gitcommit setlocal commentstring=#\ %s
    autocmd FileType c,cpp,hxx,hpp,cxx,verilog setlocal commentstring=//\ %s

    "" tagbar
    " cursor line will slow down tagbar
    autocmd FileType tagbar setlocal nocursorline
augroup END

