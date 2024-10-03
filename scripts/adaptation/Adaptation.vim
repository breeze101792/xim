" Adaptation Instance
" ===========================================
if g:IDE_ENV_INS == "nvim"
    " so ~/.vim/vim-ide/adaptation/Nvim.vim
    exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/adaptation/AdpNvim.vim "
else
    " so ~/.vim/vim-ide/adaptation/Vim.vim
    exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/adaptation/AdpVim.vim "
endif

" Adaptation OS
" ===========================================
if g:IDE_ENV_OS == "Darwin"
    exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/adaptation/AdpDarwin.vim "
" else
"     exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/adaptation/AdpVim.vim "
endif

" Function Adaptation
" ===========================================
" Jobs Adaptation
function! AdpJobStart(commands, callback)
    let l:job = 0
    try
        if g:IDE_ENV_INS == "nvim"
            let l:job = jobstart(a:commands)
        else
            let l:job = job_start(a:commands, { 'callback': a:callback })
        endif
    catch
        echom a:commands." Failed."
    endtry
    return l:job
endfunc
