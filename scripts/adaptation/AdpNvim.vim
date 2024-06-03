" Patch nvim Function
" ===========================================

" NOTE> patch for wildmenu, it's for better UI use.
" set wildcharm=<C-Z>
cnoremap <expr> <up> wildmenumode() ? "\<left>" : "\<up>"
cnoremap <expr> <down> wildmenumode() ? "\<right>" : "\<down>"
" cnoremap <expr> <left> wildmenumode() ? "\<up>" : "\<left>"
" cnoremap <expr> <right> wildmenumode() ? " \<bs>\<C-Z>" : "\<right>"
