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
