""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Config vim env                            """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""    Themes
""""""""""""""""""""""""""""""""""""""""""""""""""""""
try
    " use generated color scheme to accerate start up speed
    " if get(g:, 'IDE_CFG_CACHED_COLORSCHEME', "n") == "y"
    "     if ! empty(glob("~/.vim/colors/". get(g:, 'IDE_ENV_CACHED_COLORSCHEME', "autogen") . ".vim"))
    "         colorscheme autogen
    "     else
    "         execute "colorscheme " . get(g:, 'IDE_CFG_COLORSCHEME_NAME', "default")
    "         source ~/.vim/tools/save_colorscheme.vim
    "     endif
    if get(g:, 'IDE_CFG_COLORSCHEME_NAME', "") != ""
        execute "colorscheme " . get(g:, 'IDE_CFG_COLORSCHEME_NAME', "")
    endif
catch /^Vim\%((\a\+)\)\=:E185/
    " execute "colorscheme default"
    echom "Fallback theme to default."
endtry
