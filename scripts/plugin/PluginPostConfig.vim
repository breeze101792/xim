""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Config vim env                            """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""    Themes
""""""""""""""""""""""""""""""""""""""""""""""""""""""

if get(g:, 'IDE_CFG_CACHED_COLORSCHEME', "n") == "y"
    if empty(glob(g:IDE_ENV_ROOT_PATH."/colors/". get(g:, 'IDE_ENV_CACHED_COLORSCHEME', "autogen") . ".vim"))
        execute "colorscheme " . get(g:, 'IDE_CFG_COLORSCHEME_NAME', "default")
        " source g:IDE_ENV_ROOT_PATH."/tools/save_colorscheme.vim"
        execute 'source '.g:IDE_ENV_ROOT_PATH."/tools/save_colorscheme.vim"
    endif
elseif get(g:, 'IDE_CFG_CACHED_COLORSCHEME', "n") == "n"
    execute "colorscheme " . get(g:, 'IDE_CFG_COLORSCHEME_NAME', "")
elseif get(g:, 'IDE_CFG_COLORSCHEME_NAME', "") != "idecolor"
    execute "colorscheme " . get(g:, 'IDE_CFG_COLORSCHEME_NAME', "")
endif

""""    Functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! LLMToggle call LLMToggle()
function! LLMToggle()
    if exists(':AvanteToggle')
        :AvanteToggle
    endif
endfunction
