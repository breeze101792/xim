" Session Function
" ===========================================
" Cross session operation, or session related operation
" -------------------------------------------
"  Session Load/Open
" -------------------------------------------
command! SessionStore :call SessionStore()
function! SessionStore()
    let session_file=g:IDE_ENV_SESSION_PATH
    let current_buffer_name=expand('%:p')

    let bufcount = bufnr("$")
    let currbufidx = 1
    if bufcount == 1
        echoe "Preventing writing only 1 page to session."
        return
    endif

    call writefile(['" Vim session file'], session_file, "")
    call writefile(['" Session open buffer'], session_file, "a")
    call writefile(['""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""'], session_file, "a")
    while currbufidx <= bufcount
        let currbufname = expand('#' . currbufidx . ':p')
        if !empty(glob(currbufname))
            " FIXME delete buffer will also show on the list, remove it in the
            " future
            " echo currbufidx . ": ". currbufname
            " call writefile(['edit ' . currbufname], session_file, "a")
            " use buffer add to accerate speed
            call writefile(['badd ' . currbufname], session_file, "a")
        endif
        let currbufidx = currbufidx + 1
    endwhile

    " opened tab
    " FIXME, No win support.
    let tabcount = tabpagenr("$")[0]
    let currenttabidx = 1
    call writefile(['" Session opened tab'], session_file, "a")
    call writefile(['""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""'], session_file, "a")
    while currenttabidx <= tabcount
        let tmp_buf_idx = tabpagebuflist(currenttabidx)[0]
        let currtabname = expand('#' . tmp_buf_idx . ':p')

        if !empty(glob(currtabname))
            call writefile(['tabnew ' . currtabname], session_file, "a")
            if currtabname == current_buffer_name
                call writefile(["let session_previous_tabnr=tabpagenr('$')"], session_file, "a")
            endif
        endif
        let currenttabidx = currenttabidx + 1
    endwhile

    let currtabname=bufname("%")
    if !empty(glob(currtabname))
        call writefile(['" Restore settings'], session_file, "a")
        call writefile(['""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""'], session_file, "a")
        call writefile(['"Open buffer:'. current_buffer_name], session_file, "a")
        call writefile(["exe 'tabn ' . session_previous_tabnr" ], session_file, "a")
    endif

    " Save bookmark
    silent! exe "BookmarkSave " . g:IDE_ENV_SESSION_BOOKMARK_PATH
    echo 'Session Stored finished.'
endfunction

command! SessionLoad :call SessionLoad()
function! SessionLoad()
    let session_file=g:IDE_ENV_SESSION_PATH
    let current_buffer_name=expand('%:p')
    let bufcount = bufnr("$")

    if !empty(glob(session_file))
        silent! exec 'source ' . session_file
        " exec 'source ' . session_file
    endif
    if current_buffer_name == "" &&  bufcount == 1
        tabc 1
    endif

    if !empty(glob(g:IDE_ENV_SESSION_BOOKMARK_PATH))
        silent! exec 'BookmarkLoad ' . g:IDE_ENV_SESSION_BOOKMARK_PATH
    endif
    echo 'Session loaded. BufCnt:'.bufnr("$"). " Session:" . session_file
endfunction

command! SessionSaveBookmark :call SessionSaveBookmark()
function! SessionSaveBookmark()
    silent! exe "BookmarkSave " . g:IDE_ENV_SESSION_BOOKMARK_PATH
    echo "Session bookmark saved. Session Bookmark:" . g:IDE_ENV_SESSION_BOOKMARK_PATH
endfunction

command! SessionLoadBookmark :call SessionLoadBookmark()
function! SessionLoadBookmark()
    if !empty(glob(g:IDE_ENV_SESSION_BOOKMARK_PATH))
        silent! exec 'BookmarkLoad ' . g:IDE_ENV_SESSION_BOOKMARK_PATH
    endif
    echo "Session bookmark loaded. Session Bookmark:" . g:IDE_ENV_SESSION_BOOKMARK_PATH
endfunction
" -------------------------------------------
"  Session copy/paste op
" -------------------------------------------
function! SessionYank()
    new
    "v"                 for characterwise text
    "V"                 for linewise text
    "<CTRL-V>{width}"   for blockwise-visual text
    ""                  for an empty or unknown register
    " call setline(1,getregtype())
    let l:setline_msg=substitute(setline(1,getregtype()), '\n\+', '', '')
    " Put the text [from register x] after the cursor
    let l:yank_msg=substitute(execute('put'), '\n\+', '', '')

    silent! exec 'wq! ' . g:IDE_ENV_CLIP_PATH
    silent! exec 'bdelete ' . g:IDE_ENV_CLIP_PATH
    echo 'SessionYank, ' . l:yank_msg .", " . l:setline_msg
endfunction

function! SessionPaste(command)
    silent exec 'sview ' . g:IDE_ENV_CLIP_PATH
    let l:opt=getline(1)
    " let l:paste_msg=substitute(execute('2,$yank'), '\n\+', '', '')
    let l:paste_msg=substitute(execute('2,$yank'), '\n\+', '', '')
    let l:paste_msg=substitute(l:paste_msg, 'yanked', 'pasted', '')
    " 2,$yank
    if (l:opt == 'v')
        call setreg('"', strpart(@",0,strlen(@")-1), l:opt) " strip trailing endline ?
    else
        call setreg('"', @", l:opt)
    endif
    silent exec 'bdelete ' . g:IDE_ENV_CLIP_PATH
    silent exec 'normal ' . a:command
    " echo 'SessionPaste'
    echo 'SessionPaste, ' . l:paste_msg
endfunction
" -------------------------------------------
"  Clip op
" -------------------------------------------
command! ClipRead call ClipRead()

function! ClipRead()
    " let @c = system('cat ' . g:IDE_ENV_CLIP_PATH)
    " echo 'Read '.@c.'to reg c'
    echo system('cat ' . g:IDE_ENV_CLIP_PATH . '|tail -n 1 | tr -d "\n\r"')
endfunc

command! ClipOpen call ClipOpen()

function! ClipOpen()
    let l:clip_buf = system('cat ' . g:IDE_ENV_CLIP_PATH . '|tail -n 1 | tr -d "\n\r"')
    if !empty(glob(l:clip_buf))
        execute 'tabnew ' . l:clip_buf
    else
        " echo 'File not found'
        echo 'File not found. "' . l:clip_buf . '"'
    endif
endfunc

command! ClipCopy call ClipCopy()
function! ClipCopy()
    echo system('echo ' . expand('%:p') . ' > ' . g:IDE_ENV_CLIP_PATH)
endfunc

" -------------------------------------------
"  Title
" -------------------------------------------
command! -nargs=? Title :call <SID>Title(<q-args>)
function! s:Title(title_name)
    let g:IDE_ENV_IDE_TITLE=a:title_name
    if version >= 802
        redrawtabline
    else
        " old version didn't have redrawtabline
        " so use redraw all for it
        redraw!
    endif
endfunc
