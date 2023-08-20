" -------------------------------------------
"  Test
" -------------------------------------------
command! TestJob call TestJob()
function! TestJob()
    function! PMsg(ch, msg)
        echom 'PMsg '.a:ch.' '.a:msg
    endfunc
    let g:IDE_ENV_REQ_TAG_UPDATE = 2
    try
        let l:job = job_start('hsexc pwd', { 'callback': 'PMsg' })
    catch
        echom "Test Failed"
    endtry
endfunc

" -------------------------------------------
"  PlugBufexplorer
" -------------------------------------------
command! PlugBufexplorer call PlugBufexplorer()

function! PlugBufexplorer()

    if exists("g:bufexplorer_version")
        " call <Plug>setup()
        " let sid = '~/tools/vim-ide/plugins/bufexplorer/plugin/bufexplorer.vim' " Parse :scriptnames output
        let sid = '~/tools/vim-ide/plugins/bufexplorer/plugin/bufexplorer.vim' " Parse :scriptnames output
        let MyFuncref = function("<SNR>" . sid . '_' ."setup")
        echo call(MyFuncref, [])
    endif
    echo 'Toggle bufexplorer'
    execute 'ToggleBufExplorer'
endfunc

" -------------------------------------------
"  Get IDs
" -------------------------------------------
function! FindScriptID(name)
    for tabnr in function
        echo tabnr
    endfor
    return [0, 0]
endfunction
" function s:FindWinID(id)
"     for tabnr in range(1, tabpagenr('$'))
"         for winnr in range(1, tabpagewinnr(tabnr, '$'))
"             if gettabwinvar(tabnr, winnr, 'id') is a:id
"                 return [tabnr, winnr]
"             endif
"         endfor
"     endfor
"     return [0, 0]
" endfunction


" " -------------------------------------------
" "  Largfile handle
" " -------------------------------------------
" " file is large from 10mb
" let g:LargeFile = 1024 * 1024 * 10
" augroup LargeFile
"     au!
"     autocmd BufReadPre * let f=getfsize(expand("<afile>")) | if f > g:LargeFile || f == -2 | call LargeFile() | endif
" augroup END

" function! LargeFile()
"     " no syntax highlighting etc
"     " set eventignore+=FileType
"     set filetype=none
"     " save memory when other file is viewed
"     setlocal bufhidden=unload
"     " is read-only (write with :w new_filename)
"     setlocal buftype=nowrite
"     " no undo possible
"     setlocal undolevels=-1
"     " display message
"     " autocmd VimEnter *  echo "The file is larger than " . (g:LargeFile / 1024 / 1024) . " MB, so some options are changed (see .vimrc for details)."
" endfunction
