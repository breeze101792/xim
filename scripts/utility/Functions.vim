" Function Settings
" ===========================================
" -------------------------------------------
"  Mouse_on_off for cursor chage
" -------------------------------------------
command! MouseToggle call MouseToggle()

function! MouseToggle()
    if &mouse == 'c'
        set mouse=a
    else
        set mouse=c
    endif
    return
endfunc
" -------------------------------------------
"  Fast mode for slow device
" -------------------------------------------
command! FastMode call FastMode()

function! FastMode()
    if &cursorline
        echo 'Enable fast mode'
        :NoMatchParen
        set nocursorline
    else
        echo 'Disable fast mode'
        :DoMatchParen
        set cursorline
    endif
    " if exists(":NoMatchParen")
    "     " reenable matchparent
    "     " :DoMatchParen
    "     :NoMatchParen

    " endif
endfunc
" -------------------------------------------
"  Pure mode
" -------------------------------------------
command! PureToggle call PureToggle()

function! PureToggle()
    if &paste
        echo 'Disable Pure mode'
        set nopaste
        set cursorline
        set number

        :DoMatchParen
        :GitGutterDisable

        " if g:IDE_CFG_SPECIAL_CHARS == "y"
        "     set showbreak=↪\
        "     set listchars=tab:▸-,nbsp:␣,trail:·,precedes:←,extends:→
        " else
        "     set showbreak=→\
        "     set listchars=tab:▸-,nbsp:␣,trail:·,precedes:←,extends:→
        " endif
    else
        echo 'Enable Pure mode'
        set paste
        set nocursorline
        set nonumber

        :NoMatchParen
        :GitGutterEnable

        " set showbreak= 
        " set listchars=tab: ,nbsp: ,trail: ,precedes: ,extends: 
    endif
endfunc
" -------------------------------------------
"  Toggle Hexmode
" -------------------------------------------
" ex command for toggling hex mode - define mapping if desired
command! -bar HexToggle call HexToggle()

" helper function to toggle hex mode
function! HexToggle()
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
        %!xxd -c 16
    else
        " restore old options
        let &ft=b:oldft
        if !b:oldbin
            setlocal nobinary
        endif
        " set status
        let b:editHex=0
        " return to normal editing
        %!xxd -r -c 16
    endif
    " restore values for modified and read only state
    let &mod=l:modified
    let &readonly=l:oldreadonly
    let &modifiable=l:oldmodifiable
endfunction
" mark file as binary
command! Binary call Binary()
function! Binary()
    setlocal binary
    :e
endfunction
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
"  File op
" -------------------------------------------
command! -range FileOpen call FileOpen('')

function! FileOpen(filename)
    " ~/.bashrc
    let l:file_name = a:filename
    if l:file_name == ''
        l:file_name = VisualSelection()
    endif
    echo 'File name: '.l:file_name

    if !empty(glob(l:file_name))
        execute 'tabnew ' . l:file_name
    else
        " echo 'File not found'
        echo 'File not found. "' . l:file_name . '"'
    endif
endfunc

command! -nargs=? FindFile call FindFile(<q-args>)
command! -range FindFile call FindFile('')
function! FindFile(filename)
    let l:file_name=a:filename

    if l:file_name == ''
        try
            echo 
            let l:file_name = VisualSelection()
        catch
            let l:file_name = expand("<cword>")
        endtry
    endif
    echo 'Search File:'.l:file_name

    let l:target_file = system('find . -name '.l:file_name.' | sort | head -n 1 | xargs realpath | tr -d "\n"' )

    if !empty(glob(l:target_file))
        execute 'tabnew ' . l:target_file
    else
        " echo 'File not found'
        echo 'File not found. "' . l:file_name . '"'
    endif
endfun

command! -nargs=? RenameFile :call RenameFile(<q-args>)
function! RenameFile(new_name)
    let old_name = expand('%')
    " let new_name = input('New file name: ', expand('%'), 'file')
    if a:new_name != '' && a:new_name != old_name
        exec ':saveas ' . a:new_name
        exec ':silent !mv ' . old_name . ' ' . old_name.strftime("_RN_%Y%m%d_%I%M%S")
        redraw!
    endif
endfunction

command! -nargs=? DuplicateFile :call DuplicateFile(<q-args>)
function! DuplicateFile(new_name)
    let old_name = expand('%')
    " let new_name = input('New file name: ', expand('%'), 'file')
    if a:new_name != '' && a:new_name != old_name
        exec ':saveas ' . a:new_name
        exec ':silent !cp ' . old_name
        redraw!
    endif
endfunction
" -------------------------------------------
"  Tab op
" -------------------------------------------
function! TabCloseOthers(bang)
    let cur=tabpagenr()
    while cur < tabpagenr('$')
        exe 'tabclose' . a:bang . ' ' . (cur + 1)
    endwhile
    while tabpagenr() > 1
        exe 'tabclose' . a:bang . ' 1'
    endwhile
endfunction

function! TabCloseRight(bang)
    let cur=tabpagenr()
    while cur < tabpagenr('$')
        exe 'tabclose' . a:bang . ' ' . (cur + 1)
    endwhile
endfunction

