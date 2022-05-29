" Function Settings
" ===========================================

" -------------------------------------------
"  Mouse_on_off for cursor chage
" -------------------------------------------
let g:mouse_mode = 1 " 0 = a, 1 = c

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
" -------------------------------------------
"  Clip
" -------------------------------------------
command! ClipRead call ClipRead()

func! ClipRead()
    let @c = system('cat ${HOME}/.vim/clip')
    echo 'Read '.@c.'to reg c'
endfunc

command! ClipOpen call ClipOpen()

func! ClipOpen()
    let l:clip_buf = system('cat ${HOME}/.vim/clip')
    execute 'tabnew ' . l:clip_buf
endfunc

" -------------------------------------------
"  Title
" -------------------------------------------
command! -nargs=? Title :call <SID>Title(<q-args>)
function! s:Title(fun_name)
    let g:IDE_ENV_IDE_TITLE=a:fun_name
    if version >= 802
        redrawtabline
    else
        " old version didn't have redrawtabline
        " so use redraw all for it
        redraw!
    endif
endfunc

" -------------------------------------------
"  Tags
" -------------------------------------------
command! TagUpdate call TagUpdate()

func! TagUpdate()
    execute 'cscope reset'
endfunc
" -------------------------------------------
"  Beautify Remove trailing space
" -------------------------------------------
command! -range TrimRepeatedSpace <line1>,<line2>call TrimRepeatedSpace()
function! TrimRepeatedSpace() range
    " echo 'First Line:'.a:firstline.', Last Line:'.a:lastline
    silent! execute a:firstline.','.a:lastline.'s/\s\+/ /g'
    silent! execute a:firstline.','.a:lastline.'s/\s\+$//g'
endfunction

command! -range TrimTrailingSpace <line1>,<line2>call TrimTrailingSpace()
function! TrimTrailingSpace() range
    " echo 'First Line:'.a:firstline.', Last Line:'.a:lastline
    silent! execute a:firstline.','.a:lastline.'s/\s\+$//g'
endfunction

command! -range TrimEmptyLine <line1>,<line2>call TrimEmptyLine()
function! TrimEmptyLine() range
    " echo 'First Line:'.a:firstline.', Last Line:'.a:lastline
    " execute a:firstline.','.a:lastline.'s/\n\{2,\}/\n/g'
    silent! execute a:firstline.','.a:lastline.'s/\(\n\n\)\n\+/\1/e'
endfunction

command! -range Beautify <line1>,<line2>call Beautify()
function! Beautify() range

    " remove the trailing space
    silent! execute a:firstline.','.a:lastline.'s/\s\+$//e'

    " Remove empty lines with space
    " execute a:firstline.','.a:lastline. :%s/\($\n\s*\)\+\%$//e

    " remove double next line
    silent! execute a:firstline.','.a:lastline.'s/\(\n\n\)\n\+/\1/e'

endfunction

" -------------------------------------------
"  Duplicate Function
" -------------------------------------------
command! -range -nargs=?  DuplicateLine <line1>,<line2>call DuplicateLine(<q-args>)
function! DuplicateLine(times) range
    let l:counter = 0
    let l:selectedlines = getline(a:firstline, a:lastline)
    let l:text = [ ]
    let tmp_times=a:times

    if l:tmp_times == ""
        let l:tmp_times=1
    endif

    while l:counter < l:tmp_times
        " call append('.', l:selectedlines)
        call extend(l:text, l:selectedlines)
        let l:counter += 1
    endwhile
    call append('.', l:text)
    echo 'Duplicate text '.a:times.' times done.'
endfunction

" -------------------------------------------
"  Generate num seq
" -------------------------------------------
command! -nargs=*  GenerateNumSeq call GenerateNumSeq(<f-args>)
function! GenerateNumSeq(...)
    let l:start=1
    let l:num=5

    if a:0 == 1
        let l:num=a:1
    elseif a:0 == 2
        echo a:1.','.a:2.','.a:0
        let l:num=a:2
        let l:start=a:1
    endif

    let l:counter = l:start
    let l:selectedlines = getline(a:firstline, a:lastline)
    let l:text = [ ]

    if l:counter == ""
        let l:counter=1
    endif

    while l:counter < l:num + l:start
        call add(l:text, l:counter)
        let l:counter += 1
    endwhile
    call append('.', l:text)
    echo 'Generate num from '.l:start.' to '.l:num

endfunction

" -------------------------------------------
"  Repeat text
" -------------------------------------------
command! -nargs=* RepeatText call RepeatText(<f-args>)
function! RepeatText(text, times)
    let l:counter = 0
    let l:selectedlines = a:text
    let l:text = ""
    let tmp_times=a:times

    if l:tmp_times == ""
        let l:tmp_times=1
    endif

    while l:counter < l:tmp_times
        " call append(l:text, l:selectedlines)
        let l:text = l:text.l:selectedlines
        let l:counter += 1
    endwhile
    call append('.', l:text)
    echo 'Repeate text '.a:times.' times done.'
endfunction
" -------------------------------------------
"  DisplayColorSchemes
" -------------------------------------------
function! DisplayColorSchemes()
   let currDir = getcwd()
   exec "cd $VIMRUNTIME/colors"
   for myCol in split(glob("*"), '\n')
      if myCol =~ '\.vim'
         let mycol = substitute(myCol, '\.vim', '', '')
         exec "colorscheme " . mycol
         exec "redraw!"
         echo "colorscheme = ". myCol
         sleep 2
      endif
   endfor
   exec "cd " . currDir
endfunction
command! Dcs call DisplayColorSchemes()
