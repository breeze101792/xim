""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Config vim env                            """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    pathogen
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:pathogen_disabled = ['Trinity']

" Load pathogen
execute pathogen#infect()

""""    awesome-vim-colorschemes
""""""""""""""""""""""""""""""""""""""""""""""""""""""
colorscheme afterglow

" remove color under line
autocmd VimEnter * highlight CursorLine   cterm=NONE " hi color in content area
autocmd VimEnter * highlight CursorLineNR cterm=NONE " hi color in number line
autocmd VimEnter * highlight LineNr ctermbg=NONE " set line color

" Fix first single column issue background issue
" autocmd ColorScheme * highlight! link SignColumn LineNr
autocmd VimEnter * highlight! link SignColumn LineNr

if version <= 800
    " highlight Normal ctermbg=NONE " avoid background block
    autocmd VimEnter * highlight Normal ctermbg=NONE
endif

""""    Airline
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_theme='afterglow'
" Avoid ui not refresh
autocmd VimEnter * :AirlineRefresh

""""    Nertree
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:NERDTreeGlyphReadOnly = "RO"
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
" let NERDTreeNodeDelimiter="\u00b7"
let NERDTreeNodeDelimiter = "\t"
let g:NERDTreeWinPos = "left"

""""    Taglist
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let Tlist_Show_One_File = 1
" let Tlist_Enable_Fold_Column=1

""""    vim-comment
""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType gitcommit setlocal commentstring=#\ %s
autocmd FileType c,cpp,hxx,hpp,cxx,verilog setlocal commentstring=//\ %s

""""    ctrlp
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ctrlp_map = '<c-p>'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_switch_buffer = 'et'
let g:ctrlp_root_markers = ['Makefile', 'Android.mk', 'Android.bp', '.git', 'cscope.db', '.repo']
let g:ctrlp_extensions = ['tag']
" ignore file on .gitignore
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

" let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
" unlet g:ctrlp_custom_ignore
let g:ctrlp_custom_ignore = {
            \ 'dir':  '\v[\/]\.(git|hg|svn)$\|*build*',
            \ 'file': '\v\.(exe|so|dll|a|o|d|bin)$',
            \ 'link': 'some_bad_symbolic_links',
            \ }

""""    Syntastic
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:syntastic_always_populate_loc_list = 0
" let g:syntastic_auto_loc_list = 0
" let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 1
let g:syntastic_python_checkers = ['pylint']
let g:syntastic_c_remove_include_errors = 1

""""    Cpp Enhanced highlight
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:cpp_class_scope_highlight = 1
" let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_posix_standard = 1
let g:cpp_concepts_highlight = 1
" let g:cpp_no_function_highlight = 1
" Don't use it, it will slow down the vim
" let g:cpp_experimental_simple_template_highlight = 1
" let g:cpp_experimental_template_highlight = 1


""""    Bookmark
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Shortcut keys
" mm	:BookmarkToggle
" mi	:BookmarkAnnotate <TEXT>
" ma	:BookmarkShowAll
" mc	:BookmarkClear
" mx	:BookmarkClearAll
autocmd VimEnter * highlight BookmarkLine ctermfg=0 ctermbg=11
" autocmd VimEnter * highlight BookmarkSign ctermfg=4
let g:bookmark_sign = '⚑'
let g:bookmark_highlight_lines = 1

""""    Vim Mark
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" extended can be used up to 18 color
" maximum can be used up to 27, 58, or even 77 colors
let g:mwDefaultHighlightingPalette = 'maximum'
let g:mwDefaultHighlightingNum = 58

let g:mwAutoSaveMarks = 0
let g:mwAutoLoadMarks = 0
let g:mwIgnoreCase = 0

""""    vim-multiple-cursors
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" If set to 0, insert mappings won't be supported in _Insert_ mode anymore.
let g:multi_cursor_support_imap=1
let g:multi_cursor_exit_from_visual_mode=1
let g:multi_cursor_exit_from_insert_mode=1

""""    Src Expl
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:SrcExpl_winHeight = 10
" let g:SrcExpl_refreshTime = 100
" let g:SrcExpl_jumpKey = "<ENTER>"
" let g:SrcExpl_gobackKey = "<SPACE>"
" let g:SrcExpl_searchLocalDef = 1
" let g:SrcExpl_nestedAutoCmd = 0
let g:SrcExpl_isUpdateTags = 0
" let g:SrcExpl_pluginList = [
"             \ "__Tag_List__",
"             \ "_NERD_tree_",
"             \ "Source_Explorer"
"             \ ]
" let g:SrcExpl_colorSchemeList = [
"             \ "Red",
"             \ "Cyan",
"             \ "Green",
"             \ "Yellow",
"             \ "Magenta"
"             \ ]

""""    CCTree
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:CCTreeDisplayMode = 3
" let g:CCTreeWindowVertical = 1
" let g:CCTreeWindowMinWidth = 40
let g:CCTreeUseUTF8Symbols = 1
let g:CCTreeDbFileMaxSize  = 40000000 " (40 Mbytes)


""""    gitgutter
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:gitgutter_enabled = 0
" let g:gitgutter_sign_added = '+'
" let g:gitgutter_sign_modified = '~'
let g:gitgutter_sign_removed = '-'
" let g:gitgutter_sign_removed_first_line = '¯'
" let g:gitgutter_sign_removed_above_and_below = '_¯'
" let g:gitgutter_sign_modified_removed = '~_'

let g:gitgutter_override_sign_column_highlight = 1
" highlight clear SignColumn
autocmd VimEnter * highlight GitGutterAdd ctermfg=2 ctermbg=None
autocmd VimEnter * highlight GitGutterChange ctermfg=3 ctermbg=None
autocmd VimEnter * highlight GitGutterDelete ctermfg=1 ctermbg=None
autocmd VimEnter * highlight GitGutterChangeDelete ctermfg=4 ctermbg=None

