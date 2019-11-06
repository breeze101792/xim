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
