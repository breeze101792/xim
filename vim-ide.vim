
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Reload
""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! Reload call Reload()
command! Refresh call Reload()

func! Reload()
    if $VIDE_SH_IDE_LITE != ""
        call LiteInit()
    else
        " Core layer
        execute 'source '.g:IDE_ENV_ROOT_PATH.'/scripts/core/Core.vim'

        " Adaptation layer
        execute 'source '.g:IDE_ENV_ROOT_PATH.'/scripts/adaptation/Adaptation.vim'

        " utility function related
        execute 'source '.g:IDE_ENV_ROOT_PATH.'/scripts/utility/Utility.vim'

        " Framwork
        if version >= 704 && g:IDE_CFG_PLUGIN_ENABLE == "y"
            execute 'source '.g:IDE_ENV_ROOT_PATH.'/scripts/framework/Framework.vim'
        endif

        if version >= 704 && g:IDE_CFG_PLUGIN_ENABLE == "y"
            " plugins related
            execute 'source '.g:IDE_ENV_ROOT_PATH.'/scripts/plugin/PluginPreConfig.vim'
            execute 'source '.g:IDE_ENV_ROOT_PATH.'/scripts/plugin/PluginPostConfig.vim'
        endif

        execute 'source '.g:IDE_ENV_ROOT_PATH.'/scripts/module/Module.vim'

    endif
    redraw
    echo 'Vim Setting Reloaded.'
endfunc

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    initialize
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:IDE_ENV_ROOT_PATH = get(g:, 'IDE_ENV_ROOT_PATH', $HOME."/.vim")

function! LiteInit()
    execute 'source ' . g:IDE_ENV_ROOT_PATH . '/scripts/core/Environment.vim'
    execute 'source ' . g:IDE_ENV_ROOT_PATH . '/scripts/core/Settings.vim'
    execute 'source ' . g:IDE_ENV_ROOT_PATH . '/scripts/core/KeyMaps.vim'
    execute 'source ' . g:IDE_ENV_ROOT_PATH . '/scripts/core/Autocmd.vim'

    execute 'source '.g:IDE_ENV_ROOT_PATH.'/scripts/lite.vim'

    execute 'source '.g:IDE_ENV_ROOT_PATH.'/scripts/adaptation/Adaptation.vim'
    execute 'source '.g:IDE_ENV_ROOT_PATH.'/scripts/utility/Utility.vim'

    execute 'source '.g:IDE_ENV_ROOT_PATH.'/scripts/module/Module.vim'
endfunction

function! IdeInit()
    " Source needed scripts
    if !empty(glob("~/.vim/ConfigCustomize.vim"))
        source ~/.vim/ConfigCustomize.vim
    else
        " TODO remove it
        if !empty(glob("~/.vim/Config_Customize.vim"))
            source ~/.vim/Config_Customize.vim
        endif
    endif

    " Core
    execute 'source '.g:IDE_ENV_ROOT_PATH.'/scripts/core/Core.vim' 

    " Adaptation layer
    execute 'source '.g:IDE_ENV_ROOT_PATH.'/scripts/adaptation/Adaptation.vim' 

    " utility function related
    execute 'source '.g:IDE_ENV_ROOT_PATH.'/scripts/utility/Utility.vim' 

    " Framwork
    if version >= 704 && g:IDE_CFG_PLUGIN_ENABLE == "y"
        execute 'source '.g:IDE_ENV_ROOT_PATH.'/scripts/framework/Framework.vim' 
    endif

    if version >= 704 && g:IDE_CFG_PLUGIN_ENABLE == "y"
        " plugins related
        execute 'source '.g:IDE_ENV_ROOT_PATH.'/scripts/plugin/PluginPreConfig.vim' 
        execute 'source '.g:IDE_ENV_ROOT_PATH.'/scripts/plugin/Plugin.vim' 
        execute 'source '.g:IDE_ENV_ROOT_PATH.'/scripts/plugin/PluginPostConfig.vim' 
    endif

    execute 'source '.g:IDE_ENV_ROOT_PATH.'/scripts/module/Module.vim' 

endfunction

func! IdeMain()
    "" Main init
    if $VIDE_SH_IDE_LITE != ""
        call LiteInit()
    else
        call IdeInit()
    endif
endfunc

"  Main Function
" -------------------------------------------
call IdeMain()
