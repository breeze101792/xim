""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    initialize
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Source needed scripts
if !empty(glob("~/.vim/Config_Customize.vim"))
    so ~/.vim/Config_Customize.vim
endif

so ~/.vim/vim-ide/core/Config.vim
so ~/.vim/vim-ide/core/Environment.vim
so ~/.vim/vim-ide/core/Settings.vim
so ~/.vim/vim-ide/core/KeyMaps.vim

" utility function related
so ~/.vim/vim-ide/utility/Library.vim
so ~/.vim/vim-ide/utility/Functions.vim
so ~/.vim/vim-ide/utility/CodeEnhance.vim
so ~/.vim/vim-ide/utility/Lab.vim
so ~/.vim/vim-ide/utility/Template.vim

if version >= 704 && g:IDE_CFG_PLUGIN_ENABLE == "y"
    " plugins related
    so ~/.vim/vim-ide/plugin/Plugins.vim
    so ~/.vim/vim-ide/plugin/PluginsConfig.vim
" elseif version < 704
" skip
endif

" -------------------------------------------
"  Refresh
" -------------------------------------------
command! Refresh call Refresh()

func! Refresh()
    so ~/.vim/vim-ide/core/Config.vim
    so ~/.vim/vim-ide/core/Environment.vim
    so ~/.vim/vim-ide/core/Settings.vim
    so ~/.vim/vim-ide/core/KeyMaps.vim

    " utility function related
    so ~/.vim/vim-ide/utility/Library.vim
    so ~/.vim/vim-ide/utility/Functions.vim
    so ~/.vim/vim-ide/utility/CodeEnhance.vim
    so ~/.vim/vim-ide/utility/Lab.vim
    so ~/.vim/vim-ide/utility/Template.vim
endfunc
