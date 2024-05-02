""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Config vim env                            """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""    Themes
""""""""""""""""""""""""""""""""""""""""""""""""""""""

" echom g:IDE_ENV_ROOT_PATH."/tools/save_colorscheme.vim"
" try
"     " use generated color scheme to accerate start up speed
"     if get(g:, 'IDE_CFG_CACHED_COLORSCHEME', "n") == "y"
"         if ! empty(glob(g:IDE_ENV_ROOT_PATH."/colors/". get(g:, 'IDE_ENV_CACHED_COLORSCHEME', "autogen") . ".vim"))
"             colorscheme autogen
"         else
"             execute "colorscheme " . get(g:, 'IDE_CFG_COLORSCHEME_NAME', "default")
"             " source g:IDE_ENV_ROOT_PATH."/tools/save_colorscheme.vim"
"             execute 'source '.g:IDE_ENV_ROOT_PATH."/tools/save_colorscheme.vim"
"         endif
"     elseif get(g:, 'IDE_CFG_COLORSCHEME_NAME', "") != ""
"         execute "colorscheme " . get(g:, 'IDE_CFG_COLORSCHEME_NAME', "")
"     endif
" catch /^Vim\%((\a\+)\)\=:E185/
"     " execute "colorscheme default"
"     echom "Fallback theme to default."
" endtry
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
