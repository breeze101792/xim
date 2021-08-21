" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugins'
" - Avoid using standard Vim directory names like 'plugins'
call plug#begin('~/.vim/plugins/')

" Make sure you use single quotes
let plugin_debug = 0
" let plugin_debug = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Always loading
""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug '~/.vim/plugins/lightline.vim'
Plug '~/.vim/plugins/vim-ide'
Plug '~/.vim/plugins/vim-ingo-library'

" Plug '~/.vim/plugins/gitgutter'
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    On-demand function loading
""""""""""""""""""""""""""""""""""""""""""""""""""""""
if plugin_debug == 0
    Plug '~/.vim/plugins/nerdtree', { 'on':  'NERDTreeToggle' }
    Plug '~/.vim/plugins/tagbar', { 'on':  'TagbarToggle' }
    Plug '~/.vim/plugins/srcexpl', { 'on':  ['SrcExplRefresh', 'SrcExplToggle'] }
    Plug '~/.vim/plugins/vim-commentary', { 'on':  'Commentary' }
    Plug '~/.vim/plugins/cctree', { 'on':  'CCTreeWindowToggle' }
else
    Plug '~/.vim/plugins/nerdtree'
    Plug '~/.vim/plugins/tagbar'
    Plug '~/.vim/plugins/srcexpl'
    Plug '~/.vim/plugins/vim-commentary'
    Plug '~/.vim/plugins/cctree'
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    On-demand file type loading
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO add file type loading
if plugin_debug == 0
    Plug '~/.vim/plugins/OmniCppComplete', { 'for':  'cpp' }
    Plug '~/.vim/plugins/vim-cpp-enhanced-highlight', { 'for':  'cpp' }
else
    Plug '~/.vim/plugins/OmniCppComplete'
    Plug '~/.vim/plugins/vim-cpp-enhanced-highlight'
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Auto-start loading
""""""""""""""""""""""""""""""""""""""""""""""""""""""
if plugin_debug == 0
    Plug '~/.vim/plugins/supertab', { 'on':  [] }
    Plug '~/.vim/plugins/ctrlp', { 'on':  [] }
    Plug '~/.vim/plugins/vim-multiple-cursors', { 'on':  [] }
    Plug '~/.vim/plugins/vim-bookmarks', { 'on':  [] }
    Plug '~/.vim/plugins/vim-mark', { 'on':  [] }
    Plug '~/.vim/plugins/vim-surround', { 'on':  [] }
    Plug '~/.vim/plugins/gitgutter', { 'on':  [] }
    Plug '~/.vim/plugins/syntastic', { 'on':  [] }
else
    Plug '~/.vim/plugins/supertab'
    Plug '~/.vim/plugins/ctrlp'
    Plug '~/.vim/plugins/vim-multiple-cursors'
    Plug '~/.vim/plugins/vim-bookmarks'
    Plug '~/.vim/plugins/vim-mark'
    Plug '~/.vim/plugins/vim-surround'
    Plug '~/.vim/plugins/gitgutter'
    Plug '~/.vim/plugins/syntastic'
endif

" Initialize plugin system
call plug#end()


""""    Delay Loading
""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! DealyLoading(timer) abort
    " load plugins
    call plug#load('supertab')
    call plug#load('ctrlp')
    call plug#load('vim-multiple-cursors')
    call plug#load('vim-bookmarks')
    call plug#load('vim-mark')
    call plug#load('vim-surround')
    call plug#load('syntastic')
    call plug#load('gitgutter')
    : GitGutterEnable
endfunction

if version >= 800
    " Call loadPlug after 500ms
    call timer_start(200, 'DealyLoading')
endif
