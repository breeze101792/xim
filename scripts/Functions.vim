" Function Settings
" ===========================================
" -------------------------------------------
"  Mouse_on_off for cursor chage
" -------------------------------------------
let mouse_mode = 0 " 0 = a, 1 = c

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
command! MouseToggle call MouseToggle()

" -------------------------------------------
"  Toggle Hexmode
" -------------------------------------------
" ex command for toggling hex mode - define mapping if desired
command -bar Hexmode call ToggleHex()

" helper function to toggle hex mode
function ToggleHex()
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
fun FunctionName()
    "set a mark at our current position
    normal mz
    "while foundcontrol == 1, keep looking up the line to find something that
    "isn't a control statement
    let foundcontrol = 1
    while (foundcontrol)
        "find the previous '{' and get the line above it
        ?{
        normal k0
        let tempstring = getline(".")
        "if the line matches a control statement, set found control to 1 so
        "we can look farther back in the file for the beginning of the
        "actual function we are in
        if(match(tempstring, "while") >= 0)
            let foundcontrol = 1
        elseif(match(tempstring, "for") >= 0)
            let foundcontrol = 1
        elseif(match(tempstring, "if") >= 0)
            let foundcontrol = 1
        elseif(match(tempstring, "else") >= 0)
            let foundcontrol = 1
        elseif(match(tempstring, "try") >= 0)
            let foundcontrol = 1
        elseif(match(tempstring, "catch") >= 0)
            let foundcontrol = 1
        else
            normal `z
            let foundcontrol = 0
            return tempstring
        endif
    endwhile
    echo tempstring
    return tempstring
endfun

"this mapping assigns a variable to be the name of the function found by
"FunctionName() then echoes it back so it isn't erased if Vim shifts your
"location on screen returning to the line you started from in FunctionName()
" map \func :let name = FunctionName()<CR> :echo name<CR>

command! FunName call FunctionName()


" -------------------------------------------
"  Toggle Debug message
" -------------------------------------------
function! DebugToggle()
    if !&verbose
        set verbosefile=~/.vim/verbose.log
        set verbose=15
    else
        set verbose=0
        set verbosefile=
    endif
endfunction
command! DebugToggle call DebugToggle()
