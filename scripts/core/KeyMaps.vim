""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Map shortkey
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" <leader> : \
" let g:mapleader='\'
" let g:maplocalleader='\'

" Don't may this keys
" nnoremap <C-[> " cause esc notworking

""""    Patch for disable anoying key mapping
""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap q: <nop>
nnoremap q/ <nop>
map q <nop>

" n  Normal mode map. Defined using ':nmap' or ':nnoremap'.
" i  Insert mode map. Defined using ':imap' or ':inoremap'.
" v  Visual and select mode map. Defined using ':vmap' or ':vnoremap'.
" x  Visual mode map. Defined using ':xmap' or ':xnoremap'.
" s  Select mode map. Defined using ':smap' or ':snoremap'.
" c  Command-line mode map. Defined using ':cmap' or ':cnoremap'.
" o  Operator pending mode map. Defined using ':omap' or ':onoremap'.

" <Space>  Normal, Visual and operator pending mode map. Defined using
"          ':map' or ':noremap'.
" !  Insert and command-line mode map. Defined using 'map!' or
"    'noremap!'.

" Tab
" Auto open tab in new window
" autocmd VimEnter * tab all
" autocmd BufAdd * exe 'tablast | tabe "' . expand( "<afile") .'"'

" za: Toggle code folding at the current line. The block that the current line belongs to is folded (closed) or unfolded (opened).
" zo: Open fold.
" zc: Close fold.
" zR: Open all folds.
" zM: Close all folds.

""""    Editor
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" for quick save and exit
nnoremap <leader>wqa :wqa<CR>
nnoremap <leader>wa :wa<CR>
nnoremap <leader>qq :q!<CR>
nnoremap <leader>qa :qa<CR>
nnoremap <leader>qe :exit()<CR>
nnoremap qq :q!<CR>
nnoremap qa :qa<CR>

" open an shell without close vim
nnoremap <leader>sh :tab terminal<CR>

" select all content
map <C-a> <Esc>ggVG<CR>

" Edit
nnoremap <S-k> <Esc>dd<Up>P
nnoremap <S-j> <Esc>dd<Down>P
" inseart an line below
nnoremap <leader><CR> o<Esc>

" duplicate current tab
map <leader>d <Esc>:tab split<CR>

" tab manipulation with hjkl
map <C-h> <Esc>:tabprev<CR>
map <C-l> <Esc>:tabnext<CR>
map <S-h> <Esc>:tabmove -1 <CR>
map <S-l> <Esc>:tabmove +1 <CR>

" tab manipulation with arror keys
map <C-Left> <Esc>:tabprev<CR>
map <C-Right> <Esc>:tabnext<CR>
map <S-Left> <Esc>:tabmove -1 <CR>
map <S-Right> <Esc>:tabmove +1 <CR>
map <C-o> <Esc>:tabnew<SPACE>

" Add hilighted word with " or '
nnoremap "" viw<esc>a"<esc>hbi"<esc>wwl
nnoremap '' viw<esc>a'<esc>hbi'<esc>wwl

" toggle maximize
nnoremap <C-W>M <C-W>\| <C-W>_
nnoremap <C-W>m <C-W>=

" Type match to reset highlight
nnoremap <silent> <Leader>l ml:execute 'match Search /\%'.line('.').'l/'<CR>
nnoremap <silent> <Leader>v :execute 'match Search /\%'.virtcol('.').'v/'<CR>

""""    Toggle/Function
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" This are toggle vim system function only.
nmap <silent> <Leader>fp :PureToggle<CR>
nmap <silent> <Leader>fr :Reload<CR>
nmap <silent> <Leader>fa <Esc>ggVG<CR>
nmap <silent> <Leader>fc :LLMToggle<CR>

""""    Compatiability
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap Function keys.
map <silent> <Leader>f1 <F1><CR>
map <silent> <Leader>f2 <F2><CR>
map <silent> <Leader>f3 <F3><CR>
map <silent> <Leader>f4 <F4><CR>
map <silent> <Leader>f5 <F5><CR>
map <silent> <Leader>f6 <F6><CR>
map <silent> <Leader>f7 <F7><CR>
map <silent> <Leader>f8 <F8><CR>
map <silent> <Leader>f9 <F9><CR>
