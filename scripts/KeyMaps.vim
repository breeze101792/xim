" Map shortkey
" Edit
map <C-Up> <Esc>dd<Up>P
map <C-Down> <Esc>dd<Down>P
map <C-a> <Esc>ggVG<CR>
map <C-_> :Commentary<CR>
" tab manipulation
map <C-Left> <Esc>:tabprev<CR>
map <C-Right> <Esc>:tabnext<CR>
map <S-Left> <Esc>:tabmove -1 <CR>
map <S-Right> <Esc>:tabmove +1 <CR>
map <C-o> <Esc>:tabnew<SPACE>
" Toggle
nnoremap <silent> <C-m> :call Mouse_on_off()<CR>

" IDE map
nmap <F6> :TlistToggle<CR>
" nmap <F6> :NERDTreeToggle<CR>

" Open and close all the three plugins on the same time
" nmap <F8>  :TrinityToggleAll<CR>
" Open and close the Source Explorer separately
nmap <F8>  :TrinityToggleSourceExplorer<CR>
" Open and close the Taglist separately
" nmap <F7> :TrinityToggleTagList<CR>
" Open and close the NERD Tree separately
nmap <F7> :TrinityToggleNERDTree<CR>

" Patch
" Edit
map <C-l> <Esc>dd<Up>P
map <C-j> <Esc>dd<Down>P
" tab manipulation
map <C-h> <Esc>:tabprev<CR>
map <C-l> <Esc>:tabnext<CR>
map <S-h> <Esc>:tabmove -1 <CR>
map <S-l> <Esc>:tabmove +1 <CR>
