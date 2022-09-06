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
" Plug '~/.vim/plugins/vim-ingo-library'
" Plug '~/.vim/plugins/tagbar'

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    On-demand function loading
""""""""""""""""""""""""""""""""""""""""""""""""""""""
if plugin_debug == 0
    Plug '~/.vim/plugins/nerdtree', { 'on':  'NERDTreeToggle' }
    Plug '~/.vim/plugins/srcexpl', { 'on':  ['SrcExplRefresh', 'SrcExplToggle'] }
    Plug '~/.vim/plugins/vim-commentary', { 'on':  'Commentary' }
    Plug '~/.vim/plugins/cctree', { 'on':  ['CCTreeWindowToggle', 'CCTreeLoadXRefDB'] }
    Plug '~/.vim/plugins/tabular', { 'on':  ['Tabularize'] }
    Plug '~/.vim/plugins/vim-bookmarks', { 'on':  ['BookmarkToggle'] }
    Plug '~/.vim/plugins/ctrlp', { 'on':  ['CtrlP'] }
    Plug '~/.vim/plugins/syntastic', { 'on':  ['SyntasticCheck'] }
    Plug '~/.vim/plugins/Colorizer', { 'on':  ['ColorToggle'] }
    Plug '~/.vim/plugins/bufexplorer', { 'on':  ['ToggleBufExplorer'] }
    Plug '~/.vim/plugins/vim-mark', { 'on':  ['<Plug>MarkSet'] }
    Plug '~/.vim/plugins/gitgutter', { 'on':  ['GitGutterEnable'] }
    Plug '~/.vim/plugins/vim-easygrep', { 'on':  ['<Plug>EgMapGrepCurrentWord_a', '<Plug>EgMapGrepCurrentWord_A', '<Plug>EgMapGrepCurrentWord_v', '<Plug>EgMapGrepCurrentWord_V'] }
else
    Plug '~/.vim/plugins/nerdtree'
    " Plug '~/.vim/plugins/tagbar'
    Plug '~/.vim/plugins/srcexpl'
    Plug '~/.vim/plugins/vim-commentary'
    Plug '~/.vim/plugins/cctree'
    Plug '~/.vim/plugins/tabular'
    Plug '~/.vim/plugins/vim-bookmarks'
    Plug '~/.vim/plugins/ctrlp'
    Plug '~/.vim/plugins/syntastic'
    Plug '~/.vim/plugins/Colorizer'
    Plug '~/.vim/plugins/bufexplorer'
    Plug '~/.vim/plugins/vim-mark'
    Plug '~/.vim/plugins/gitgutter'
    Plug '~/.vim/plugins/vim-easygrep'
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    On-demand file type loading
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO add file type loading
if plugin_debug == 0
    Plug '~/.vim/plugins/OmniCppComplete', { 'for':  ['cpp', 'c'] }
    Plug '~/.vim/plugins/vim-cpp-enhanced-highlight', { 'for':  ['cpp', 'c'] }
    Plug '~/.vim/plugins/vim-python-pep8-indent', { 'for':  ['python'] }
else
    Plug '~/.vim/plugins/OmniCppComplete'
    Plug '~/.vim/plugins/vim-cpp-enhanced-highlight'
    Plug '~/.vim/plugins/vim-python-pep8-indent'
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Auto-start loading
""""""""""""""""""""""""""""""""""""""""""""""""""""""
if plugin_debug == 0
    Plug '~/.vim/plugins/vim-ingo-library', { 'on':  [] }
    Plug '~/.vim/plugins/tagbar', { 'on':  ['TagbarToggle'] }

    Plug '~/.vim/plugins/supertab', { 'on':  ['<Plug>SuperTabForward'] }
    Plug '~/.vim/plugins/vim-multiple-cursors', { 'on':  [] }
    Plug '~/.vim/plugins/vim-surround', { 'on':  [] }
else
    Plug '~/.vim/plugins/vim-ingo-library'
    Plug '~/.vim/plugins/tagbar'

    Plug '~/.vim/plugins/supertab'
    Plug '~/.vim/plugins/vim-multiple-cursors'
    Plug '~/.vim/plugins/vim-surround'
endif

" Initialize plugin system
call plug#end()


""""    Delay Loading
""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! DealyLoading(timer) abort
    " load redraw plugins first, to prevent status restore
    call plug#load('supertab') " this will restore line number
    call plug#load('vim-multiple-cursors')

    :GitGutterEnable

    " no redraw
    call plug#load('vim-surround')

    call plug#load('vim-ingo-library')
    call plug#load('tagbar')
endfunction

if version >= 800 && plugin_debug == 0
    " Call loadPlug after 500ms
    " all init shuld be done before first 500ms
    call timer_start(500, 'DealyLoading')
endif
