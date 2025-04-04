""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Config vim env                            """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Default enable all config, since we have lite version. if everything got
" wrong. Use lite version insdead.
let g:IDE_CFG_GIT_ENV                        = get(g:, 'IDE_CFG_GIT_ENV', "y")
let g:IDE_CFG_AUTOCMD_ENABLE                 = get(g:, 'IDE_CFG_AUTOCMD_ENABLE', "y")
let g:IDE_CFG_PLUGIN_ENABLE                  = get(g:, 'IDE_CFG_PLUGIN_ENABLE', "y")
let g:IDE_CFG_SPECIAL_CHARS                  = get(g:, 'IDE_CFG_SPECIAL_CHARS', "y")

let g:IDE_CFG_HIGH_PERFORMANCE_HOST          = get(g:, 'IDE_CFG_HIGH_PERFORMANCE_HOST', "y")

" Session
let g:IDE_CFG_SESSION_AUTOSAVE               = get(g:, 'IDE_CFG_SESSION_AUTOSAVE', "y")

" color theme
let g:IDE_CFG_CACHED_COLORSCHEME             = get(g:, 'IDE_CFG_CACHED_COLORSCHEME', "y")
" lazy will preload this, so set it to be ""
" let g:IDE_CFG_COLORSCHEME_NAME             = get(g:, 'IDE_CFG_COLORSCHEME_NAME', "autogen")
let g:IDE_CFG_COLORSCHEME_NAME               = get(g:, 'IDE_CFG_COLORSCHEME_NAME', "idecolor")

"" Backgorund worker
let g:IDE_CFG_BACKGROUND_WORKER              = get(g:, 'IDE_CFG_BACKGROUND_WORKER', "y")
let g:IDE_CFG_AUTO_TAG_UPDATE                = get(g:, 'IDE_CFG_AUTO_TAG_UPDATE', "y")

"" LLM
let g:IDE_CFG_LLM_SERVER                     = get(g:, 'IDE_CFG_LLM_SERVER', "localhost")
let g:IDE_CFG_LLM_SERVER_PORT                = get(g:, 'IDE_CFG_LLM_SERVER_PORT', "11434")
let g:IDE_CFG_LLM_MODEL                      = get(g:, 'IDE_CFG_LLM_MODEL', "qwen2.5:7b-instruct-q8_0")
let g:IDE_CFG_LLM_IMPL                       = get(g:, 'IDE_CFG_LLM_IMPL', "avante")
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Shell vim env                             """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
if $VIDE_SH_SPECIAL_CHARS == "y"
    let g:IDE_CFG_SPECIAL_CHARS = "y"
elseif $VIDE_SH_SPECIAL_CHARS == "n"
    let g:IDE_CFG_SPECIAL_CHARS = "n"
endif

if $VIDE_SH_AUTOCMD_ENABLE == "y"
    let g:IDE_CFG_AUTOCMD_ENABLE = "y"
elseif $VIDE_SH_AUTOCMD_ENABLE == "n"
    let g:IDE_CFG_AUTOCMD_ENABLE = "n"
endif

if $VIDE_SH_PLUGIN_ENABLE == "y"
    let g:IDE_CFG_PLUGIN_ENABLE = "y"
elseif $VIDE_SH_PLUGIN_ENABLE == "n"
    let g:IDE_CFG_PLUGIN_ENABLE = "n"
endif
