""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Golobal vim env                            """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:IDE_ENV_IDE_TITLE = get(g:, 'IDE_ENV_IDE_TITLE', "VIM")
let g:IDE_ENV_CSCOPE_DB = get(g:, 'IDE_ENV_CSCOPE_DB', "")
let g:IDE_ENV_CCTREE_DB = get(g:, 'IDE_ENV_CCTREE_DB', "")
let g:IDE_ENV_PROJ_SCRIPT = get(g:, 'IDE_ENV_PROJ_SCRIPT', "")

" Path config
let g:IDE_ENV_CONFIG_PATH = get(g:, 'IDE_ENV_CONFIG_PATH', $HOME."/.vim")
" let g:IDE_ENV_SESSION_PATH = get(g:, 'IDE_ENV_SESSION_PATH', $HOME."/.vim/session")
let g:IDE_ENV_SESSION_PATH = get(g:, 'IDE_ENV_SESSION_PATH', g:IDE_ENV_CONFIG_PATH."/session")
let g:IDE_ENV_CLIP_PATH = get(g:, 'IDE_ENV_CLIP_PATH', g:IDE_ENV_CONFIG_PATH."/clip")

if $VIDE_SH_CSCOPE_DB != ""
    let g:IDE_ENV_CSCOPE_DB = $VIDE_SH_CSCOPE_DB
endif
if $VIDE_SH_CCTREE_DB != ""
    let g:IDE_ENV_CCTREE_DB = $VIDE_SH_CCTREE_DB
endif
if $VIDE_SH_PROJ_SCRIPT != ""
    let g:IDE_ENV_PROJ_SCRIPT = $VIDE_SH_PROJ_SCRIPT
endif
" if $VIDE_SH_TMP != ""
"     let g:IDE_ENV_TMP = "y"
" else
"     let g:IDE_ENV_TMP = "n"
" endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Functions of env                          """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Buffer Env 
" let b:IDE_ENV_CURRENT_FUNC = ""
" let b:IDE_ENV_GIT_BRANCH = ""
" let b:IDE_ENV_GIT_PROJECT_NAME = ""
" let b:IDE_ENV_GIT_PROJECT_ROOT = ""
function! IDE_UpdateEnv_CursorHold()
    " let b:IDE_ENV_CURRENT_FUNC = CurrentFunction()
    if g:IDE_CFG_PLUGIN_ENABLE == "y"
        let b:IDE_ENV_CURRENT_FUNC = tagbar#currenttag('%s','','f')
    else
        let b:IDE_ENV_CURRENT_FUNC = CurrentFunction()
    endif
endfunc

function! IDE_UpdateEnv_BufOpen()
    if g:IDE_CFG_GIT_ENV == "y"
        " FIXME, git above git 2.22.0 support --show-current
        " let b:IDE_ENV_GIT_BRANCH = system('git branch --show-current 2> /dev/null | tr -d "\n"')
        let b:IDE_ENV_GIT_BRANCH = system('git rev-parse --abbrev-ref HEAD 2> /dev/null | sed "s/^HEAD$//g" | tr -d "\n"')
        let b:IDE_ENV_GIT_PROJECT_NAME = system('git remote -v 2> /dev/null |grep fetch | sed "s/\/ / /g" | rev | cut -d "/" -f 1 | rev | cut -d " " -f 1 | tr -d "\n"')
        " FIXME file on git root will should return ./
        let b:IDE_ENV_GIT_PROJECT_ROOT = system('git rev-parse --show-prefix 2> /dev/null | cut -d " " -f 1 | tr -d "\n"')
    else
        let b:IDE_ENV_GIT_BRANCH = ""
        let b:IDE_ENV_GIT_PROJECT_NAME = ""
        let b:IDE_ENV_GIT_PROJECT_ROOT = ""
    endif
    if g:IDE_CFG_PLUGIN_ENABLE == "y"
        let b:IDE_ENV_CURRENT_FUNC = tagbar#currenttag('%s','','f')
    else
        let b:IDE_ENV_CURRENT_FUNC = CurrentFunction()
    endif
endfunc
