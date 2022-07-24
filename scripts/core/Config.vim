""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Config vim env                            """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:IDE_CFG_GIT_ENV = get(g:, 'IDE_CFG_GIT_ENV', "n")
let g:IDE_CFG_SPECIAL_CHARS = get(g:, 'IDE_CFG_SPECIAL_CHARS', "n")
let g:IDE_CFG_CACHED_COLORSCHEME = get(g:, 'IDE_CFG_CACHED_COLORSCHEME', "n")

let g:IDE_CFG_PLUGIN_ENABLE = get(g:, 'IDE_CFG_PLUGIN_ENABLE', "y")

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Shell vim env                             """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
if $VIDE_SH_SPECIAL_CHARS == "y"
    let g:IDE_CFG_SPECIAL_CHARS = "y"
else
    let g:IDE_CFG_SPECIAL_CHARS = "n"
endif

if $VIDE_SH_PLUGIN_ENABLE == "y"
    let g:IDE_CFG_PLUGIN_ENABLE = "y"
else
    let g:IDE_CFG_PLUGIN_ENABLE = "n"
endif
