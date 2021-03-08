""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Config vim env                            """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Load pathogen
execute pathogen#infect()

""""    Nertree
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:NERDTreeGlyphReadOnly = "RO"
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let NERDTreeNodeDelimiter="\u00b7"
let g:NERDTreeWinPos = "left"

""""    Taglist
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let Tlist_Show_One_File = 1
" let Tlist_Enable_Fold_Column=1

""""    vim-comment
""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType gitcommit setlocal commentstring=#\ %s
autocmd FileType c,cpp,h,cxx setlocal commentstring=//\ %s

""""    ctrlp
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ctrlp_map = '<c-p>'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_root_markers = ['ctags']
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
" let g:syntastic_check_on_wq = 0
" let g:syntastic_python_checkers = ['pylint']

""""    Cpp Enhanced highlight
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:cpp_class_scope_highlight = 1
" let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_posix_standard = 1
let g:cpp_experimental_simple_template_highlight = 1
let g:cpp_experimental_template_highlight = 1
let g:cpp_concepts_highlight = 1
" let g:cpp_no_function_highlight = 1


""""    Bookmark
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Shortcut keys
" mm	:BookmarkToggle
" mi	:BookmarkAnnotate <TEXT>
" ma	:BookmarkShowAll
" mc	:BookmarkClear
" mx	:BookmarkClearAll
highlight BookmarkSign ctermbg=NONE ctermfg=160
highlight BookmarkLine ctermbg=194 ctermfg=NONE
let g:bookmark_sign = '⚑'
let g:bookmark_highlight_lines = 1

""""    Airline
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#formatter = 'unique_tail'

""""    Vim Mark
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" update to 18 color
let g:mwDefaultHighlightingPalette = 'extended'
let g:mwDefaultHighlightingNum = 18
let g:mwAutoSaveMarks = 0
let g:mwAutoLoadMarks = 0
let g:mwIgnoreCase = 0




