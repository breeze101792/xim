" Load pathogen
execute pathogen#infect()

" Nertree
let g:NERDTreeGlyphReadOnly = "RO"
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let NERDTreeNodeDelimiter="\u00b7"
let g:NERDTreeWinPos = "left"

" Taglist
" let Tlist_Show_One_File = 1
" let Tlist_Enable_Fold_Column=1

" vim-comment
autocmd FileType gitcommit setlocal commentstring=#\ %s
autocmd FileType c,cpp,h,cxx setlocal commentstring=//\ %s

" ctrlp
let g:ctrlp_map = '<c-p>'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_root_markers = ['ctags']
" ignore file on .gitignore
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.o,*.a

" let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
" unlet g:ctrlp_custom_ignore
let g:ctrlp_custom_ignore = {
            \ 'dir':  '\v[\/]\.(git|hg|svn)$\|*build*',
            \ 'file': '\v\.(exe|so|dll|a|o|d|bin)$',
            \ 'link': 'some_bad_symbolic_links',
            \ }
