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
Plug '~/.vim/plugins/vim-ide'
Plug '~/.vim/plugins/vim-airline'
Plug '~/.vim/plugins/ingo-library'
Plug '~/.vim/plugins/gitgutter'
Plug '~/.vim/plugins/supertab'

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
""""    Others loading
""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug '~/.vim/plugins/ctrlp'
Plug '~/.vim/plugins/vim-multiple-cursors'
Plug '~/.vim/plugins/vim-bookmarks'
Plug '~/.vim/plugins/vim-mark'

" Initialize plugin system
call plug#end()

