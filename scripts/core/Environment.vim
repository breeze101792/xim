""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Golobal vim env                            """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Note. Update golbale variable only on functions, to avoid overide on
"" restore variable
" for Adaption use
if !exists("g:IDE_ENV_INS")
    if has("nvim")
        let g:IDE_ENV_INS = "nvim"
    else
        let g:IDE_ENV_INS = "vim"
    endif
endif

if !exists("g:IDE_ENV_OS")
    if has("macunix")
        let g:IDE_ENV_OS = "Darwin"
    elseif has("unix")
        let g:IDE_ENV_OS = "Linux"
    elseif has("win64") || has("win32") || has("win16")
        let g:IDE_ENV_OS = "Windows"
    else
        " fallbackk to linux.
        let g:IDE_ENV_OS = "Linux"
    endif
endif

" Env settings
let g:IDE_ENV_IDE_TITLE = get(g:, 'IDE_ENV_IDE_TITLE', "VIM")
let g:IDE_ENV_HEART_BEAT = get(g:, 'IDE_ENV_HEART_BEAT', 30000)
let g:IDE_ENV_CACHED_COLORSCHEME = get(g:, 'IDE_ENV_CACHED_COLORSCHEME', "autogen")

if g:IDE_ENV_INS == "nvim"
    let g:IDE_ENV_ROOT_PATH = get(g:, 'IDE_ENV_ROOT_PATH', $HOME."/.config/nvim")
else
    let g:IDE_ENV_ROOT_PATH = get(g:, 'IDE_ENV_ROOT_PATH', $HOME."/.vim")
endif
let g:IDE_ENV_CSCOPE_EXC = get(g:, 'IDE_ENV_CSCOPE_EXC', "cscope")

" Path config

" Centralize path
let g:IDE_ENV_CONFIG_PATH = get(g:, 'IDE_ENV_CONFIG_PATH', $HOME."/.vim")
let g:IDE_ENV_CLIP_PATH = get(g:, 'IDE_ENV_CLIP_PATH', g:IDE_ENV_CONFIG_PATH."/clip")

" NOTE. This need to set it on runtime
let g:IDE_ENV_PROJ_DATA_PATH = get(g:, 'IDE_ENV_PROJ_DATA_PATH', "./")
let g:IDE_ENV_PROJ_SCRIPT = get(g:, 'IDE_ENV_PROJ_SCRIPT', "")

" Deprecated.
let g:IDE_ENV_TAGS_DB = get(g:, 'IDE_ENV_TAGS_DB', "")
let g:IDE_ENV_CSCOPE_DB = get(g:, 'IDE_ENV_CSCOPE_DB', "")
let g:IDE_ENV_CCTREE_DB = get(g:, 'IDE_ENV_CCTREE_DB', "")

" Session
let g:IDE_ENV_SESSION_AUTOSAVE_PATH = get(g:, 'IDE_ENV_SESSION_AUTOSAVE_PATH', g:IDE_ENV_CONFIG_PATH."/session_autosave")
let g:IDE_ENV_SESSION_PATH = get(g:, 'IDE_ENV_SESSION_PATH', g:IDE_ENV_CONFIG_PATH."/session")

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Golobal vim var                           """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:IDE_ENV_REQ_TAG_UPDATE=0
let g:IDE_ENV_REQ_SESSION_RESTORE=""

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Golobal defines                           """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:IDE_ENV_DEF_PAGE_WIDTH=80
let g:IDE_ENV_DEF_FILE_SIZE_THRESHOLD=100 * 1000 * 1000
