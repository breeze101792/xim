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
let g:IDE_CFG_COLORSCHEME_NAME               = get(g:, 'IDE_CFG_COLORSCHEME_NAME', "idecolor")

"" Backgorund worker
let g:IDE_CFG_BACKGROUND_WORKER              = get(g:, 'IDE_CFG_BACKGROUND_WORKER', "y")
let g:IDE_CFG_AUTO_TAG_UPDATE                = get(g:, 'IDE_CFG_AUTO_TAG_UPDATE', "y")

"" Tab Completions
let g:IDE_CFG_IMPL_COMPLETION                = get(g:, 'IDE_CFG_IMPL_COMPLETION', "supertab")

"" LLM
"" FIXME, remove IDE_CFG_LLM_IMPL, it's for legacy name.
let g:IDE_CFG_LLM_IMPL                       = get(g:, 'IDE_CFG_LLM_IMPL', "avante")
let g:IDE_CFG_IMPL_LLM                       = get(g:, 'IDE_CFG_IMPL_LLM', g:IDE_CFG_LLM_IMPL)
let g:IDE_CFG_LLM_PROVIDER                   = get(g:, 'IDE_CFG_LLM_PROVIDER', "LLMLocal")

" gemini service.
" let g:IDE_CFG_LLM_GEMINI_URL                = get(g:, 'IDE_CFG_LLM_GEMINI_URL', "http://localhost:1337/v1/")
let g:IDE_CFG_LLM_GEMINI_MODEL               = get(g:, 'IDE_CFG_LLM_GEMINI_MODEL', "gemini-2.5-flash-preview-05-20")

" openrouter service.
let g:IDE_CFG_LLM_OPENWRT_URL                 = get(g:, 'IDE_CFG_LLM_OPENWRT_URL', "https://openrouter.ai/api/v1/")
let g:IDE_CFG_LLM_OPENWRT_MODEL               = get(g:, 'IDE_CFG_LLM_OPENWRT_MODEL', "google/gemini-2.0-flash-exp:free")

" openai service.
let g:IDE_CFG_LLM_OPENAPI_URL                = get(g:, 'IDE_CFG_LLM_OPENAPI_URL', "http://localhost:1337/v1/")
let g:IDE_CFG_LLM_OPENAPI_MODEL              = get(g:, 'IDE_CFG_LLM_OPENAPI_MODEL', "gpt-4.1")

" ollama service.
let g:IDE_CFG_LLM_OLLAMA_URL                 = get(g:, 'IDE_CFG_LLM_OLLAMA_URL', "http://localhost:11434/")
let g:IDE_CFG_LLM_OLLAMA_MODEL               = get(g:, 'IDE_CFG_LLM_OLLAMA_MODEL', "qwen2.5:14b-instruct-q8_0")

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
