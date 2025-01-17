" Core Settings
" ===========================================
exe 'source ' . g:IDE_ENV_ROOT_PATH . '/scripts/core/Config.vim'
exe 'source ' . g:IDE_ENV_ROOT_PATH . '/scripts/core/Environment.vim'
exe 'source ' . g:IDE_ENV_ROOT_PATH . '/scripts/core/Settings.vim'
exe 'source ' . g:IDE_ENV_ROOT_PATH . '/scripts/core/KeyMaps.vim'

if g:IDE_CFG_AUTOCMD_ENABLE == "y"
    exe 'source ' . g:IDE_ENV_ROOT_PATH . '/scripts/core/Autocmd.vim'
endif
