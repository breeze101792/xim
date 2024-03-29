""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Config vim env                            """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""    Themes
""""""""""""""""""""""""""""""""""""""""""""""""""""""
try
    " use generated color scheme to accerate start up speed
    if g:IDE_CFG_CACHED_COLORSCHEME == "y"
        if ! empty(glob("~/.vim/colors/". g:IDE_ENV_CACHED_COLORSCHEME . ".vim"))
            colorscheme autogen
        else
            execute "colorscheme " . g:IDE_CFG_COLORSCHEME_NAME
            source ~/.vim/tools/save_colorscheme.vim
        endif
    else
        " execute "colorscheme idecolor"
        execute "colorscheme " . g:IDE_CFG_COLORSCHEME_NAME
    endif
catch /^Vim\%((\a\+)\)\=:E185/
    execute "colorscheme default"
    echom "Fallback theme to default."
endtry
