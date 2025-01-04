""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    initialize
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Source needed scripts
if !empty(glob("~/.vim/ConfigCustomize.vim"))
    source ~/.vim/ConfigCustomize.vim
else
    " TODO remove it
    if !empty(glob("~/.vim/Config_Customize.vim"))
        source ~/.vim/Config_Customize.vim
    endif
endif
let s:config_path='~/.vim/scripts' 

execute 'source '.s:config_path.'/core/Config.vim' 
execute 'source '.s:config_path.'/core/Environment.vim' 
execute 'source '.s:config_path.'/core/Settings.vim' 
execute 'source '.s:config_path.'/core/KeyMaps.vim' 

if g:IDE_CFG_AUTOCMD_ENABLE == "y"
    execute 'source '.s:config_path.'/core/Autocmd.vim' 
endif

" Adaptation layer
execute 'source '.s:config_path.'/adaptation/Adaptation.vim' 

" utility function related
execute 'source '.s:config_path.'/utility/Utility.vim' 

if version >= 704 && g:IDE_CFG_PLUGIN_ENABLE == "y"
    " plugins related
    execute 'source '.s:config_path.'/plugin/PluginPreConfig.vim' 
    execute 'source '.s:config_path.'/plugin/Plugin.vim' 
    execute 'source '.s:config_path.'/plugin/PluginPostConfig.vim' 
else
    execute 'source '.s:config_path.'/plugin/PluginNone.vim' 
" elseif version < 704
" skip
endif

" -------------------------------------------
"  Reload
" -------------------------------------------
command! Reload call Reload()
command! Refresh call Reload()

func! Reload()
    let l:config_path='~/.vim/scripts' 

    execute 'source '.l:config_path.'/core/Config.vim' 
    execute 'source '.l:config_path.'/core/Environment.vim' 
    execute 'source '.l:config_path.'/core/Settings.vim' 
    execute 'source '.l:config_path.'/core/KeyMaps.vim' 
    if g:IDE_CFG_AUTOCMD_ENABLE == "y"
        execute 'source '.l:config_path.'/core/Autocmd.vim' 
    endif

    " Adaptation layer
    execute 'source '.l:config_path.'/adaptation/Adaptation.vim' 

    " utility function related
    execute 'source '.l:config_path.'/utility/Utility.vim' 

    if version >= 704 && g:IDE_CFG_PLUGIN_ENABLE == "y"
        " plugins related
        execute 'source '.l:config_path.'/plugin/PluginPreConfig.vim' 
        execute 'source '.l:config_path.'/plugin/PluginPostConfig.vim' 
    else
        execute 'source '.s:config_path.'/plugin/PluginNone.vim' 
    endif

    redraw
    echo 'Vim Setting Reloaded.'
endfunc
