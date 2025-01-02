" -------------------------------------------
"  TabsOrSpaces
" -------------------------------------------
function! TabsOrSpaces()
    " Determines whether to use spaces or tabs on the current buffer.
    " if getfsize(bufname("%")) > 256000
    "     " File is very large, just use the default.
    "     setlocal expandtab
    "     return
    " endif

    let check_line_num=250
    let file_lines=line('$')
    let start_line=0
    if file_lines < check_line_num
        let start_line=0
    else
        let start_line=file_lines - check_line_num
    endif

    " TODO, count only on code area. currently use offset to avoid counting on
    " header descriptions.
    let tab_num=len(filter(getbufline(bufname("%"), start_line, "$"), 'v:val =~ "^\\t"'))
    let space_num=len(filter(getbufline(bufname("%"), start_line, "$"), 'v:val =~ "^  "'))
    " echo 'File num: '.file_lines.', Tabs:'.tab_num.', Spaces: '.space_num

    if tab_num > space_num
        setlocal noexpandtab
    else
        setlocal expandtab
    endif
endfunction
" -------------------------------------------
"  Selection
" -------------------------------------------
function! VisualSelection()
    if mode()=="v"
        let [line_start, column_start] = getpos("v")[1:2]
        let [line_end, column_end] = getpos(".")[1:2]
    else
        let [line_start, column_start] = getpos("'<")[1:2]
        let [line_end, column_end] = getpos("'>")[1:2]
    end
    if (line2byte(line_start)+column_start) > (line2byte(line_end)+column_end)
        let [line_start, column_start, line_end, column_end] =
        \   [line_end, column_end, line_start, column_start]
    end
    let lines = getline(line_start, line_end)
    if len(lines) == 0
            return ''
    endif
    let lines[-1] = lines[-1][: column_end - 1]
    let lines[0] = lines[0][column_start - 1:]
    " echo join(lines, "\n")
    return join(lines, "\n")
endfunction

" -------------------------------------------
"  Display FunctionName
" -------------------------------------------
"this mapping assigns a variable to be the name of the function found by
"FunctionName() then echoes it back so it isn't erased if Vim shifts your
"location on screen returning to the line you started from in FunctionName()
" map \func :let name = FunctionName()<CR> :echo name<CR>

command! CurrentFunction call CurrentFunction()
function! CurrentFunction()
    let strList = ["while", "foreach", "ifelse", "if else", "for", "if", "else", "try", "catch", "case", "switch"]
    let counter = 0
    let max_find = 5
    let foundcontrol = 1
    let position = ""
    let pos=getpos(".")          " This saves the cursor position
    let view=winsaveview()       " This saves the window view
    while (foundcontrol)
        let counter = counter + 1
        if counter > max_find
            call cursor(pos)
            call winrestview(view)
            return ""
        endif
        let foundcontrol = 0
        normal [{
        call search('\S','bW')
        let tempchar = getline(".")[col(".") - 1]
        if (match(tempchar, ")") >=0 )
            normal %
            call search('\S','bW')
        endif
        let tempstring = getline(".")
        for item in strList
            if( match(tempstring,item) >= 0 )
                let position = item . " - " . position
                let foundcontrol = 1
                break
            endif
        endfor
        if(foundcontrol == 0)
            call cursor(pos)
            call winrestview(view)
            return tempstring.position
        endif
    endwhile
    call cursor(pos)
    call winrestview(view)
    return tempstring.position
endfun
" -------------------------------------------
"  Conditional Pair
" -------------------------------------------
" This matches character pairs that are defined.
function! ConditionalPairMap(open, close) abort
    let line = getline('.')
    let col = col('.')
    if col < col('$') || stridx(line, a:close, col + 1) != -1
        return a:open
    else
        return a:open . a:close . repeat("\<left>", len(a:close))
    endif
endfunction
" -------------------------------------------
"  String Ops
" -------------------------------------------
fu! StartsWith(longer, shorter) abort
    return a:longer[0:len(a:shorter)-1] ==# a:shorter
endfunction

fu! EndsWith(longer, shorter) abort
    return a:longer[len(a:longer)-len(a:shorter):] ==# a:shorter
endfunction
fu! Contains(longer, shorter) abort
    return stridx(a:longer, a:short) >= 0
endfunction

" -------------------------------------------
"  String Path compare
" -------------------------------------------
function! PathCompare(path_a,path_b) abort
    let list_a = split(a:path_a,'/')
    let list_b = split(a:path_b,'/')
    let len_a=len(list_a)
    let len_b=len(list_b)

    if len_a > len_b
        for each_idx in range(len_b)

            if list_b[len_b - each_idx - 1] != list_a[len_a - each_idx - 1]
                return list_a[len_a - each_idx - 1]
            endif
        endfor
        return list_a[len_a - len_b - 1]
    elseif len_a < len_b
        for each_idx in range(len_a)
            if list_a[len_a - each_idx - 1] != list_b[len_b - each_idx - 1]
                return list_a[len_a - each_idx - 1]
            endif
        endfor
        " return list_b[len_b - len_a - 1]
    else
        for each_idx in range(len_b)
            let tmp_idx = len_b - each_idx - 1
            if list_b[tmp_idx] != list_a[tmp_idx]
                return list_a[tmp_idx]
            endif
        endfor
    endif
    return ""
endfunc
" -------------------------------------------
"  Largefile
" -------------------------------------------
function! LargeFileMode()
    " if getfsize(@%) > g:IDE_ENV_DEF_FILE_SIZE_THRESHOLD
        setlocal syntax=OFF
        setlocal nowrap
        setlocal nofoldenable
        setlocal nohlsearch

        " Set options:
        "   eventignore+=FileType (no syntax highlighting etc
        "   assumes FileType always on)
        "   noswapfile (save copy of file)
        "   bufhidden=unload (save memory when other file is viewed)
        "   buftype=nowritefile (is read-only)
        "   undolevels=-1 (no undo possible)
        setlocal noswapfile bufhidden=unload buftype=nowrite undolevels=-1

    "     set eventignore+=FileType
    " else
    "     set eventignore-=FileType
    " endif
endfunc
" -------------------------------------------
"  GetFileSize
" -------------------------------------------
function! GetFileSize()
    let bytes = getfsize(expand('%:p'))
    if bytes <= 0
        return '0B'
    endif

    if (bytes >= 1024*1024*1024)
        let gbytes = bytes / 1024 / 1024 / 1024
        return gbytes.'GB'
    elseif (bytes >= 1024*1024)
        let mbytes = bytes / 1024 / 1024
        return mbytes.'MB'
    elseif (bytes >= 1024)
        let kbytes = bytes / 1024
        return kbytes.'KB'
    else
        return bytes.'B'
    endif

endfunction
command! GetFileSize call GetFileSize()
