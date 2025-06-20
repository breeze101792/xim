" File: TabGroup.vim
" Description: Manages and maintains tab groups for Vim projects, allowing users to save, load, and switch between different session configurations.

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup AutoTabGroup
    autocmd!
    autocmd VimLeave * :silent! call TabGroupAutoSave()
augroup END

nmap <silent> tl :TabGroupOpenList<CR>
nmap <silent> tn :TabGroupNew<CR>
nmap <silent> ts :TabGroupStore<CR>

""""    Variable
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:tabgroup_default_group_name="_entry_"
let g:tabgroup_default_session_path=expand('~')."/.vim/session/tabgroup"
let g:tabgroup_project_folder_name='.vimproject'
let g:tabgroup_current_group_name=g:tabgroup_default_group_name

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Function
""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  TabGroup Private
" -------------------------------------------
function! TabGroupPrivate_BufKeyMaping()
    " Map <Enter> in the location list window to select the group
    nnoremap <buffer> <CR>  :call TabGroupSelectUnderCursor_Load()<CR>
    nnoremap <buffer> h     :quit<CR>
    nnoremap <buffer> l     :call TabGroupSelectUnderCursor_Load()<CR>
    nnoremap <buffer> d     :call TabGroupSelectUnderCursor_Delete()<CR>
    nnoremap <buffer> r     :call TabGroupSelectUnderCursor_Reload()<CR>
    nnoremap <buffer> <esc> :quit<CR>
endfunc
function! TabGroupPrivate_IsLegalName(group_name)
    " A legal name must consist only of alphanumeric characters and underscores.
    " It must also not be empty.
    if a:group_name =~# '^[a-zA-Z0-9_]\+$'
        return v:true
    else
        return v:false
    endif
endfunction

function! TabGroup_IsModified()
    " Check if any buffer has unsaved changes.
    for buf in getbufinfo()
        if buf.changed
            " echo 'Buffer ' . buf.bufnr . ' (' . buf.name . ') has unsaved changes.'
            return v:true
        endif
    endfor
    return v:false
endfunction

function! TabGroupPrivate_GetProjectRootPath()
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

function! TabGroupPrivate_GetPath(...)
    let l:group_name = g:tabgroup_current_group_name
    if a:0 == 1
        let l:group_name = a:1
    endif

    let project_root_path=TabGroupPrivate_GetProjectRootPath()
    let session_path=""
    if project_root_path == ""
        let session_path=g:tabgroup_default_session_path . '/' .l:group_name
    else
        let l:tab_group_root_path=project_root_path . '/' . g:tabgroup_project_folder_name . '/tabgroup'
        let session_path=l:tab_group_root_path . '/' .l:group_name
    endif
    return session_path
endfunction

function! TabGroupPrivate_Load(group_name)
    let group_name = a:group_name

    let session_path=TabGroupPrivate_GetPath(a:group_name)

    " Session path
    let session_file=session_path."/session.vim"

    if empty(glob(session_path)) || !isdirectory(session_path)
        echom "Folder not found. Session: ". session_path
        return v:false
    endif

    if TabGroup_IsModified()
        echom "Please save change first."
        return v:false
    else
        " Close all existing tabs and buffers before loading the new session
        silent! %bd!
        silent! tabonly!
    endif

    if !empty(glob(session_file))
        silent! exec 'source ' . session_file
        return v:true
    else
        echom "Session load failed. file not found.". session_file
        return v:false
    endif
endfunction

function! TabGroupPrivate_Store(group_name)
    let group_name = a:group_name

    " Validate group name: only allow alphanumeric characters and underscores.
    if !TabGroupPrivate_IsLegalName(l:group_name)
        echom "Error: Tab group name can only contain alphanumeric characters (a-zA-Z0-9) and underscores, and cannot be empty."
        return v:false
    endif

    let session_path=TabGroupPrivate_GetPath(group_name)

    if empty(glob(session_path))
        call system('mkdir -p "' . session_path . '"')
    endif

    " Session path
    let session_file=session_path."/session.vim"

    " Vars
    let current_buffer_name=expand('%:p')
    let buf_cnt=0
    let tab_cnt=0

    " Buf variable
    let bufcount = bufnr("$")
    if bufcount == 1 && group_name == g:tabgroup_default_group_name
        echo "Igreno save tab with " . g:tabgroup_default_group_name ." group."
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
    let tab_buffers = []
    while tabidx <= tabcount
        let buflist_in_tab = tabpagebuflist(tabidx)
        if !empty(buflist_in_tab)
            let main_buf_nr = buflist_in_tab[0] " Get the first buffer in the tab
            let currtabname = expand('#' . main_buf_nr . ':p')
            let buf_info = getbufinfo(main_buf_nr)[0]

            if !empty(glob(currtabname)) && buflisted(currtabname) == 1
                " Store the buffer path and its line number
                call add(tab_buffers, {'path': currtabname, 'lnum': buf_info.lnum})
                let tab_cnt = tab_cnt + 1
            endif
        endif
        let tabidx = tabidx + 1
    endwhile

    " Write commands to open tabs
    for i in range(len(tab_buffers))
        let tab_buf = tab_buffers[i]
        if i == 0
            " For the first tab, use 'edit'
            call writefile(['edit +'. tab_buf.lnum . ' ' . tab_buf.path], session_file, "a")
        else
            " For subsequent tabs, use 'tabnew'
            call writefile(['tabnew +'. tab_buf.lnum . ' ' . tab_buf.path], session_file, "a")
        endif
    endfor

    " Restore to the original active tab
    call writefile(["let session_original_tabnr=" . current_tab_idx], session_file, "a")
    call writefile(["exe 'tabnext ' . session_original_tabnr"], session_file, "a")

    call writefile(['" Restore settings'], session_file, "a")
    call writefile(['""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""'], session_file, "a")
    call writefile(['"Open buffer:'. bufname("%")], session_file, "a")

    return v:true
endfunction

function! TabGroupAutoSave()
    let l:group_name = g:tabgroup_current_group_name
    if l:group_name == ""
        let l:group_name = g:tabgroup_default_group_name
    endif

    if TabGroupPrivate_Store(l:group_name) == v:true
        let g:tabgroup_current_group_name = l:group_name
        " echo 'Group ' . l:group_name . ' Stored finished. Tab:' . tabpagenr("$") . ', Buf:'.bufnr("$")
        return v:true
    else
        echoe 'Group ' . l:group_name . ' Stored fail.'
        return v:false
    endif
endfunction
function! TabGroupSelectUnderCursor_Load()
    " Get the line number in location list window
    let lnum = line('.') - 1
    if lnum == 0
        echo "Don't select title bar."
        " Select to title bar, ignored.
        return
    else
        let group_name = getloclist(0)[lnum].text
        lclose
        call TabGroupLoad(group_name)
    endif
endfunction
function! TabGroupSelectUnderCursor_Delete()
    " Get the line number in location list window (zero-based index)
    let lnum = line('.') - 1

    " Get full location list
    let loclist = getloclist(0)

    " If lnum is out of bounds or title line, do nothing
    if lnum <= 0 || lnum >= len(loclist)
        return
    endif

    " Extract group name
    let l:group_name = loclist[lnum].text
    if l:group_name == g:tabgroup_current_group_name
        " don't let user remove current goup.
        echom "Can't remove the current group."
        return v:false
    endif

    " Call your delete logic
    if TabGroupDelete(l:group_name)
        " Remove the item from the list
        call remove(loclist, lnum)

        let new_lnum = line('.') - 1

        " Refresh the location list (replace mode)
        call setloclist(0, loclist, 'r')

        execute new_lnum

        " when do setlocalist, some how <CR> is been removed, so add it back
        " as workaound.
        " nnoremap <buffer> <CR> :silent! call TabGroupSelectUnderCursor_Load()<CR>
        call TabGroupPrivate_BufKeyMaping()

        " block the current group, so we don't need this. just keep it for
        " reference.
        " let new_idx = TabGroupPrivate_SearchLoclistEntryWithText(g:tabgroup_default_group_name)
        " execute new_idx
    endif

    " Optionally close if list is now empty (only title left)
    if len(loclist) <= 1
        lclose
    endif
endfunction

function! TabGroupSelectUnderCursor_Reload()
    " Get the line number in location list window (zero-based index)
    let lnum = line('.') - 1

    " Get full location list
    let loclist = getloclist(0)

    " If lnum is out of bounds or title line, do nothing
    if lnum <= 0 || lnum >= len(loclist)
        return
    endif

    " Extract group name
    let l:group_name = loclist[lnum].text

    let l:user_check = input('You want to load group without saving current one?(y/N) ')
    if l:user_check =~? '^[yY]\(es\)\?$'
        " Call your load logic, it's only load without save.
        if TabGroupPrivate_Load(l:group_name)
            echo l:group_name . " load successfully."
            lclose
        else
            echom l:group_name . " load failed."
        endif
    endif
endfunction
"  TabGroup Public
" -------------------------------------------
command! TabGroupHelp call TabGroupHelp()
function! TabGroupHelp()
    echom "TabGroup Commands:"
    echom "  :TabGroupOpenList - Open a list of saved tab groups to load, delete, or reload."
    echom "  :TabGroupNew [name] - Create a new tab group. If [name] is not provided, prompts for a name."
    echom "  :TabGroupStore [name] - Save the current tab group. If [name] is not provided, prompts for a name or saves to the current group."
    echom "  :TabGroupLoad [name] - Load a specified tab group. If [name] is not provided, loads the current group."
    echom "  :TabGroupDelete <name> - Delete a specified tab group. Cannot delete the current or default group."
    echom ""
    echom "Key Mappings:"
    echom "  tl - Open tab group list (:TabGroupOpenList)"
    echom "  tn - Create new tab group (:TabGroupNew)"
    echom "  ts - Store current tab group (:TabGroupStore)"
    echom ""
    echom "In Tab Group Selector (location list):"
    echom "  <CR> / l - Load the tab group under the cursor."
    echom "  d - Delete the tab group under the cursor."
    echom "  r - Reload the tab group under the cursor without saving current changes."
    echom "  h / <esc> - Close the tab group selector."
endfunc
command! TabGroupOpenList call TabGroupOpenList()
function! TabGroupOpenList()
    let session_root_path = TabGroupPrivate_GetPath('')
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
    call add(loc_list, {'text': ' -- Tab Group Selector -- ||', 'lnum': 0, 'valid': 0}) " Mark current group with lnum 1
    for i in range(len(group_names))
        let group_name = group_names[i]
        " lnum 2 => foreground, 1 => background.
        if group_name == g:tabgroup_current_group_name
            let current_group_idx = i
            call add(loc_list, {'text': group_name, 'lnum': 2, 'valid': 1}) " Mark current group with lnum 1
        else
            call add(loc_list, {'text': group_name, 'lnum': 1, 'valid': 0})
        endif
    endfor

    " Set and open location list
    call setloclist(0, loc_list, 'r')
    lopen

    " Move cursor to the current group if found
    if current_group_idx != -1
        " The location list is 1-indexed, add one for title bar.
        call cursor(current_group_idx + 1 + 1, 1)
    endif
    call TabGroupPrivate_BufKeyMaping()
endfunction

command! -nargs=*  TabGroupNew call TabGroupNew(<f-args>)
function! TabGroupNew(...)
    let l:group_name = ""
    if a:0 == 1
        let l:group_name = a:1
    else
        let l:group_name = input("Enter a new group name: ")
        echo "\n"
        if l:group_name == ''
            return 0
        endif
        if !TabGroupPrivate_IsLegalName(l:group_name)
            echom "Error: Tab group name can only contain alphanumeric characters (a-zA-Z0-9) and underscores, and cannot be empty."
            return 0
        endif
    endif

    " Check if the new group name is the same as the current one
    if l:group_name == g:tabgroup_current_group_name
        echom "Ignore creating the same group(" . l:group_name . ") as current."
        return 0
    endif

    let session_path=TabGroupPrivate_GetPath(l:group_name)

    " Check if the directory has been taken.
    if ! empty(glob(session_path))
        echom "Tab group '" . l:group_name . "' already exists at: " . session_path
        return 0 " Return 0 to indicate it wasn't a new creation
    else
        " store current group.
        if TabGroupAutoSave() == v:false
            echom "Auto save fail"
            return v:false
        endif
        " check is modified.
        if TabGroup_IsModified()
            echom "Please save change first."
            return v:false
        else
            " Close all existing tabs and buffers before loading the new session
            silent! %bd!
            silent! tabonly!
            echo "\n"
        endif
        call TabGroupStore(l:group_name)
    endif
endfunction

command! -nargs=*  TabGroupStore call TabGroupStore(<f-args>)
function! TabGroupStore(...)
    let l:group_name = ""
    if a:0 == 1
        let l:group_name = a:1
    else
        let l:group_name = input("Enter a name for storing current group(Enter to save in original group.): ")
        echo "\n"
        if l:group_name == ''
            if TabGroupAutoSave()
                echo "Save on " . g:tabgroup_current_group_name
                return v:true
            else
                echom "Save group fail on " . g:tabgroup_current_group_name
                return v:false
            endif
        endif
    endif

    if TabGroupPrivate_Store(l:group_name) == v:true
        let g:tabgroup_current_group_name = l:group_name
        call TabGroupTitle(g:tabgroup_current_group_name)
        echo 'Group ' . l:group_name . ' Stored finished. Tab:' . tabpagenr("$") . ', Buf:'.bufnr("$")
    else
        echoe 'Group ' . l:group_name . ' Stored fail.'
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
        return v:false
    endif

    " before we load group, we store it first. 
    if TabGroupAutoSave() == v:false
        echo 'Auto save fail, please check if there is any unsave change of it.'
        return v:false
    endif

    if TabGroupPrivate_Load(group_name)
        let g:tabgroup_current_group_name = group_name
        call TabGroupTitle(g:tabgroup_current_group_name)
        echo 'Group ' . group_name . ' loaded. Tab:' . tabpagenr("$") . ', Buf:'.bufnr("$")
        return v:true
    else
        echoe 'Group ' . group_name . ' loade fail.'
        " fallback to original file.
        call TabGroupPrivate_Load(g:tabgroup_current_group_name)
        return v:false
    endif
endfunction

command! -nargs=1  TabGroupDelete call TabGroupDelete(<f-args>)
function! TabGroupDelete(group_name)
    if a:group_name == g:tabgroup_default_group_name
        echo 'Can not remove '.g:tabgroup_default_group_name.' group.'
        return v:false
    endif

    if a:group_name == g:tabgroup_current_group_name
        echom "Can not remove current group, please check to other group first."
        return v:false
    endif

    let session_path=TabGroupPrivate_GetPath(a:group_name)
    " remove tab_group
    if ! empty(glob(session_path))
        call system('rm -r ' . session_path)
        echo 'Remove ' . a:group_name . ' group on '. session_path
    endif

    return v:true
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
