" Module Settings
" ===========================================
" Module should not depends on other file.

" let g:IDE_MDOULE_STATUSLINE = get(g:, 'IDE_MDOULE_STATUSLINE', "n")
" let g:IDE_MDOULE_HIGHLIGHTWORD = get(g:, 'IDE_MDOULE_HIGHLIGHTWORD', "n")
" let g:IDE_MDOULE_BOOKMARK = get(g:, 'IDE_MDOULE_BOOKMARK', "n")

if get(g:, 'IDE_MDOULE_BOOKMARK', 'n') == 'y'
    exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/module/Bookmark.vim"
endif

if get(g:, 'IDE_MDOULE_STATUSLINE', 'n') == 'y'
    exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/module/StatusLine.vim"
endif

if get(g:, 'IDE_MDOULE_HIGHLIGHTWORD', 'n') == 'y'
    exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/module/HighlightWord.vim"
endif

if get(g:, 'IDE_MDOULE_CODETAGS', 'n') == 'y'
    exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/module/CodeTags.vim"
endif

if get(g:, 'IDE_MDOULE_SEARCHPROJECT', 'n') == 'y'
    exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/module/SearchProject.vim"
endif

" it's for testing.
" exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/module/Lab.vim"
