" Function Settings
" ===========================================
" -------------------------------------------
"  Check for spell
" -------------------------------------------
command! Spellcheck call Spellcheck()
function! Spellcheck()
    setlocal spell
    normal z=
    setlocal nospell
endfunction

" -------------------------------------------
"  Save color scheme
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
command! -nargs=? PureToggle call PureToggle(<f-args>)

function! PureToggle(...)
    let l:mode = get(a:, 1, -1)
    " 0 disable.
    " 1 enable.
    " 2 means reset.
    if l:mode == 2
        let g:pure_toggle_autocmd = 0
        let l:mode = 0
    endif
    "echom 'Mode: '.l:mode. 'Pate:'.&paste. 'narg:'.a:0

    if &paste == 0 && l:mode != 0 || l:mode == 1
        setlocal paste
        " setlocal nocursorline
        setlocal nonumber
        setlocal nolist

        exe "GitGutterDisable"
        exe "NoMatchParen"

        " when not working it, just disable it.
        " 0: init, 1: wait for leave, 2: done.
        if get(g:, 'pure_toggle_autocmd', 0) == 0
            let g:pure_toggle_autocmd = 1
            " FIXME, i'll run twice.
            " autocmd BufLeave,FocusLost,WinLeave <buffer> ++once :silent! PureToggle 2
            autocmd BufLeave,FocusLost,WinLeave <buffer> ++once :PureToggle 2
            echo 'Enable Pure mode, with setup autocmd.'
        else
            echo 'Enable Pure mode'
        endif
    elseif &paste  == 1 || l:mode == 0
        " backup vars
        setlocal nopaste
        " setlocal cursorline
        setlocal number
        setlocal list

        exe "GitGutterEnable"
        exe "DoMatchParen"
        echo 'Disable Pure mode'
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
    let old_name = expand('%:p') " Get absolute path of current file
    " Construct the absolute path for the new file name.
    " This ensures that if a:new_name is relative, it's relative to the original file's directory.
    let new_full_path = fnamemodify(fnamemodify(old_name, ':h') . '/' . a:new_name, ':p')

    if a:new_name != '' && new_full_path != old_name
        " Save the current buffer to the new absolute path
        exec ':saveas ' . new_full_path
        " Rename the original file to a backup name
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

command! -range LogOpen call LogOpen('')
function! LogOpen(filename)
    " ~/.bashrc
    let l:file_name = system('hsexc hs_varconfig -g ${HS_VAR_LOGFILE}')
    " echo file_name
    exec 'tabnew '.l:file_name
endfunc
" -------------------------------------------
"  Tags/cscope
" -------------------------------------------
command! CCTreeSetup call CCTreeSetup()
function! CCTreeSetup()
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

command! -range -nargs=? TrimEmptyLine <line1>,<line2>call TrimEmptyLine(<f-args>)
function! TrimEmptyLine() range
    let line_cnt=get(a:, 0, "0")
    if line_cnt == "0"
        silent! execute a:firstline.','.a:lastline.'s/\(\n\)\n\+/\1/e'
    elseif line_cnt == "1"
        silent! execute a:firstline.','.a:lastline.'s/\(\n\n\)\n\+/\1/e'
    elseif line_cnt == "2"
        silent! execute a:firstline.','.a:lastline.'s/\(\n\n\n\)\n\+/\1/e'
    else
        silent! execute a:firstline.','.a:lastline.'s/\(\n\)\n\+/\1/e'
    endif
    " echo 'First Line:'.a:firstline.', Last Line:'.a:lastline
    " execute a:firstline.','.a:lastline.'s/\n\{2,\}/\n/g'
endfunction

command! -range Beautify <line1>,<line2>call Beautify()
function! Beautify() range

    " This function eim to help those lang is not beautify by =.
    if &filetype ==# 'sh' || &filetype ==# 'bash' || &filetype ==# 'zsh'
        if &expandtab
            silent! execute a:firstline.','.a:lastline.'!shfmt -ci -i 4'
        else
            silent! execute a:firstline.','.a:lastline.'!shfmt -ci'
        endif
    else
        " silent! execute a:firstline.','.a:lastline.'!shfmt -ci'
        echom "Not supported."
        " call feedkeys(a:firstline.','.a:lastline."=")
    endif
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
        if &filetype ==# 'c' || &filetype ==# 'cpp'
            echom "FileType: C/Cpp"
            silent! execute a:firstline.','.a:lastline.' TComment'
            " let l:pattern_cnt=execute(a:firstline.','.a:lastline.'CountPattern *')
            " echom 'Pattern'.l:pattern_cnt
            " if a:lastline - a:firstline + 1 == l:pattern_cnt
            "     silent! execute a:firstline.','.a:lastline.' TComment'
            "     return
            " endif
        else
            " echo 'block'
            silent! execute a:firstline.','.a:lastline.' TCommentBlock'
        endif
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
            " echo 'Pattern not found'
            echo 0
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
        " echom 'Pattern not found'
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
"  Make command
" -------------------------------------------
" Smarter Make Command
" 1. Search upward for 'Makefile'
" 2. Execute make -C <directory>
" 3. Accept arguments (e.g., :M clean, :M all)

