

""""    Worker Checker function
""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! W_TagUpdate()
    if g:IDE_ENV_PROJ_DATA_PATH != "" && g:IDE_ENV_REQ_TAG_UPDATE == 1
        " g:IDE_ENV_REQ_TAG_UPDATE
        " 0: Can be request to update
        " 1: Request to update
        " 2: Doing update, will ignore all request
        call TagUpdate()
    else
        let g:IDE_ENV_REQ_TAG_UPDATE = 0
    endif
endfunc

""""    Auto function
""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! IDE_PostInit(timer) abort
    call IDE_EnvSetup()
    if g:IDE_CFG_PLUGIN_ENABLE == "y"
        call IDE_PlugInDealyLoading()
    endif

    if g:IDE_ENV_REQ_SESSION_RESTORE != ""
        echom "Restore: ".g:IDE_ENV_REQ_SESSION_RESTORE
        call SessionLoad(g:IDE_ENV_REQ_SESSION_RESTORE)
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

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Auto Commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""    Init commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""
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

function! IDE_Leave()
    if g:IDE_CFG_SESSION_AUTOSAVE == 'y'
        silent! exe "SessionStore autosave"
    endif
endfunction

augroup leave_gp
    autocmd!
    autocmd VimLeavePre * call IDE_Leave()
augroup END


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
" autocmd FileType c,cpp setlocal equalprg=clang-format
augroup file_open_gp
    autocmd!

    " disable file operation if it's bigger then what we expected.
    " Check if 500MB
    " autocmd FileType * if getfsize(@%) > g:IDE_ENV_DEF_FILE_SIZE_THRESHOLD | echom "Big file size detected(".getfsize(@%)."). Enter Fast mode."| setlocal syntax=OFF | setlocal nowrap | setlocal nofoldenable | setlocal nohlsearch | endif
    autocmd BufReadPre * if getfsize(@%) > g:IDE_ENV_DEF_FILE_SIZE_THRESHOLD | echom "Big file size detected(".getfsize(@%)."). Enter Fast mode."| call LargeFileMode() | endif

    " memorize last open line
    autocmd BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif
augroup END

augroup file_write_gp
    autocmd!
    autocmd FileType c,cc,c++,cxx,cpp,h,hh,h++,hxx,hpp autocmd BufWritePost * if g:IDE_ENV_REQ_TAG_UPDATE == 0|let g:IDE_ENV_REQ_TAG_UPDATE=1|endif
augroup END

" Call the function after opening a buffer
augroup tab_gp
    autocmd!
    autocmd BufReadPost * call TabsOrSpaces()
augroup END

augroup filetype_gp
    autocmd!
    " Larg file check.
    " au BufNewFile *.log set filetype=log
    autocmd BufReadPost,BufNewFile *.log if getfsize(@%) < g:IDE_ENV_DEF_FILE_SIZE_THRESHOLD | set filetype=log | endif

    " source code file, don't need to check file size.
    autocmd BufNewFile,BufReadPost *.iig set filetype=cpp
augroup END

" Looks like formatter will disable syntax.
" augroup formatter_gp
"     autocmd!
"     autocmd FileType javascript if executable("js-beautify") == 1 | setlocal equalprg="js-beautify -f -" | endif
"     autocmd FileType sh,bash if executable("shfmt") == 1 | setlocal equalprg="shfmt -i 4 -cs" | endif
" augroup END

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

