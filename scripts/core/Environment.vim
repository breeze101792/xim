""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Golobal vim env                            """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:IDE_ENV_IDE_TITLE = get(g:, 'IDE_ENV_IDE_TITLE', "VIM")
let g:IDE_ENV_CSCOPE_DB = get(g:, 'IDE_ENV_CSCOPE_DB', "")
let g:IDE_ENV_CCTREE_DB = get(g:, 'IDE_ENV_CCTREE_DB', "")
let g:IDE_ENV_PROJ_SCRIPT = get(g:, 'IDE_ENV_PROJ_SCRIPT', "")

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
func! IDE_UpdateEnv_CursorHold()
    " let b:IDE_ENV_CURRENT_FUNC = CurrentFunction()
    if g:IDE_CFG_PLUGIN_ENABLE == "y"
        let b:IDE_ENV_CURRENT_FUNC = tagbar#currenttag('%s','','f')
    else
        let b:IDE_ENV_CURRENT_FUNC = CurrentFunction()
    endif
endfunc

func! IDE_UpdateEnv_BufOpen()
    if g:IDE_CFG_GIT_ENV == "y"
        let b:IDE_ENV_GIT_BRANCH = system('git branch --show-current 2> /dev/null | tr -d "\n"')
        let b:IDE_ENV_GIT_PROJECT_NAME = system('git remote -v 2> /dev/null |grep fetch | sed "s/\/ / /g" | rev | cut -d "/" -f 1 | rev | cut -d " " -f 1 | tr -d "\n"')
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

augroup environment_gp
    autocmd!
    autocmd CursorHold * :call IDE_UpdateEnv_CursorHold()
    " autocmd BufEnter * :call IDE_UpdateEnv_BufOpen()
    autocmd BufReadPost * :call IDE_UpdateEnv_BufOpen()
augroup END
