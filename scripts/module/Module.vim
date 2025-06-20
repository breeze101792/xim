" Module Settings
" ===========================================
" Module should not depends on other file.
" it's better that we modulize all functions.

" let g:IDE_MDOULE_CODETAGS = get(g:, 'IDE_MDOULE_CODETAGS', "n")
" let g:IDE_MDOULE_STATUSLINE = get(g:, 'IDE_MDOULE_STATUSLINE', "n")
" let g:IDE_MDOULE_HIGHLIGHTWORD = get(g:, 'IDE_MDOULE_HIGHLIGHTWORD', "n")
" let g:IDE_MDOULE_BOOKMARK = get(g:, 'IDE_MDOULE_BOOKMARK', "n")
" let g:IDE_MDOULE_SEARCHPROJECT = get(g:, 'IDE_MDOULE_SEARCHPROJECT', "n")
" let g:IDE_MDOULE_TABGROUP = get(g:, 'IDE_MDOULE_TABGROUP', "n")
" let g:IDE_MDOULE_PROJECTMANAGER = get(g:, 'IDE_MDOULE_PROJECTMANAGER', "n")
" let g:IDE_MDOULE_MULTIPLECURSORS = get(g:, 'IDE_MDOULE_MULTIPLECURSORS', "n")

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

if get(g:, 'IDE_MDOULE_TABGROUP', 'n') == 'y'
    exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/module/TabGroup.vim"
endif

if get(g:, 'IDE_MDOULE_PROJECTMANAGER', 'n') == 'y'
    exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/module/ProjectManager.vim"
endif

if get(g:, 'IDE_MDOULE_MULTIPLECURSORS', 'n') == 'y'
    exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/module/MultipleCursors.vim"
endif

" Module Testing Zoon
" ===========================================
" it's for testing.
" exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/module/Lab.vim"
" exe "source " . g:IDE_ENV_ROOT_PATH . "/scripts/module/LogAnalysis.vim"
