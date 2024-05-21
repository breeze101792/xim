" Commands Settings
" ===========================================
" command! -nargs=1 Count :%s/<args>//n

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
"  Mouse_on_off for cursor chage
" -------------------------------------------
command! SaveColorscheme call SaveColorscheme()

function! SaveColorscheme()
    " source ~/.vim/tools/save_colorscheme.vim
    execute 'source '.g:IDE_ENV_ROOT_PATH."/tools/save_colorscheme.vim"
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
        exe "DoMatchParen"
        set cursorline
    endif
    " if exists(":NoMatchParen")
    "     " reenable matchparent
    "     " :DoMatchParen
    "     :NoMatchParen

    " endif
endfunc
" -------------------------------------------
"  Get Syntax name
" -------------------------------------------
" a little more informative version of the above
command! SynStack call SynStack()
function! SynStack()
	if !exists("*synstack")
		return
	endif
	echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
" -------------------------------------------
"  Pure mode
" -------------------------------------------
command! PureToggle call PureToggle()

function! PureToggle()

    if &paste
        echo 'Disable Pure mode'
        " backup vars
        setlocal nopaste
        " setlocal cursorline
        setlocal number
        setlocal list

        exe "GitGutterEnable"
        exe "DoMatchParen"

    else
        echo 'Enable Pure mode'
        setlocal paste
        " setlocal nocursorline
        setlocal nonumber
        setlocal nolist

        exe "GitGutterDisable"
        exe "NoMatchParen"

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
        echom "Save debug file in ". &verbosefile
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

function! TabGo(tabname)

    let tabcount = tabpagenr("$")
    let currenttabidx = 1
    call writefile(['" Session opened tab'], g:IDE_ENV_SESSION_PATH, "a")
    call writefile(['""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""'], g:IDE_ENV_SESSION_PATH, "a")
    while currenttabidx <= tabcount
        let currtabname = expand('#' . currenttabidx)

        if tabname == currtabname
            exe 'tabclose' . a:bang . ' 1'
            break
        endif
        let currenttabidx = currenttabidx + 1
    endwhile
endfunction

command! -bang Tabcloseothers call TabCloseOthers('<bang>')
command! -bang Tabcloseright call TabCloseRight('<bang>')
command! -bang Tabcloseleft call TabCloseLeft('<bang>')

" -------------------------------------------
"  Tags/cscope
" -------------------------------------------
command! TreeSetup call TreeSetup()
function! TreeSetup()
    try
        if g:IDE_ENV_CCTREE_DB != ''
            echo "Update cctree db from " . g:IDE_ENV_CCTREE_DB
            execute "CCTreeLoadXRefDB ".g:IDE_ENV_CCTREE_DB
        elseif g:IDE_ENV_CSCOPE_DB != ''
            echo "Update cctree db from " . g:IDE_ENV_CSCOPE_DB
            execute "CCTreeLoadDB ".g:IDE_ENV_CSCOPE_DB
        else
            echo "Update cctree db from buffer"
            execute "CCTreeLoadBufferUsingTag "
        endif
    catch
        echoe "Fail to setup CCTree"
    endtry
endfunc