function! TabCloseLeft(bang)
    while tabpagenr() > 1
        exe 'tabclose' . a:bang . ' 1'
    endwhile
endfunction

command! -bang Tabcloseothers call TabCloseOthers('<bang>')
command! -bang Tabcloseright call TabCloseRight('<bang>')
command! -bang Tabcloseleft call TabCloseLeft('<bang>')
" -------------------------------------------
"  Clip/Session op
" -------------------------------------------
command! ClipRead call ClipRead()

function! ClipRead()
    " let @c = system('cat ' . g:IDE_ENV_CLIP_PATH)
    " echo 'Read '.@c.'to reg c'
    echo system('cat ' . g:IDE_ENV_CLIP_PATH)
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
"  Session Load/Open
" -------------------------------------------
command! SessionStore :call SessionStore()
function! SessionStore()
    let bufcount = bufnr("$")
    let currbufnr = 1

    " let g:IDE_ENV_SESSION_PATH = ${HOME}.'/.vim/session'
    call writefile(['" Vim session file'], g:IDE_ENV_SESSION_PATH, "")
    while currbufnr <= bufcount
        let currbufname = expand('#' . currbufnr . ':p')
        if !empty(glob(currbufname))
            " FIXME delete buffer will also show on the list, remove it in the
            " future
            " echo currbufnr . ": ". currbufname
            " call writefile(['edit ' . currbufname], g:IDE_ENV_SESSION_PATH, "a")
            " use buffer add to accerate speed
            call writefile(['badd ' . currbufname], g:IDE_ENV_SESSION_PATH, "a")
        endif
        let currbufnr = currbufnr + 1
    endwhile
    echo 'Session Stored finished.'
endfunction

command! SessionLoad :call SessionLoad()
function! SessionLoad()
    silent! exec 'source' . g:IDE_ENV_SESSION_PATH
    echo 'Session loaded. BufCnt:'.bufnr("$")
endfunction
command! SessionOpen :call SessionOpen()
function! SessionOpen()
    silent! exec 'source' . g:IDE_ENV_SESSION_PATH
    silent! exec 'tab sball'
    echo 'Session loaded & opened. BufCnt:'.bufnr("$")
endfunction

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

" -------------------------------------------
"  Tags/cscope
" -------------------------------------------
command! TagUpdate call TagUpdate()

function! TagUpdate()
    execute 'cscope reset'
endfunc

command! -nargs=? TagFind :call <SID>TagFind(<q-args>)
function! s:TagFind(tag_name)
    execute 'cs find g ' . a:tag_name
endfunc

" -------------------------------------------
"  Mouse_on_off for cursor chage
" -------------------------------------------
command! ConvertFileProp call ConvertFileProp()

function! ConvertFileProp()
    set ff=unix
    set fileencoding=utf8
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

command! -range FormatCode <line1>,<line2>call FormatCode()
function! FormatCode() range
    " may need to migrate to beautify
    silent! execute a:firstline.','.a:lastline.'s/;/;\r/g'
    silent! execute a:firstline.','.a:lastline.'s/{/{\r/g'
    silent! execute a:firstline.','.a:lastline.'s/}/}\r/g'
endfun

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
"  Select
" -------------------------------------------
command! SelAll call SelAll()
command! SelBlock call SelBlock()

function! SelAll()
    call feedkeys('ggVG')
endfunction
function! SelBlock()
    call feedkeys('[{')
    call feedkeys('V]}')
endfunction
" -------------------------------------------
"  TmpFile
" -------------------------------------------
function! TmpFile()
    tabnew ~/.vim/tmpfile
endfunction
command! TmpFile call TmpFile()

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
command! DisplayColorSchemes call DisplayColorSchemes()
" -------------------------------------------
"  GenerateCachedColorScheme
" -------------------------------------------
function! GenerateCachedColorScheme()
    silent! source ~/.vim/tools/save_colorscheme.vim
endfunction
command! GenerateCachedColorScheme call GenerateCachedColorScheme()

" -------------------------------------------
"  info
" -------------------------------------------
command! Info call Info()

function! Info()
    if empty(glob(expand('%:p')))
        echo 'No file found'
        return 0
    endif
    let sep="\n"
    let msg=printf('%- 16s: %s', 'Path', expand('%:p'))
    let msg=msg . sep . printf('%- 16s: %s', 'Attr ', &fileformat . ', '  . &fileencoding . ', ' . (&expandtab ? 'stab':'htab'))
    let msg=msg . sep . printf('%- 16s: %s', 'Filetype ', &filetype)

    " update buf info
    call IDE_UpdateEnv_BufOpen()
    let proj_path = get(b:, 'IDE_ENV_GIT_PROJECT_PATH', "-1")
    let proj_name = get(b:, 'IDE_ENV_GIT_PROJECT_NAME', "-1")
    let proj_branch = get(b:, 'IDE_ENV_GIT_BRANCH', "")

    if proj_name!=''
        let msg=msg . sep . printf('%- 16s: %s', 'Git Info', (proj_branch == '' ? '':proj_branch . '@'). proj_name)
        let msg=msg . sep . printf('%- 16s: %s', 'Git Path', (proj_path == '' ? './':proj_path))
    endif

    echo msg
endfunc
