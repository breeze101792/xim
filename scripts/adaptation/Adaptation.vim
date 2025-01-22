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
"     " Currently, we don't have anything need to set on linux platform.
"     exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/adaptation/AdpLinux.vim "
endif

" Adaptation Plugins
" ===========================================
if get(g:, 'IDE_CFG_PLUGIN_ENABLE', 'n') == "y"
    exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/adaptation/AdpPlugin.vim "
else
    exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/adaptation/AdpModule.vim "
endif

" Function Adaptation
" ===========================================
" This is for adp layer function, it's more like an adp abstract layer.
exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/adaptation/AdpFunction.vim "
