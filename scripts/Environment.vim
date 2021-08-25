let IDE_ENV_CURRENT_FUNC = ""
let IDE_ENV_GIT_BRANCH = ""
let IDE_ENV_GIT_PROJECT_NAME = ""

func! IDE_UpdateEnv_CursorHold()
    " let g:IDE_ENV_CURRENT_FUNC = CurrentFunction()
    let g:IDE_ENV_CURRENT_FUNC = tagbar#currenttag('%s ','','f')
endfunc

func! IDE_UpdateEnv_BufEnter()
    let g:IDE_ENV_GIT_BRANCH = system('git branch --show-current | tr -d "\n"')
    let g:IDE_ENV_GIT_PROJECT_NAME = system('git remote -v |grep fetch | rev | cut -d "/" -f 1 | rev | cut -d " " -f 1 | tr -d "\n"')
    let g:IDE_ENV_CURRENT_FUNC = tagbar#currenttag('%s','','f')
endfunc

autocmd CursorHold * :call IDE_UpdateEnv_CursorHold()
autocmd BufEnter * :call IDE_UpdateEnv_BufEnter()

