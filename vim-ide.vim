" Config vim env
" disable vi compatiable
set nocp
set encoding=utf-8
" Load pathogen
execute pathogen#infect()
let g:NERDTreeGlyphReadOnly = "RO"

" Editor Settings
syntax on
filetype plugin indent on
" colorscheme murphy
" colorscheme industry
colorscheme pablo
set mouse=a
" set mouse=
" set paste
" ignore case
set ic
set nu
" hightlight search word
set hlsearch
" soft tab
set expandtab
set tabstop=4
set shiftwidth=4
set listchars=tab:>-
" show special char
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
set list
" setup cursor
set cursorcolumn
hi cursorcolumn cterm=NONE ctermbg=233
set cursorline
hi CursorLine   cterm=NONE ctermbg=233

set cscopetag cscopeverbose

" remove the trailing space 
autocmd FileType c,cpp,h,bash,sh autocmd BufWritePre <buffer> %s/\s\+$//e
" memorize last open line
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

" map shortkey
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
map <C-o> <Esc>:tabnew 

" IDE map
" Open and close all the three plugins on the same time
" nmap <F8>  :TrinityToggleAll<CR>
" Open and close the Source Explorer separately
nmap <F8>  :TrinityToggleSourceExplorer<CR>
" Open and close the Taglist separately
nmap <F7> :TrinityToggleTagList<CR>
" Open and close the NERD Tree separately
nmap <F6> :TrinityToggleNERDTree<CR>

" Plugin settings
" Nertree
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let NERDTreeNodeDelimiter="\u00b7"

" Test
let mouse_mode = 0 " 0 = c, 1 = a


func! Mouse_on_off()
   if g:mouse_mode == 0
      let g:mouse_mode = 1
      set mouse=c
   else
      let g:mouse_mode = 0
      set mouse=a
   endif
   return
endfunc
nnoremap <silent> <C-m> :call Mouse_on_off()<CR>
