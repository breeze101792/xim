" Session Function
" ===========================================
" Cross session operation, or session related operation
" -------------------------------------------
"  Session Load/Open
" -------------------------------------------
function! SessionGetPath(...)
    let session_path=""
    if a:0 == 1
        if a:1 == 'autosave' || a:1 == 'as'
            let session_path=g:IDE_ENV_SESSION_AUTOSAVE_PATH
        elseif a:1 == 'default' || a:1 == 'def'
            let session_path=g:IDE_ENV_SESSION_PATH
        else
            let session_path=a:1
        endif
    else
        let session_path=g:IDE_ENV_SESSION_PATH
    endif
    return session_path
endfunction

command! -nargs=*  SessionStore call SessionStore(<f-args>)
function! SessionStore(...)
    if a:0 == 1
        let session_path=SessionGetPath(a:1)
    elseif a:0 == 2
        let session_path=SessionGetPath(a:1, a:2)
    else
        let session_path=SessionGetPath()
    endif

    if empty(glob(session_path))
        call system('mkdir ' . session_path)
    endif

    " Session path
    let session_file=session_path."/session.vim"
    let session_bookmark_file=session_path."/bookmark.vim"
    let session_highlight=session_path."/highlight.hl"

    " Vars
    let current_buffer_name=expand('%:p')
    let buf_cnt=0
    let tab_cnt=0

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
        " echom 'Buffer:'.currbufname.'-'.bufloaded(currbufname).'-'.bufexists(currbufname).'-'.buflisted(currbufname)
        if !empty(glob(currbufname)) && buflisted(currbufname) == 1
            call writefile(['badd ' . currbufname], session_file, "a")
            let buf_cnt = buf_cnt + 1
        endif
        let currbufidx = currbufidx + 1
    endwhile

    " opened tab
    " FIXME, No win support.
    let tabcount = tabpagenr("$")
    let currenttabidx = 1
    call writefile(['" Session opened tab'], session_file, "a")
    call writefile(['""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""'], session_file, "a")
    while currenttabidx <= tabcount
        let tmp_buf_idx = tabpagebuflist(currenttabidx)[0]
        let currtabname = expand('#' . tmp_buf_idx . ':p')

        " echom 'Tab:'.currtabname.'-'.bufloaded(currtabname).'-'.bufexists(currtabname).'-'.buflisted(currtabname)
        if !empty(glob(currtabname)) && buflisted(currtabname) == 1
            call writefile(['tabnew ' . currtabname], session_file, "a")
            " FIXME, do it on acturally tab.
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
    silent! exe "BookmarkSave " . session_bookmark_file
    silent! exe "HI save " . session_highlight
    echo 'Session Stored finished., Tab:' . tab_cnt . ', Buf:' . buf_cnt. ", File: ". session_path
endfunction

command! -nargs=*  SessionLoad call SessionLoad(<f-args>)
function! SessionLoad(...)
    if a:0 == 1
        let session_path=SessionGetPath(a:1)
    elseif a:0 == 2
        let session_path=SessionGetPath(a:1, a:2)
    else
        let session_path=SessionGetPath()
    endif

    " Session path
    let session_file=session_path."/session.vim"
    let session_bookmark_file=session_path."/bookmark.vim"
    let session_highlight=session_path."/highlight.hl"

    if empty(glob(session_path)) || !isdirectory(session_path)
        echom "Folder not found. Session: ". session_path
        return
    endif

    let current_buffer_name=expand('%:p')
    let bufcount = bufnr("$")

    if !empty(glob(session_file))
        silent! exec 'source ' . session_file
        " exec 'source ' . session_file
    endif
    if current_buffer_name == "" &&  bufcount == 1
        tabc 1
    endif

    if !empty(glob(session_bookmark_file))
        silent! exec 'BookmarkLoad ' . session_bookmark_file
    endif
    if !empty(glob(session_highlight))
        silent! exec 'HI load ' . session_highlight
    endif
    echo 'Session loaded. Tab:' . tabpagenr("$") . ', Buf:'.bufnr("$"). " Session:" . session_file
endfunction

"  Bookmark
" -------------------------------------------
command! -nargs=*  SessionStoreBookmark call SessionStoreBookmark(<f-args>)
function! SessionStoreBookmark(...)
    if a:0 == 1
        let session_path=SessionGetPath(a:1)
    elseif a:0 == 2
        let session_path=SessionGetPath(a:1, a:2)
    else
        let session_path=SessionGetPath()
    endif

    let session_file=session_path."/session.vim"
    let session_bookmark_file=session_path."/bookmark.vim"

    if empty(glob(session_path))
        call system('mkdir ' . session_path)
    endif

    silent! exe "BookmarkSave " . session_bookmark_file
    echo "Session bookmark stored. Session Bookmark:" . session_bookmark_file
endfunction

command! -nargs=*  SessionLoadBookmark call SessionLoadBookmark(<f-args>)
function! SessionLoadBookmark(...)
    if a:0 == 1
        let session_path=SessionGetPath(a:1)
    elseif a:0 == 2
        let session_path=SessionGetPath(a:1, a:2)
    else
        let session_path=SessionGetPath()
    endif

    let session_file=session_path."/session.vim"
    let session_bookmark_file=session_path."/bookmark.vim"

    if !empty(glob(session_bookmark_file))
        silent! exec 'BookmarkLoad ' . session_bookmark_file
    endif
    echo "Session bookmark loaded. Session Bookmark:" . session_bookmark_file
endfunction

"  Highight
" -------------------------------------------
command! -nargs=*  SessionStoreHighlight call SessionStoreHighlight(<f-args>)
function! SessionStoreHighlight(...)
    if a:0 == 1
        let session_path=SessionGetPath(a:1)
    elseif a:0 == 2
        let session_path=SessionGetPath(a:1, a:2)
    else
        let session_path=SessionGetPath()
    endif

    let session_file=session_path."/session.vim"
    let session_highlight=session_path."/highlight.hl"

    if empty(glob(session_path))
        call system('mkdir ' . session_path)
    endif

    silent! exe "HI save " . session_highlight
    echo "Session highlight stored. Session highlight:" . session_highlight
endfunction

command! -nargs=*  SessionLoadHighlight call SessionLoadHighlight(<f-args>)
function! SessionLoadHighlight(...)
    if a:0 == 1
        let session_path=SessionGetPath(a:1)
    elseif a:0 == 2
        let session_path=SessionGetPath(a:1, a:2)
    else
        let session_path=SessionGetPath()
    endif

    let session_file=session_path."/session.vim"
    let session_highlight=session_path."/highlight.hl"

    if !empty(glob(session_highlight))
        silent! exec 'HI load ' . session_highlight
    endif
    echo "Session highlight loaded. Session highlight:" . session_highlight
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
