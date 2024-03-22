" Adaptation Source
" ===========================================
if has('nvim')
    so ~/.vim/vim-ide/adaptation/Nvim.vim
else
    so ~/.vim/vim-ide/adaptation/Vim.vim
endif

" Adaptation Function
" ===========================================
function! AdpJobStart(commands, callback)
    let l:job = 0
    try
        if has('nvim')
            let l:job = jobstart(a:commands)
        else
            let l:job = job_start(a:commands, { 'callback': a:callback })
        endif
    catch
        echom a:commands." Failed."
    endtry
    return l:job
endfunc

