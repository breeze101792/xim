""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Config vim env                            """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:IDE_CFG_CACHED_COLORSCHEME = get(g:, 'IDE_CFG_CACHED_COLORSCHEME', "y")
let g:IDE_CFG_GIT_ENV            = get(g:, 'IDE_CFG_GIT_ENV', "y")
let g:IDE_CFG_PLUGIN_ENABLE      = get(g:, 'IDE_CFG_PLUGIN_ENABLE', "y")
let g:IDE_CFG_SPECIAL_CHARS      = get(g:, 'IDE_CFG_SPECIAL_CHARS', "n")
let g:IDE_CFG_BACKGROUND_WORKER  = get(g:, 'IDE_CFG_BACKGROUND_WORKER', "n")
let g:IDE_CFG_AUTO_TAG_UPDATE  = get(g:, 'IDE_CFG_AUTO_TAG_UPDATE', "n")

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Shell vim env                             """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
if $VIDE_SH_SPECIAL_CHARS == "y"
    let g:IDE_CFG_SPECIAL_CHARS = "y"
elseif $VIDE_SH_SPECIAL_CHARS == "n"
    let g:IDE_CFG_SPECIAL_CHARS = "n"
else
    let g:IDE_CFG_SPECIAL_CHARS = ""
endif
" echo g:IDE_CFG_SPECIAL_CHARS

if $VIDE_SH_PLUGIN_ENABLE == "y"
    let g:IDE_CFG_PLUGIN_ENABLE = "y"
elseif $VIDE_SH_PLUGIN_ENABLE == "n"
    let g:IDE_CFG_PLUGIN_ENABLE = "n"
else
    let g:IDE_CFG_PLUGIN_ENABLE = "y"
endif
" echo g:IDE_CFG_PLUGIN_ENABLE