" command! TagUpdate call TagUpdate()
" function! TagUpdate()
"     try
"         execute g:IDE_ENV_CSCOPE_EXC.' reset'
"     catch
"         if g:IDE_ENV_CSCOPE_DB != ''
"             " echo "Open "g:IDE_ENV_CSCOPE_DB
"             execute g:IDE_ENV_CSCOPE_EXC." add ".g:IDE_ENV_CSCOPE_DB
"         endif
"         if g:IDE_ENV_CCTREE_DB != ''
"             " echo "Open "g:IDE_ENV_CCTREE_DB
"             execute "CCTreeLoadXRefDB ".g:IDE_ENV_CCTREE_DB
"         endif
"     endtry
" endfunc
"
command! TagSetup call TagSetup()
function! TagSetup()
    " May need to setup by search for db file in vim
    try
        " Reset tags
        silent! execute g:IDE_ENV_CSCOPE_EXC." reset "
        "" Add Tag by project
        " Setup cscope db
        if g:IDE_ENV_PROJ_DATA_PATH != ""
            let l:cscope_db_list=system('ls -1 '.g:IDE_ENV_PROJ_DATA_PATH.'/cscope*.db')
            silent! execute g:IDE_ENV_CSCOPE_EXC." reset "
            for each_db in split(l:cscope_db_list, '\n')
                " echom each_db
                silent! execute g:IDE_ENV_CSCOPE_EXC." add ".each_db
            endfor
        endif
        " Add tags
        if !empty(glob(g:IDE_ENV_PROJ_DATA_PATH."/tags"))
            silent! execute "set tags=".g:IDE_ENV_PROJ_DATA_PATH."/tags"
        endif

        " Legacy tag
        " FIXME Need to be removed
        " {
        "     if g:IDE_ENV_TAGS_DB != ''
        "         " echo "Open ".g:IDE_ENV_TAGS_DB
        "         execute "set tags=".g:IDE_ENV_TAGS_DB
        "     endif
        "     if g:IDE_ENV_CSCOPE_DB != ''
        "         " echo "Open "g:IDE_ENV_CSCOPE_DB
        "         execute g:IDE_ENV_CSCOPE_EXC."  add ".g:IDE_ENV_CSCOPE_DB
        "     endif
        "     }

        " cctree
        if g:IDE_ENV_CCTREE_DB != ''
            " echo "Open ".g:IDE_ENV_CCTREE_DB
            silent! execute "CCTreeLoadXRefDB" . g:IDE_ENV_CCTREE_DB
        endif
        " cctree will only enable when specify
        " if !empty(glob(g:IDE_ENV_PROJ_DATA_PATH."/cctree.db"))
        "     silent! execute "CCTreeLoadXRefDB ".g:IDE_ENV_PROJ_DATA_PATH."/cctree.db"
        " endif
        if g:IDE_ENV_PROJ_SCRIPT != ''
            " echo "Source ".g:IDE_ENV_PROJ_SCRIPT
            execute 'source' . g:IDE_ENV_PROJ_SCRIPT
        endif


    catch

    endtry
endfunc

command! TagUpdate call TagUpdate()

function! TagUpdate()
    function! TagUpdateHandler(ch, msg)
        " call TagUpdate()
        call TagSetup()

        " This is for auto update system
        let g:IDE_ENV_REQ_TAG_UPDATE = 0
        echom 'Tag update complete. '.a:ch.' '.a:msg
    endfunc
    let g:IDE_ENV_REQ_TAG_UPDATE = 2
    try
        " FIXME, it will not call back on nvim
        " Sleep is for avoiding write conflit with vim itself
        if executable("xim")
            call AdpJobStart('xim update', 'TagUpdateHandler')
        else
            echom "Xim not found, use legacy mode."
            call AdpJobStart('hsexc pvupdate', 'TagUpdateHandler')
        endif
    catch
        echom "TagUpdate Failed, Please check if hsexc exist."
        let g:IDE_ENV_REQ_TAG_UPDATE = 0
    endtry
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

command! -range CommentCodeBlock <line1>,<line2>TCommentBlock
command! -range CommentCode <line1>,<line2>call CommentCode()
function! CommentCode() range
    " echo 'comment'.a:firstline.','.a:lastline

    if a:lastline - a:firstline == 0
        silent! TComment
    else
        " echo &filetype
        " if &filetype ==# 'c' || &filetype ==# 'cpp'
        "     let l:pattern_cnt=execute(a:firstline.','.a:lastline.'CountPattern *')
        "     echom 'Pattern'.l:pattern_cnt
        "     if a:lastline - a:firstline + 1 == l:pattern_cnt
        "         silent! execute a:firstline.','.a:lastline.' TComment'
        "         return
        "     endif
        " endif
        " echo 'block'
        silent! execute a:firstline.','.a:lastline.' TCommentInline'
    endif
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
"  CountPattern
" -------------------------------------------
command! -range -nargs=? CountPattern <line1>,<line2>call CountPattern(<q-args>)
function! CountPattern(pattern) range
    " echom 'Start->'.a:pattern.'<-'
    try
        let match_ret=execute(a:firstline.','.a:lastline.'s/'.a:pattern.'/ /n')

        let token=split(match_ret[1:], ' ')
        if len(token) < 4
            echo 'Pattern not found'
            return 0
        endif

        let pattern_matches=token[0]
        let line_matches=token[3]
        let test=char2nr(pattern_matches[0])
        " echo 'word:'.pattern_matches.', lines:'.line_matches
        " echo 'pattern:'.pattern_matches
        echo pattern_matches
        return pattern_matches

    catch
        echom 'Pattern not found'
        echo 0
        return 0
    endtry
