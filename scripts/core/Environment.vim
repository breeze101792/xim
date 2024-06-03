""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Golobal vim env                            """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Note. Update golbale variable only on functions, to avoid overide on
"" restore variable
if has("nvim")
    let g:IDE_ENV_INS = get(g:, 'IDE_ENV_INS', "nvim")
else
    let g:IDE_ENV_INS = get(g:, 'IDE_ENV_INS', "vim")
endif

let g:IDE_ENV_IDE_TITLE = get(g:, 'IDE_ENV_IDE_TITLE', "VIM")
let g:IDE_ENV_HEART_BEAT = get(g:, 'IDE_ENV_HEART_BEAT', 30000)
let g:IDE_ENV_CACHED_COLORSCHEME = get(g:, 'IDE_ENV_CACHED_COLORSCHEME', "autogen")

if g:IDE_ENV_INS == "nvim"
    let g:IDE_ENV_ROOT_PATH = get(g:, 'IDE_ENV_ROOT_PATH', $HOME."/.config/nvim")
else
    let g:IDE_ENV_ROOT_PATH = get(g:, 'IDE_ENV_ROOT_PATH', $HOME."/.vim")
endif
let g:IDE_ENV_CSCOPE_EXC = get(g:, 'IDE_ENV_CSCOPE_EXC', "cscope")

" Path config

" Centralize path
let g:IDE_ENV_CONFIG_PATH = get(g:, 'IDE_ENV_CONFIG_PATH', $HOME."/.vim")
let g:IDE_ENV_CLIP_PATH = get(g:, 'IDE_ENV_CLIP_PATH', g:IDE_ENV_CONFIG_PATH."/clip")

" NOTE. This need to set it on runtime
let g:IDE_ENV_PROJ_DATA_PATH = get(g:, 'IDE_ENV_PROJ_DATA_PATH', "./")
let g:IDE_ENV_PROJ_SCRIPT = get(g:, 'IDE_ENV_PROJ_SCRIPT', "")

" Deprecated.
let g:IDE_ENV_TAGS_DB = get(g:, 'IDE_ENV_TAGS_DB', "")
let g:IDE_ENV_CSCOPE_DB = get(g:, 'IDE_ENV_CSCOPE_DB', "")
let g:IDE_ENV_CCTREE_DB = get(g:, 'IDE_ENV_CCTREE_DB', "")

" Session
let g:IDE_ENV_SESSION_AUTOSAVE_PATH = get(g:, 'IDE_ENV_SESSION_AUTOSAVE_PATH', g:IDE_ENV_CONFIG_PATH."/session_autosave")
let g:IDE_ENV_SESSION_PATH = get(g:, 'IDE_ENV_SESSION_PATH', g:IDE_ENV_CONFIG_PATH."/session")

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Golobal vim var                           """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:IDE_ENV_REQ_TAG_UPDATE=0
let g:IDE_ENV_REQ_SESSION_RESTORE=""

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Functions of env                          """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""

"" Buffer Env
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" This is for local buffer env.
" let b:IDE_ENV_CURRENT_FUNC     = ""
" let b:IDE_ENV_GIT_BRANCH       = ""
" let b:IDE_ENV_GIT_PROJECT_NAME = ""
" let b:IDE_ENV_GIT_PROJECT_PATH = ""

"" Buffer Functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! IDE_EnvSetup_Proj()
    if !empty(glob(g:IDE_ENV_PROJ_DATA_PATH."/proj.vim"))
        execute 'source '.g:IDE_ENV_PROJ_DATA_PATH."/proj.vim"
        let g:IDE_ENV_SESSION_PATH = g:IDE_ENV_PROJ_DATA_PATH."/session"
        let g:IDE_ENV_SESSION_AUTOSAVE_PATH = g:IDE_ENV_PROJ_DATA_PATH."/session_autosave"
    else
        let g:IDE_ENV_SESSION_AUTOSAVE_PATH = g:IDE_ENV_CONFIG_PATH."/session_autosave"
        let g:IDE_ENV_SESSION_PATH = g:IDE_ENV_CONFIG_PATH."/session"
    endif
endfunc

function! IDE_EnvSetup()
    "" NOTE. Don't start any function here.

    ""    Proj Setup
    """"""""""""""""""""""""""""""""""""""""""""""""""""""
    if $VIDE_SH_PROJ_DATA_PATH != ""
        let g:IDE_ENV_PROJ_DATA_PATH = $VIDE_SH_PROJ_DATA_PATH
    else
        let g:IDE_ENV_PROJ_DATA_PATH = ""
    endif
    if $VIDE_SH_TAGS_DB != ""
        let g:IDE_ENV_TAGS_DB = $VIDE_SH_TAGS_DB
    else
        let g:IDE_ENV_TAGS_DB = ""
    endif
    if $VIDE_SH_CSCOPE_DB != ""
        let g:IDE_ENV_CSCOPE_DB = $VIDE_SH_CSCOPE_DB
    else
        let g:IDE_ENV_CSCOPE_DB = ""
    endif
    if $VIDE_SH_CCTREE_DB != ""
        let g:IDE_ENV_CCTREE_DB = $VIDE_SH_CCTREE_DB
    else
        let g:IDE_ENV_CCTREE_DB = ""
    endif
    if $VIDE_SH_PROJ_SCRIPT != ""
        let g:IDE_ENV_PROJ_SCRIPT = $VIDE_SH_PROJ_SCRIPT
    else
        let g:IDE_ENV_PROJ_SCRIPT = ""
    endif

    if $VIDE_SH_SESSION_RESTORE != ""
        let g:IDE_ENV_REQ_SESSION_RESTORE = $VIDE_SH_SESSION_RESTORE
    else
        let g:IDE_ENV_REQ_SESSION_RESTORE = ""
    endif

    " Project Script setup
    call IDE_EnvSetup_Proj()

    ""    Others
    """"""""""""""""""""""""""""""""""""""""""""""""""""""
    " if $VIDE_SH_TMP != ""
    "     let g:IDE_ENV_TMP = "y"
    " else
    "     let g:IDE_ENV_TMP = "n"
    " endif

    ""    NVIM
    """"""""""""""""""""""""""""""""""""""""""""""""""""""
    if g:IDE_ENV_INS == "nvim"
        let g:IDE_ENV_IDE_TITLE = "NVIM"

        let g:IDE_ENV_CSCOPE_EXC = "Cscope"
    endif
endfunction
function! IDE_UpdateEnv_CursorHold()
    " if g:IDE_CFG_PLUGIN_ENABLE == "y" && exists('*tagbar#currenttag')
    if g:IDE_CFG_PLUGIN_ENABLE == "y"
        try
            let b:IDE_ENV_CURRENT_FUNC = tagbar#currenttag('%s','','f')
        catch
            let b:IDE_ENV_CURRENT_FUNC = CurrentFunction()
        endtry

        " Ignore ctrlp
        if &filetype != 'ctrlp'
            call lightline#update()
        endif
    else
        let b:IDE_ENV_CURRENT_FUNC = CurrentFunction()
    endif

endfunc

command! UpdateBufInfo call IDE_UpdateEnv_BufOpen(1)
function! IDE_UpdateEnv_BufOpen(...)
    let l:file_name = expand("%:p")
    if a:0 == 1
        echom "Force update buffer info. ".b:IDE_ENV_BUF_UPDATED
        let b:IDE_ENV_BUF_UPDATED = a:1
    else
        let b:IDE_ENV_BUF_UPDATED = get(b:, 'IDE_ENV_BUF_UPDATED', "0")
    endif

    if b:IDE_ENV_BUF_UPDATED == 1 || file_name == "" || empty(glob(file_name))
        return
    endif

    if g:IDE_CFG_GIT_ENV == "y"
        " FIXME, git above git 2.22.0 support --show-current
        " let b:IDE_ENV_GIT_BRANCH = system('git branch --show-current 2> /dev/null | tr -d "\n"')
        let l:current_path = expand("%:p:h")
        let b:IDE_ENV_GIT_BRANCH = system('cd '.l:current_path.'; git rev-parse --abbrev-ref HEAD 2> /dev/null | sed "s/^HEAD$//g" | tr -d "\n"')
        let b:IDE_ENV_GIT_PROJECT_NAME = system('cd '.l:current_path.'; git remote -v 2> /dev/null |grep fetch | sed "s/\/ / /g" | rev | cut -d "/" -f 1 | rev | cut -d " " -f 1 | tr -d "\n"')
        " FIXME file on git path will should return ./
        let b:IDE_ENV_GIT_PROJECT_PATH = system('cd '.l:current_path.'; git rev-parse --show-prefix 2> /dev/null | cut -d " " -f 1 | tr -d "\n"')
    else
        let b:IDE_ENV_GIT_BRANCH = ""
        let b:IDE_ENV_GIT_PROJECT_NAME = ""
        let b:IDE_ENV_GIT_PROJECT_PATH = ""
    endif

    if g:IDE_CFG_PLUGIN_ENABLE == "y"
        try
            let b:IDE_ENV_CURRENT_FUNC = tagbar#currenttag('%s','','f')
        catch
            let b:IDE_ENV_CURRENT_FUNC = ''
        endtry
    else
        let b:IDE_ENV_CURRENT_FUNC = CurrentFunction()
    endif

    " NOTE. We only run this onces.
    let b:IDE_ENV_BUF_UPDATED = 1
endfunc
