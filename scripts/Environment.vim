" Buffer Env 
" let b:IDE_ENV_CURRENT_FUNC = ""
" let b:IDE_ENV_GIT_BRANCH = ""
" let b:IDE_ENV_GIT_PROJECT_NAME = ""
" let b:IDE_ENV_GIT_PROJECT_ROOT = ""
func! IDE_UpdateEnv_CursorHold()
    " let b:IDE_ENV_CURRENT_FUNC = CurrentFunction()
    let b:IDE_ENV_CURRENT_FUNC = tagbar#currenttag('%s ','','f')
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
    let b:IDE_ENV_CURRENT_FUNC = tagbar#currenttag('%s','','f')
endfunc

autocmd CursorHold * :call IDE_UpdateEnv_CursorHold()
" autocmd BufEnter * :call IDE_UpdateEnv_BufOpen()
autocmd BufReadPost * :call IDE_UpdateEnv_BufOpen()


