""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    initialize
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Source needed scripts
if !empty(glob("~/.vim/ConfigCustomize.vim"))
    so ~/.vim/ConfigCustomize.vim
else
    " TODO remove it
    if !empty(glob("~/.vim/Config_Customize.vim"))
        so ~/.vim/Config_Customize.vim
    endif
endif

so ~/.vim/vim-ide/core/Config.vim
so ~/.vim/vim-ide/core/Environment.vim
so ~/.vim/vim-ide/core/Settings.vim
so ~/.vim/vim-ide/core/Autocmd.vim

" Adaptation layer
so ~/.vim/vim-ide/adaptation/Adaptation.vim

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

so ~/.vim/vim-ide/core/KeyMaps.vim

" -------------------------------------------
"  Reload
" -------------------------------------------
command! Reload call Reload()
command! Refresh call Reload()

func! Reload()
    so ~/.vim/vim-ide/core/Config.vim
    so ~/.vim/vim-ide/core/Environment.vim
    so ~/.vim/vim-ide/core/Settings.vim
    so ~/.vim/vim-ide/core/Autocmd.vim

    " Adaptation layer
    so ~/.vim/vim-ide/utility/Adaptation.vim

    " utility function related
    so ~/.vim/vim-ide/utility/Library.vim
    so ~/.vim/vim-ide/utility/Functions.vim
    so ~/.vim/vim-ide/utility/CodeEnhance.vim
    so ~/.vim/vim-ide/utility/Lab.vim
    so ~/.vim/vim-ide/utility/Template.vim

    if version >= 704 && g:IDE_CFG_PLUGIN_ENABLE == "y"
        " plugins related
        so ~/.vim/vim-ide/plugin/PluginsConfig.vim
    endif

    so ~/.vim/vim-ide/core/KeyMaps.vim

    redraw
    echo 'Vim Setting Reloaded.'
endfunc
