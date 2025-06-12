" File: TabGroup.vim
" Description: Manages and maintains tab groups for Vim projects, allowing users to save, load, and switch between different session configurations.

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup AutoTabGroup
    autocmd!
    autocmd VimLeave * :silent! call TabGroupStore()
augroup END

nmap <silent> tl :silent! TabGroupOpenList<CR>
nmap <silent> tn :TabGroupNew<CR>

""""    Variable
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:tabgroup_default_session_path=expand('~')."/.vim/session/tabgroup"
let g:tabgroup_current_group_name='default'
let g:tabgroup_project_folder_name='.vimproject'

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Function
""""""""""""""""""""""""""""""""""""""""""""""""""""""

"  TabGroup Private
" -------------------------------------------
function! TabGroupGetProjectRootPath()
    " Search for .git/.repo/.vimproject for root path and return it.
    let current_dir = getcwd()
    let project_path = ""

    " Define a list of project root markers
    let l:project_markers = [g:tabgroup_project_folder_name]

    " Loop upwards until we find a marker or reach the root
    while current_dir != '/' && !empty(current_dir)
        for marker in l:project_markers
            if isdirectory(current_dir . '/' . marker)
                let project_path = current_dir
                break
            endif
        endfor
        if !empty(project_path)
            break " Found a marker, exit the while loop
        endif
        let current_dir = fnamemodify(current_dir, ':h') " Go up one directory
    endwhile

    return project_path
endfunction

function! TabGroupGetPath(...)
    let l:group_name = g:tabgroup_current_group_name
    if a:0 == 1
        let l:group_name = a:1
    endif

    let project_root_path=TabGroupGetProjectRootPath() . '/' . g:tabgroup_project_folder_name . '/tabgroup'
    let session_path=""
    if project_root_path == ""
        let session_path=g:tabgroup_default_session_path . '/' .l:group_name
    else
        let session_path=project_root_path . '/' .l:group_name
    endif
    return session_path
endfunction

function! TabGroupPrivate_Load(group_name)
    let group_name = a:group_name

    let session_path=TabGroupGetPath(a:group_name)

    " Session path
    let session_file=session_path."/session.vim"

    if empty(glob(session_path)) || !isdirectory(session_path)
        echom "Folder not found. Session: ". session_path
        return v:false
    endif

    " Close all existing tabs and buffers before loading the new session
    silent! %bd!
    tabonly!

    if !empty(glob(session_file))
        silent! exec 'source ' . session_file
        return v:true
    else
        echom "Session load failed. file not found."
        return v:false
    endif
endfunction
function! TabGroupPrivate_Store(group_name)
    let group_name = a:group_name

    let session_path=TabGroupGetPath(group_name)

    if empty(glob(session_path))
        call system('mkdir -p ' . session_path)
    endif

    " Session path
    let session_file=session_path."/session.vim"

    " Vars
    let current_buffer_name=expand('%:p')
    let buf_cnt=0
    let tab_cnt=0

    " Buf variable
    let bufcount = bufnr("$")
    if bufcount == 1 && group_name == 'default'
        echo "Igreno save tab with default group."
        return v:true
    endif

    call writefile(['" Vim session file'], session_file, "")
    call writefile(['" Session open buffer'], session_file, "a")
    call writefile(['""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""'], session_file, "a")

    for each_buf in getbufinfo()
        " echom each_buf.name . '-' . each_buf.lnum
        if !empty(glob(each_buf.name)) && buflisted(each_buf.name) == 1
            call writefile(['badd +'. each_buf.lnum . " " . each_buf.name], session_file, "a")
            let buf_cnt = buf_cnt + 1
        endif
    endfor

    " opened tab
    " FIXME, No win support.
    let tabcount = tabpagenr("$")
    let current_tab_idx = tabpagenr()

    let tabidx = 1
    call writefile(['" Session opened tab'], session_file, "a")
    call writefile(['""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""'], session_file, "a")
    while tabidx <= tabcount
        let tmp_buf_idx = tabpagebuflist(tabidx)[0]
        let currtabname = expand('#' . tmp_buf_idx . ':p')

        " echom 'Tab:'.currtabname.'-'.bufloaded(currtabname).'-'.bufexists(currtabname).'-'.buflisted(currtabname)
        if !empty(glob(currtabname)) && buflisted(currtabname) == 1
            " FIXME, do it on acturally tab.
            exec 'tabn '.tabidx
            " echo 'tabn '.tabidx
            if tab_cnt == 0
                " so we don't have to close the first tab.
                call writefile(['edit +'. line('.') . ' ' . currtabname], session_file, "a")
            else
                call writefile(['tabnew +'. line('.') . ' ' . currtabname], session_file, "a")
            endif
            if current_tab_idx == tabidx
                call writefile(["let session_previous_tabnr=tabpagenr('$')"], session_file, "a")
            endif

            let tab_cnt = tab_cnt + 1
        endif
        let tabidx = tabidx + 1
    endwhile
    exec 'tabn '.current_tab_idx

    call writefile(['" Restore settings'], session_file, "a")
    call writefile(['""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""'], session_file, "a")
    call writefile(['"Open buffer:'. bufname("%")], session_file, "a")
    call writefile(["exe 'tabn ' . session_previous_tabnr" ], session_file, "a")

    return v:true
endfunction

"  TabGroup Public
" -------------------------------------------
command! TabGroupOpenList call TabGroupOpenList()
function! TabGroupOpenList()
    let session_root_path = TabGroupGetPath('')
    " echom "tab group root path: " . session_root_path

    if empty(glob(session_root_path)) || !isdirectory(session_root_path)
        echom "No tab groups root path found: " . session_root_path
        return 0
    endif

    " Get list of subdirectories (group names)
    " glob(pattern, expr, list)
    " expr: 1 for directories only
    " list: 1 for list
    let group_dir_paths = glob(session_root_path . '/*', 1, 1)
    let group_names = []
    for dir_path in group_dir_paths
        if isdirectory(dir_path)
            let group_name = fnamemodify(dir_path, ':t') " Get just the directory name
            call add(group_names, group_name)
        endif
    endfor

    if empty(group_names)
        echom "No tab groups found in: " . session_root_path
        return
    endif

    " Prepare location list entries
    let loc_list = []
    let current_group_idx = -1
    for i in range(len(group_names))
        let group_name = group_names[i]
        if group_name == g:tabgroup_current_group_name
            let current_group_idx = i
            call add(loc_list, {'text': group_name, 'lnum': 1, 'valid': 1}) " Mark current group with lnum 1
        else
            call add(loc_list, {'text': group_name, 'lnum': 0, 'valid': 0})
        endif
    endfor

    " Set and open location list
    call setloclist(0, loc_list, 'r')
    lopen

    " Move cursor to the current group if found
    if current_group_idx != -1
        " The location list is 1-indexed
        call cursor(current_group_idx + 1, 1)
    endif

    " Map <Enter> in the location list window to select the group
    nnoremap <buffer> <CR> :silent! call TabGroupSelectUnderCursor_Load()<CR>
    nnoremap <buffer> d :silent! call TabGroupSelectUnderCursor_Delete()<CR>
endfunction

function! TabGroupSelectUnderCursor_Load()
    " Get the line number in location list window
    let lnum = line('.') - 1
    let group_name = getloclist(0)[lnum].text
    call TabGroupLoad(group_name)
    lclose
endfunction
function! TabGroupSelectUnderCursor_Delete()
    " Get the line number in location list window
    let lnum = line('.') - 1
    let group_name = getloclist(0)[lnum].text
    call TabGroupDelete(group_name)
    lclose
endfunction

command! -nargs=*  TabGroupNew call TabGroupNew(<f-args>)
function! TabGroupNew(...)
    let l:group_name = ""
    if a:0 == 1
        let l:group_name = a:1
    else
        let l:group_name = input("Enter a new group name: ")
        if l:group_name == ''
            return 0
        endif
    endif

    if group_name == g:tabgroup_current_group_name
        echom "Ignore loading the same group(" . group_name . ")"
        return 0
    endif

    " Check if the new group name is the same as the current one
    if l:group_name == g:tabgroup_current_group_name
        " echo "Ignore creating the same group(" . l:group_name . ") as current."
        return 0
    endif

    let session_path=TabGroupGetPath(l:group_name)

    " Check if the group directory already exists
    if isdirectory(session_path)
        echom "Tab group '" . l:group_name . "' already exists at: " . session_path
        return 0 " Return 0 to indicate it wasn't a new creation
    else
        " save previous group.
        silent! call TabGroupStore()
        " Close all existing tabs and buffers before loading the new session
        silent! %bd!
        silent! tabonly!
        echo "\n"
        call TabGroupStore(group_name)
    endif
endfunction

command! -nargs=*  TabGroupStore call TabGroupStore(<f-args>)
function! TabGroupStore(...)
    " accept only 1 args as group_name, if none, use default one.
    let group_name = g:tabgroup_current_group_name
    if a:0 == 1
        let group_name=a:1
    endif

    if TabGroupPrivate_Store(group_name) == v:true
        let g:tabgroup_current_group_name = group_name
        call TabGroupTitle(g:tabgroup_current_group_name)
        echo 'Group ' . group_name . ' Stored finished., Tab:' . tab_cnt . ', Buf:' . buf_cnt. ", File: ". session_path
    else
        echoe 'Group ' . group_name . ' Stored fail.'
        return v:false
    endif
endfunction

command! -nargs=*  TabGroupLoad call TabGroupLoad(<f-args>)
function! TabGroupLoad(...)
    let group_name = g:tabgroup_current_group_name
    if a:0 == 1
        let group_name=a:1
    endif
    if group_name == g:tabgroup_current_group_name
        echom "Ignore loading the same group(" . group_name . ")"
        return 0
    endif

    " before we load group, we store it first. 
    silent! call TabGroupStore()

    if TabGroupPrivate_Load(group_name)
        let g:tabgroup_current_group_name = group_name
        call TabGroupTitle(g:tabgroup_current_group_name)
        echo 'Group ' . group_name . ' loaded. Tab:' . tabpagenr("$") . ', Buf:'.bufnr("$")
        return v:true
    else
        echoe 'Group ' . group_name . ' loade fail.'
        return v:false
    endif
endfunction

command! -nargs=1  TabGroupDelete call TabGroupDelete(<f-args>)
function! TabGroupDelete(group_name)
    if a:group_name == 'default'
        echo 'Can not remove default group.'
        return v:true
    endif

    let session_path=TabGroupGetPath(a:group_name)
    " remove tab_group
    if ! empty(glob(session_path))
        call system('rm -r ' . session_path)
        echo 'Remove ' . a:group_name . ' group on '. session_path
    endif

    let l:group_name='default'

    if TabGroupPrivate_Store(group_name) == v:true
        let g:tabgroup_current_group_name = l:group_name
        call TabGroupTitle(g:tabgroup_current_group_name)
        echo 'Group ' . l:group_name . ' loaded. Tab:' . tabpagenr("$") . ', Buf:'.bufnr("$")
    else
        echoe 'Group ' . group_name . ' Stored fail.'
        return v:false
    endif

endfunction

" -------------------------------------------
"  Title
" -------------------------------------------
function! TabGroupTitle(title_name)
    " FIXME, use more good way to set title.
    let g:IDE_ENV_IDE_TITLE=a:title_name
    if version >= 802
        redrawtabline
    else
        " old version didn't have redrawtabline
        " so use redraw all for it
        redraw!
    endif
endfunc
