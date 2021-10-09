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
nnoremap <leader>wa :wa<CR>
nnoremap <leader>qa :qa<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>qq :q!<CR>
nnoremap <leader>wqa :wqa<CR>

" Toggle Hex Mode
nmap <Leader>h :HexToggle<CR>

" open an shell without close vim
nnoremap <leader>sh :sh<CR>

" select all content
map <C-a> <Esc>ggVG<CR>

" Edit
nnoremap <S-k> <Esc>dd<Up>P
nnoremap <S-j> <Esc>dd<Down>P
" inseart an line below
nnoremap <leader><CR> o<Esc>

" " Move 5 times fast
" map <C-H> 5h
" map <C-L> 5l
" map <C-J> 5j
" map <C-K> 5k

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

" Refresh all
nmap <F5> :redraw<CR>

" toggle maximize
nnoremap <C-W>M <C-W>\| <C-W>_
nnoremap <C-W>m <C-W>=

""""    Function map
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Toggle
nnoremap <silent> <C-m> :MouseToggle<CR>

" cscope
" a: Find places where this symbol is assigned a value
" c: Find functions calling this function
" d: Find functions called by this function
" e: Find this egrep pattern
" f: Find this file
" g: Find this definition
" i: Find files #including this file
" s: Find this C symbol
" t: Find this text string
nnoremap <silent>ca :cscope find a <cword><CR>
nnoremap <silent>cc :cscope find c <cword><CR>
nnoremap <silent>cl :cscope find d <cword><CR>
nnoremap <silent>ce :cscope find e <cword><CR>
nnoremap <silent>cf :cscope find f <cword><CR>
nnoremap <silent>cd :cscope find g <cword><CR>
nnoremap <silent>ci :cscope find i <cword><CR>
nnoremap <silent>cs :cscope find s <cword><CR>
nnoremap <silent>ct :cscope find t <cword><CR>

" srcexpl
nnoremap <silent><Leader>t :SrcExplRefresh<CR>

""""    Plugins map
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" IDE map
" nmap <F6> :TlistToggle<CR>
nmap <F6> :TagbarToggle<CR>
" nmap <F6> :NERDTreeToggle<CR>

nmap <F7> :NERDTreeToggle<CR>

" SrcExpl
nmap <F8> :SrcExplToggle<CR>

" SrcExpl
nmap <F9> :CCTreeWindowToggle<CR>

" Commentary settings
map <C-_> :Commentary<CR>

" GitGutter settings
map <C-g> :GitGutterToggle<CR>
nmap ]c :GitGutterNextHunk<CR>
nmap [c :GitGutterPrevHunk<CR>

" tabular
vnoremap <leader>t :Tabularize /

" bookmark
noremap mm :BookmarkToggle<CR>

" CtrlP
noremap <C-p> :CtrlP<CR>

" bufferexpl
noremap <leader>b :ToggleBufExplorer<CR>

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
