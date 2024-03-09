""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Autocmd vim env                           """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""    Worker Checker function
""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! W_TagUpdate()
    if g:IDE_ENV_PROJ_DATA_PATH != "" && g:IDE_ENV_REQ_TAG_UPDATE == 1
        " g:IDE_ENV_REQ_TAG_UPDATE
        " 0: Can be request to update
        " 1: Request to update
        " 2: Doing update, will ignore all request
        call PvUpdate()
    endif
endfunc

""""    Auto function
""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! IDE_PostInit(timer) abort
    call IDE_EnvSetup()
    if g:IDE_CFG_PLUGIN_ENABLE == "y"
        call IDE_PlugInDealyLoading()
    endif
    " echo 'Post Init finished'
endfunction

function! IDE_Worker(timer) abort
    " echo 'VIM Worker Heart Beat'
    if g:IDE_CFG_AUTO_TAG_UPDATE == "y"
        call W_TagUpdate()
    endif

    " Next Heart Beat
    call timer_start(g:IDE_ENV_HEART_BEAT, 'IDE_Worker')
endfunction

augroup init_gp
    autocmd!
    if version >= 800
        " Call loadPlug after 500ms
        " all init should be done after vim enter 100ms
        autocmd VIMEnter * call timer_start(100, 'IDE_PostInit')
        if g:IDE_CFG_BACKGROUND_WORKER == 'y'
            autocmd VIMEnter * call timer_start(g:IDE_ENV_HEART_BEAT, 'IDE_Worker')
        endif
    else
        autocmd VIMEnter * call IDE_PostInit(0)
    endif
augroup END

autocmd FileType c,cpp,h,py,vim,sh,mk autocmd BufWritePre <buffer> %s/\s\+$//e
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

augroup file_write_gp
    autocmd!
    autocmd FileType c,cc,c++,cxx,cpp,h,hh,h++,hxx,hpp autocmd BufWritePost * if g:IDE_ENV_REQ_TAG_UPDATE == 0|let g:IDE_ENV_REQ_TAG_UPDATE=1|endif
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

""""    Highlight Variable
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Highlight TODO, FIXME, NOTE, etc.
if has('autocmd') && v:version > 701
    augroup syntax_hi_gp
        autocmd!
        " autocmd Syntax * call matchadd(
        "             \ 'Debug',
        "             \ '\v\W\zs<(NOTE|INFO|IDEA|TODO|FIXME|CHANGED|XXX|BUG|HACK|TRICKY)>'
        "             \ )
        autocmd Syntax * call matchadd(
                    \ 'Debug',
                    \ '\v\W\zs<(NOTE|CHANGED|BUG|HACK|TRICKY)>'
                    \ )
    augroup END
endif

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
    au BufRead,BufNewFile *.iig set filetype=cpp
augroup END

""""    Plugins cmd
""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup plugin_gp
    autocmd!
    autocmd FileType nerdtree setlocal nocursorline

    "" vim-comment
    autocmd FileType gitcommit setlocal commentstring=#\ %s
    " autocmd FileType c,cpp,h,hxx,hpp,cxx,verilog setlocal commentstring=//\ %s

    "" tagbar
    " cursor line will slow down tagbar
    autocmd FileType tagbar setlocal nocursorline
augroup END