endfunc


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
command! IdeInfo call IdeInfo()

function! IdeInfo()
    let sep="\n"
    let msg="IDE Information"
    let msg=msg . sep . printf("%s", "[Envs/Configs]")
    let msg=msg . sep . printf('    %- 32s: %s', 'IDE_ENV_IDE_TITLE', g:IDE_ENV_IDE_TITLE)
    let msg=msg . sep . printf('    %- 32s: %s', 'IDE_ENV_ROOT_PATH', g:IDE_ENV_ROOT_PATH)
    let msg=msg . sep . printf('    %- 32s: %s', 'IDE_ENV_CONFIG_PATH', g:IDE_ENV_CONFIG_PATH)
    let msg=msg . sep . printf('    %- 32s: %s', 'IDE_ENV_HEART_BEAT', g:IDE_ENV_HEART_BEAT)

    let msg=msg . sep . printf("%s", "[Proj/Sessions]")
    let msg=msg . sep . printf('    %- 32s: %s', 'IDE_ENV_PROJ_DATA_PATH', g:IDE_ENV_PROJ_DATA_PATH)
    let msg=msg . sep . printf('    %- 32s: %s', 'IDE_ENV_PROJ_SCRIPT', g:IDE_ENV_PROJ_SCRIPT)
    let msg=msg . sep . printf('    %- 32s: %s', 'IDE_ENV_SESSION_PATH', g:IDE_ENV_SESSION_PATH)
    let msg=msg . sep . printf('    %- 32s: %s', 'IDE_ENV_SESSION_AUTOSAVE_PATH', g:IDE_ENV_SESSION_AUTOSAVE_PATH)
    let msg=msg . sep . printf('    %- 32s: %s', 'IDE_ENV_SESSION_MARK_PATH', g:IDE_ENV_SESSION_MARK_PATH)
    " let msg=msg . sep . printf('    %- 32s: %s', 'IDE_ENV_SESSION_BOOKMARK_PATH', g:IDE_ENV_SESSION_BOOKMARK_PATH)

    let msg=msg . sep . printf("%s", "[Args/Vars]")
    let msg=msg . sep . printf('    %- 32s: %s', 'IDE_ENV_REQ_TAG_UPDATE ', g:IDE_ENV_REQ_TAG_UPDATE)
    let msg=msg . sep . printf('    %- 32s: %s', 'IDE_ENV_REQ_SESSION_RESTORE', g:IDE_ENV_REQ_SESSION_RESTORE)

    let msg=msg . sep . printf("%s", "[Configs]")
    let msg=msg . sep . printf('    %- 32s: %s', 'IDE_CFG_CACHED_COLORSCHEME ', g:IDE_CFG_CACHED_COLORSCHEME)
    let msg=msg . sep . printf('    %- 32s: %s', 'IDE_CFG_GIT_ENV ', g:IDE_CFG_GIT_ENV)
    let msg=msg . sep . printf('    %- 32s: %s', 'IDE_CFG_PLUGIN_ENABLE ', g:IDE_CFG_PLUGIN_ENABLE)
    let msg=msg . sep . printf('    %- 32s: %s', 'IDE_CFG_SPECIAL_CHARS ', g:IDE_CFG_SPECIAL_CHARS)
    let msg=msg . sep . printf('    %- 32s: %s', 'IDE_CFG_SESSION_AUTOSAVE', g:IDE_CFG_SESSION_AUTOSAVE)

    "" Backgorund worker
    let msg=msg . sep . printf('    %- 32s: %s', 'IDE_CFG_BACKGROUND_WORKER ', g:IDE_CFG_BACKGROUND_WORKER)
    let msg=msg . sep . printf('    %- 32s: %s', 'IDE_CFG_AUTO_TAG_UPDATE ', g:IDE_CFG_AUTO_TAG_UPDATE)

    echo msg
endfunc
