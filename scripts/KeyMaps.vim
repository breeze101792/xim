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
" cscope
" nnoremap <silent> <C-m> :Csc<CR>
nnoremap <silent><Leader><C-]> <C-w><C-]><C-w>T

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

" Patch
"""""""""""""""""""""""""""""""""""""""""""""""""""""
" Edit
map <S-k> <Esc>dd<Up>P
map <S-j> <Esc>dd<Down>P
" tab manipulation
map <C-h> <Esc>:tabprev<CR>
map <C-l> <Esc>:tabnext<CR>
map <S-h> <Esc>:tabmove -1 <CR>
map <S-l> <Esc>:tabmove +1 <CR>

" Enable Alt Keys
" for i in range(97,122)
"     let c = nr2char(i)
"     exec "map \e".c." <M-".c.">"
"     exec "map! \e".c." <M-".c.">"
" endfor
" No Ctrl Key Patch
" nmap <A-t> <Esc>:pop<CR>
