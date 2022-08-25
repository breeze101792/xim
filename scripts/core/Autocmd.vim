""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Autocmd vim env                           """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""    Auto function
""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! PostInit()
    " Tag setup
    " -------------------------------------------
    if g:IDE_ENV_CSCOPE_DB != ''
        " echo "Open "g:IDE_ENV_CSCOPE_DB
        execute "cscope add ".g:IDE_ENV_CSCOPE_DB
    endif
    " FIXME don't use autocmd ousside group, fix/test it with ccglue
    if g:IDE_ENV_CCTREE_DB != ''
        " echo "Open "g:IDE_ENV_CCTREE_DB
        silent! execute "CCTreeLoadXRefDB" . g:IDE_ENV_CCTREE_DB
    endif
    if g:IDE_ENV_PROJ_SCRIPT != ''
        " echo "Source "g:IDE_ENV_PROJ_SCRIPT
        execute 'source' . g:IDE_ENV_PROJ_SCRIPT
    endif

    " Moving from delay loading function will slow down the launch time.
    " try
    "     :GitGutterEnable
    " catch
    "     echo 'Fail to load Gitgutter'
    " endtry
    " call plug#load('vim-surround')
    " call plug#load('supertab')
    " call plug#load('vim-multiple-cursors')
endfunction

augroup init_gp
    autocmd!
    autocmd VIMEnter * call PostInit()
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

