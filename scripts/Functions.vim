" Function Settings
" ===========================================
" -------------------------------------------
"  Mouse_on_off for cursor chage
" -------------------------------------------
let mouse_mode = 1 " 0 = a, 1 = c

command! MouseToggle call MouseToggle()

func! MouseToggle()
    if g:mouse_mode == 0
        let g:mouse_mode = 1
        set mouse=c
    else
        let g:mouse_mode = 0
        set mouse=a
    endif
    return
endfunc

" -------------------------------------------
"  Toggle Hexmode
" -------------------------------------------
" ex command for toggling hex mode - define mapping if desired
command -bar HexToggle call HexToggle()

" helper function to toggle hex mode
function HexToggle()
    " hex mode should be considered a read-only operation
    " save values for modified and read-only for restoration later,
    " and clear the read-only flag for now
    let l:modified=&mod
    let l:oldreadonly=&readonly
    let &readonly=0
    let l:oldmodifiable=&modifiable
    let &modifiable=1
    if !exists("b:editHex") || !b:editHex
        " save old options
        let b:oldft=&ft
        let b:oldbin=&bin
        " set new options
        setlocal binary " make sure it overrides any textwidth, etc.
        silent :e " this will reload the file without trickeries
        "(DOS line endings will be shown entirely )
        let &ft="xxd"
        " set status
        let b:editHex=1
        " switch to hex editor
        %!xxd -c 32
    else
        " restore old options
        let &ft=b:oldft
        if !b:oldbin
            setlocal nobinary
        endif
        " set status
        let b:editHex=0
        " return to normal editing
        %!xxd -r -c 32
    endif
    " restore values for modified and read only state
    let &mod=l:modified
    let &readonly=l:oldreadonly
    let &modifiable=l:oldmodifiable
endfunction
" -------------------------------------------
"  Display FunctionName
" -------------------------------------------
"this mapping assigns a variable to be the name of the function found by
"FunctionName() then echoes it back so it isn't erased if Vim shifts your
"location on screen returning to the line you started from in FunctionName()
" map \func :let name = FunctionName()<CR> :echo name<CR>

command! CurrentFunction call CurrentFunction()
fun CurrentFunction()
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
"  Toggle Debug message
" -------------------------------------------
command! DebugToggle call DebugToggle()
function! DebugToggle()
    if !&verbose
        set verbosefile=~/.vim/verbose.log
        set verbose=15
    else
        set verbose=0
        set verbosefile=
    endif
endfunction
" ===========================================
" C/C++ Function
" ===========================================
" -------------------------------------------
"  C Function
" -------------------------------------------
command! -nargs=? CFun :call <SID>CFun(<q-args>)
function! s:CFun(fun_name)
    let l:indent = repeat(' ', indent('.'))
    let l:tmpl=a:fun_name
    if l:tmpl == ""
        let l:tmpl="function_name"
    endif
    let l:text = [
                \ "u32retCode = <TMPL>;",
                \ "if (u32retCode != TRUE)",
                \ "{",
                \ "    printf(\"Fail to call <TMPL>. Return Code:%u\\n\", __func__, __LINE__, u32retCode);",
                \ "    return u32retCode;",
                \ "}",
                \ ""
                \ ]
    call map(l:text, {k, v -> l:indent . substitute(v, '\C<TMPL>', l:tmpl, 'g')})
    call append('.', l:text)
endfunction
" -------------------------------------------
"  C Printf
" -------------------------------------------
command! -nargs=? CPrintf :call <SID>CPrintf(<q-args>)
command! CPrintf :call <SID>CPrintf("")
function! s:CPrintf(content)
    let l:indent = repeat(' ', indent('.'))
    let l:tmpl=a:content
    if l:tmpl == ""
        let l:tmpl="message"
    endif
    let l:text = [
                \ "printf(\"[Debug %s,%d] <TMPL> \\n\", __func__, __LINE__);\n",
                \ ""
                \ ]
    call map(l:text, {k, v -> l:indent . substitute(v, '\C<TMPL>', l:tmpl, 'g')})
    call append('.', l:text)
endfunction
" ===========================================
" Python Function
" ===========================================
" -------------------------------------------
"  Python Prop
" -------------------------------------------
command! -nargs=? PyProp :call <SID>PyProp(<q-args>)
command! PyProp :call <SID>PyProp("python_prop")
function! s:PyProp(property)
    let l:indent = repeat(' ', indent('.'))
    let l:tmpl=a:property
    if l:tmpl == ""
        let l:tmpl="py_prop"
    endif
    let l:text = [
        \ '@property',
        \ 'def <TMPL>(self):',
        \ '    return self.<TMPL>',
        \ '@property.setter',
        \ '    def <TMPL>(self,val):',
        \ '        self._<TMPL> = val'
    \ ]
    call map(l:text, {k, v -> l:indent . substitute(v, '\C<TMPL>', l:tmpl, 'g')})
    call append('.', l:text)
endfunction
