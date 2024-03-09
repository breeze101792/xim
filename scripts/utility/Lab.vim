
" -------------------------------------------
"  Trace
" -------------------------------------------
command! -nargs=* -complete=expression Trace
    \ call Trace(<args>)

function! Trace (...)
    let mesg = join(a:000)
    " let mesg = strftime("%Y-%m-%d %H:%M:%S") . " " . mesg
    let mesg_list = split(mesg, "\n")
    let orig_tabnr = tabpagenr()

    if !exists("g:trace_bufnr") || !bufexists(g:trace_bufnr)
        tabe
        let g:trace_bufnr = bufnr("%")
        file Trace
        setlocal buftype=nofile bufhidden=hide
    else
        let trace_tabnr = 0
        for t in range(tabpagenr("$"))
            let a = tabpagebuflist(t + 1)
            for i in a
                if i == g:trace_bufnr
                    let trace_tabnr = t + 1
                endif
            endfor
        endfor
        if trace_tabnr
            exec "tabn " . trace_tabnr
        else
            exec "tab sbuf " . g:trace_bufnr
        endif
    endif

    if line("$") == 1 && getline(1) == ""
        let line = 1
    else
        let line = line("$") + 1
    endif
    call setline(line, mesg_list)
    call cursor(line, 1)
    exec "tabn " . orig_tabnr
endfunction


" -------------------------------------------
"  Help
" -------------------------------------------
" command! -nargs=? TestHelp call TestHelp(<q-args>)
" command! -range TestHelp call TestHelp('')
" function! TestHelp(filename)
"     let l:file_name=a:filename
"
"     if l:file_name == ''
"         try
"             let l:file_name = VisualSelection()
"         catch
"             let l:file_name = expand("<cword>")
"         endtry
"     endif
"
"     let l:target_file = system('echo '.l:file_name.' | sort | head -n 1 | tr -d "\n"' )
"     echo l:target_file
" endfunc

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
