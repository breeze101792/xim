" File: ProjectManager.vim
" Description: Manager project.

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO, add autocommand for loading project file(proj.vim).
" currently we only use this for create project folder.
augroup ProjectManagerGroup
    autocmd!
    autocmd VimEnter * :silent! call ProjectManagerReload()
augroup END

""""    Variable
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:projectmanager_project_folder_name='.vimproject'
let g:projectmanager_project_config_name='proj.vim'
let g:projectmanager_project_markers=[g:projectmanager_project_folder_name, '.repo', '.git']
let g:projectmanager_current_project_root=''

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Function
""""""""""""""""""""""""""""""""""""""""""""""""""""""

"  Private Functions
" -------------------------------------------
function! ProjectManager_GetProjectRootPath()
    if get(g:, 'projectmanager_debug', 0)
        echom "ProjectManager_GetProjectRootPath: starting"
    endif
    " Search for .git/.repo/.vimproject for root path and return it.
    let l:start_dir = getcwd()
    if get(g:, 'projectmanager_debug', 0)
        echom "ProjectManager_GetProjectRootPath: start_dir=" . l:start_dir
    endif
    let project_path = ""

    " Define a list of project root markers
    let l:project_markers = g:projectmanager_project_markers
    if get(g:, 'projectmanager_debug', 0)
        echom "ProjectManager_GetProjectRootPath: project_markers=" . string(l:project_markers)
    endif

    " Loop upwards until we find a marker or reach the root
    for marker in l:project_markers
        if get(g:, 'projectmanager_debug', 0)
            echom "ProjectManager_GetProjectRootPath: checking marker=" . marker
        endif
        let current_dir = l:start_dir
        while current_dir != '/' && !empty(current_dir)
            if get(g:, 'projectmanager_debug', 0)
                echom "ProjectManager_GetProjectRootPath: checking dir=" . current_dir . " for marker " . marker
            endif
            if isdirectory(current_dir . '/' . marker)
                let project_path = current_dir
                if get(g:, 'projectmanager_debug', 0)
                    echom "ProjectManager_GetProjectRootPath: found project_path=" . project_path
                endif
                break
            endif
            let current_dir = fnamemodify(current_dir, ':h') " Go up one directory
        endwhile
        if !empty(project_path)
            break " Found a marker, exit the for loop
        endif
    endfor

    if get(g:, 'projectmanager_debug', 0)
        echom "ProjectManager_GetProjectRootPath: returning project_path=" . project_path
    endif
    return project_path
endfunction

"  Public Functions
" -------------------------------------------

command! ProjectManagerInit call ProjectManagerInit()
function! ProjectManagerInit()
    let l:project_root = ProjectManager_GetProjectRootPath()

    if empty(l:project_root)
        echom "No project root found.". l:project_root
        return
    endif

    let l:project_config_dir = l:project_root . '/' . g:projectmanager_project_folder_name

    if isdirectory(l:project_config_dir)
        " Project config directory already exists, do nothing
        echom "Project config directory already exists: " . l:project_config_dir
        return
    else
        " Project config directory does not exist, create it
        call mkdir(l:project_config_dir, "p")
        " echom "Created project config directory: " . l:project_config_dir
    endif

    let l:project_config_file = l:project_config_dir . '/' . g:projectmanager_project_config_name

    if !filereadable(l:project_config_file)
        " Project config file does not exist, create it
        call writefile([], l:project_config_file)
        " echom "Created project config file: " . l:project_config_file
    else
        " Project config file already exists, do nothing
        echom "Project config file already exists: " . l:project_config_file
    endif

    echom "Init project on " . l:project_root
endfunc

command! ProjectManagerEditConfig call ProjectManagerEditConfig()
function! ProjectManagerEditConfig()
    let l:project_root = ProjectManager_GetProjectRootPath()
    let l:project_config_dir = l:project_root . '/' . g:projectmanager_project_folder_name
    let l:project_config_file = l:project_config_dir . '/' . g:projectmanager_project_config_name

    if !filereadable(l:project_config_file)
        echom "Project config file does not exist or is not readable: " . l:project_config_file
        return
    else
        " Open the project config file for editing
        execute 'edit ' . l:project_config_file
    endif
endfunc

command! ProjectManagerReload call ProjectManagerReload()
function! ProjectManagerReload()
    let l:project_root = ProjectManager_GetProjectRootPath()
    let l:project_config_dir = l:project_root . '/' . g:projectmanager_project_folder_name
    let l:project_config_file = l:project_config_dir . '/' . g:projectmanager_project_config_name

    if !filereadable(l:project_config_file)
        echo "Project config file does not exist or is not readable: " . l:project_config_file
        return
    else
        " Source the project config file for editing
        silent! exec 'source ' . l:project_config_file
    endif
endfunc

