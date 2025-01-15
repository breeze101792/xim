" Module Settings
" ===========================================
" Module should not depends on other file.

" let g:IDE_MDOULE_STATUSLINE = get(g:, 'IDE_MDOULE_STATUSLINE', "n")
" let g:IDE_MDOULE_HIGHLIGHTWORD = get(g:, 'IDE_MDOULE_HIGHLIGHTWORD', "n")

if get(g:, 'IDE_MDOULE_STATUSLINE', 'n') == 'y'
    exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/module/StatusLine.vim"
endif

if get(g:, 'IDE_MDOULE_HIGHLIGHTWORD', 'n') == 'y'
    exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/module/HighlightWord.vim"
endif
