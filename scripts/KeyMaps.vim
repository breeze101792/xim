""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Map shortkey
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" <leader> : \

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


""""    Editor
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" for quick save and exit
nnoremap <leader>wa :wa<cr>
nnoremap <leader>qa :qa<cr>
nnoremap <leader>q :q<cr>
nnoremap <leader>wqa :wqa<cr>

" open an shell without close vim
nnoremap <leader>sh :sh<cr>

"goto end of line and start of line
map <C-a> <Esc>ggVG<CR>

" Edit
nnoremap <S-k> <Esc>dd<Up>P
nnoremap <S-j> <Esc>dd<Down>P
" inseart an line below
nnoremap <leader><cr> o<Esc>

" tab manipulation
map <C-h> <Esc>:tabprev<CR>
map <C-l> <Esc>:tabnext<CR>
map <S-h> <Esc>:tabmove -1 <CR>
map <S-l> <Esc>:tabmove +1 <CR>

" tab manipulation
map <C-Left> <Esc>:tabprev<CR>
map <C-Right> <Esc>:tabnext<CR>
map <S-Left> <Esc>:tabmove -1 <CR>
map <S-Right> <Esc>:tabmove +1 <CR>
map <C-o> <Esc>:tabnew<SPACE>

" Add hilighted word with " or '
nnoremap "" viw<esc>a"<esc>hbi"<esc>wwl
nnoremap '' viw<esc>a'<esc>hbi'<esc>wwl

""""    Function map
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Toggle
nnoremap <silent> <C-m> :call Mouse_toggle()<CR>
" cscope
nnoremap <silent><Leader>b :Bt<CR>
nnoremap <silent><Leader><C-]> <C-w><C-]><C-w>T

""""    Plugins map
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" IDE map
" nmap <F6> :TlistToggle<CR>
nmap <F6> :TagbarToggle<CR>
" nmap <F6> :NERDTreeToggle<CR>

" Open and close all the three plugins on the same time
" nmap <F8>  :TrinityToggleAll<CR>
" Open and close the Source Explorer separately
nmap <F8>  :TrinityToggleSourceExplorer<CR>
" Open and close the Taglist separately
" nmap <F7> :TrinityToggleTagList<CR>
" Open and close the NERD Tree separately
" nmap <F7> :TrinityToggleNERDTree<CR>
nmap <F7> :NERDTreeToggle<CR>

" Commentary settings
map <C-_> :Commentary<CR>

" Patch
"""""""""""""""""""""""""""""""""""""""""""""""""""""

" Enable Alt Keys
" for i in range(97,122)
"     let c = nr2char(i)
"     exec "map \e".c." <M-".c.">"
"     exec "map! \e".c." <M-".c.">"
" endfor
" No Ctrl Key Patch
" nmap <A-t> <Esc>:pop<CR>