function! s:RunMake(args)
    " 1. Search upward for 'Makefile'
    let l:makefile = findfile('Makefile', expand('%:p:h') . ';')
    let l:other_args = ' '
    " let l:other_args = '--no-print-directory'

    " 2. Fallback to current dir if not found
    if l:makefile ==# ''
        echo "Makefile not found! Running make in current dir..."
        let l:cmd = 'make ' . a:args . ' ' . l:other_args
    else
        let l:make_dir = fnamemodify(l:makefile, ':p:h')
        echo "Executing: make -C " . l:make_dir . " " . a:args . ' ' . l:other_args
        let l:cmd = 'make -C ' . l:make_dir . ' ' . a:args . ' ' . l:other_args
    endif

    " 3. Execute make silently (avoid 'Press ENTER') but capture output
    " The '!' prevents jumping to the first error automatically
    execute 'make! ' . substitute(l:cmd, '^make', '', '')

    " if v:shell_error != 0
    "     return
    " endif

    " 4. 【Change here】Always open Quickfix window (height 10)
    botright copen 10

    " 5. Force redraw to clear command line message
    redraw!
    
    " Optional: Print a success message if no errors
    if len(getqflist()) == 0
        echo "Build Success!"
    endif
endfunction

" Define command :M
command! -nargs=* Make call s:RunMake(<q-args>)
" force replace make with Make
cnoreabbrev <expr> make (getcmdtype() == ':' && getcmdline() =~ '^make') ? 'Make' : 'make'

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
    let msg=msg . sep . printf("%s"               , "[Envs/Configs/Defs]")
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_ENV_OS'                      , g:IDE_ENV_OS)
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_ENV_IDE_TITLE'               , g:IDE_ENV_IDE_TITLE)
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_ENV_ROOT_PATH'               , g:IDE_ENV_ROOT_PATH)
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_ENV_CONFIG_PATH'             , g:IDE_ENV_CONFIG_PATH)
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_ENV_HEART_BEAT'              , g:IDE_ENV_HEART_BEAT)

    let msg=msg . sep . printf("%s"               , "[Proj/Sessions]")
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_ENV_PROJ_DATA_PATH'          , g:IDE_ENV_PROJ_DATA_PATH)
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_ENV_PROJ_SCRIPT'             , g:IDE_ENV_PROJ_SCRIPT)
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_ENV_SESSION_AUTOSAVE_PATH'   , g:IDE_ENV_SESSION_AUTOSAVE_PATH)
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_ENV_SESSION_PATH'            , g:IDE_ENV_SESSION_PATH)
    " let msg=msg . sep . printf('    %- 32s: %s' , 'IDE_ENV_SESSION_BOOKMARK_PATH'   , g:IDE_ENV_SESSION_BOOKMARK_PATH)

    let msg=msg . sep . printf("%s"               , "[Args/Vars]")
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_ENV_REQ_TAG_UPDATE '         , g:IDE_ENV_REQ_TAG_UPDATE)
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_ENV_REQ_SESSION_RESTORE'     , g:IDE_ENV_REQ_SESSION_RESTORE)
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_ENV_DEF_PAGE_WIDTH'          , g:IDE_ENV_DEF_PAGE_WIDTH)
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_ENV_DEF_FILE_SIZE_THRESHOLD' , g:IDE_ENV_DEF_FILE_SIZE_THRESHOLD)

    let msg=msg . sep . printf("%s"               , "[Configs]")
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_CFG_PLUGIN_ENABLE '          , g:IDE_CFG_PLUGIN_ENABLE)
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_CFG_AUTOCMD_ENABLE '         , g:IDE_CFG_AUTOCMD_ENABLE)
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_CFG_CACHED_COLORSCHEME '     , g:IDE_CFG_CACHED_COLORSCHEME)
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_CFG_GIT_ENV '                , g:IDE_CFG_GIT_ENV)
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_CFG_SPECIAL_CHARS '          , g:IDE_CFG_SPECIAL_CHARS)
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_CFG_SESSION_AUTOSAVE'        , g:IDE_CFG_SESSION_AUTOSAVE)

    "" Backgorund worker
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_CFG_BACKGROUND_WORKER '      , g:IDE_CFG_BACKGROUND_WORKER)
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_CFG_AUTO_TAG_UPDATE '        , g:IDE_CFG_AUTO_TAG_UPDATE)

    let msg=msg . sep . printf("%s"               , "[Modules]")
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_MDOULE_BOOKMARK '            , g:IDE_MDOULE_BOOKMARK)
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_MDOULE_STATUSLINE '          , g:IDE_MDOULE_STATUSLINE)
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_MDOULE_HIGHLIGHTWORD '       , g:IDE_MDOULE_HIGHLIGHTWORD)

    let msg=msg . sep . printf("%s"               , "[IMPL]")
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_CFG_IMPL_LLM '               , g:IDE_CFG_IMPL_LLM)
    let msg=msg . sep . printf('    %- 32s: %s'   , 'IDE_CFG_IMPL_COMPLETION '        , g:IDE_CFG_IMPL_COMPLETION)

    let msg=msg . sep . printf('')
    let msg=msg . sep . printf('%s: %s', 'Note', 'Use reload command if value not expected on neovim.')

    echo msg
endfunc

command! -nargs=*  IdeConfig call IdeConfig(<f-args>)
function! IdeConfig(...)
    let config_file=g:IDE_ENV_CONFIG_PATH."/ConfigCustomize.vim"

    if !empty(glob(config_file))
        echom "tabnew ". config_file
        exec "tabnew ". config_file
    else
        echom "File not found ". config_file
    endif
endfunction
