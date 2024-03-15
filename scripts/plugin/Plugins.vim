""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Vars
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let VAR_PLUGIN_PATH = '~/.vim/plugins'

" Make sure you use single quotes
let VAR_PLUGIN_DEBUG = 0
" let VAR_PLUGIN_DEBUG = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Plugins Entry
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugins'
" - Avoid using standard Vim directory names like 'plugins'
call plug#begin(VAR_PLUGIN_PATH)

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Always loading
""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug VAR_PLUGIN_PATH.'/lightline.vim'
Plug VAR_PLUGIN_PATH.'/vim-ide'
" Plug VAR_PLUGIN_PATH.'/vim-ingo-library'
" Plug VAR_PLUGIN_PATH.'/tagbar'

" FIXME, contain vimenter for init, this will not trigger it.
Plug VAR_PLUGIN_PATH.'/bufexplorer'

""""    Color
""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug VAR_PLUGIN_PATH.'/everforest'


""""    Nvim Entry
""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has('nvim')
    Plug VAR_PLUGIN_PATH.'/cscope_maps.nvim'
    Plug VAR_PLUGIN_PATH.'/nvim-lspconfig'
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    On-demand function loading
""""""""""""""""""""""""""""""""""""""""""""""""""""""
"NOTE. if autocommand contain vimenter for init, this will not trigger it.
if VAR_PLUGIN_DEBUG == 0
    Plug VAR_PLUGIN_PATH.'/Colorizer', { 'on':  ['ColorToggle'] }
    Plug VAR_PLUGIN_PATH.'/cctree', { 'on':  ['CCTreeWindowToggle', 'CCTreeLoadXRefDB'] }
    Plug VAR_PLUGIN_PATH.'/ctrlp', { 'on':  ['CtrlP'] }
    Plug VAR_PLUGIN_PATH.'/gitgutter', { 'on':  ['GitGutterEnable'] }
    Plug VAR_PLUGIN_PATH.'/nerdtree', { 'on':  'NERDTreeToggle' }
    Plug VAR_PLUGIN_PATH.'/srcexpl', { 'on':  ['SrcExplRefresh', 'SrcExplToggle'] }
    Plug VAR_PLUGIN_PATH.'/tabular', { 'on':  ['Tabularize'] }
    Plug VAR_PLUGIN_PATH.'/vim-bookmarks', { 'on':  ['BookmarkToggle'] }
    Plug VAR_PLUGIN_PATH.'/tcomment', { 'on':  ['TComment', 'TCommentBlock'] }
    " Plug VAR_PLUGIN_PATH.'/vim-commentary', { 'on':  'Commentary' }
    Plug VAR_PLUGIN_PATH.'/vim-easygrep', { 'on':  ['Grep','<Plug>EgMapGrepCurrentWord_a', '<Plug>EgMapGrepCurrentWord_A', '<Plug>EgMapGrepCurrentWord_v', '<Plug>EgMapGrepCurrentWord_V'] }
    Plug VAR_PLUGIN_PATH.'/vim-mark', { 'on':  ['<Plug>MarkSet'] }
else
    Plug VAR_PLUGIN_PATH.'/Colorizer'
    Plug VAR_PLUGIN_PATH.'/cctree'
    Plug VAR_PLUGIN_PATH.'/ctrlp'
    Plug VAR_PLUGIN_PATH.'/gitgutter'
    Plug VAR_PLUGIN_PATH.'/nerdtree'
    Plug VAR_PLUGIN_PATH.'/srcexpl'
    Plug VAR_PLUGIN_PATH.'/tabular'
    Plug VAR_PLUGIN_PATH.'/vim-bookmarks'
    Plug VAR_PLUGIN_PATH.'/tcomment'
    " Plug VAR_PLUGIN_PATH.'/vim-commentary'
    Plug VAR_PLUGIN_PATH.'/vim-easygrep'
    Plug VAR_PLUGIN_PATH.'/vim-mark'
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    On-demand file type loading
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO add file type loading
if VAR_PLUGIN_DEBUG == 0
    " Plug VAR_PLUGIN_PATH.'/syntastic', { 'on':  ['SyntasticCheck'], 'for':  ['cpp', 'c', 'python', 'sh'] }
    Plug VAR_PLUGIN_PATH.'/OmniCppComplete', { 'for':  ['cpp', 'c'] }
    Plug VAR_PLUGIN_PATH.'/ale', { 'on':  ['ALEEnable'],'for':  ['sh', 'cpp', 'c'] }
    Plug VAR_PLUGIN_PATH.'/vim-cpp-enhanced-highlight', { 'for':  ['cpp', 'c'] }
    Plug VAR_PLUGIN_PATH.'/vim-python-pep8-indent', { 'for':  ['python'] }
else
    " Plug VAR_PLUGIN_PATH.'/syntastic'
    Plug VAR_PLUGIN_PATH.'/OmniCppComplete'
    Plug VAR_PLUGIN_PATH.'/ale'
    Plug VAR_PLUGIN_PATH.'/vim-cpp-enhanced-highlight'
    Plug VAR_PLUGIN_PATH.'/vim-python-pep8-indent'
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Auto-start loading
""""""""""""""""""""""""""""""""""""""""""""""""""""""
if VAR_PLUGIN_DEBUG == 0
    Plug VAR_PLUGIN_PATH.'/vim-ingo-library', { 'on':  [] }
    Plug VAR_PLUGIN_PATH.'/tagbar', { 'on':  ['TagbarToggle'] }

    Plug VAR_PLUGIN_PATH.'/supertab', { 'on':  ['<Plug>SuperTabForward'] }
    Plug VAR_PLUGIN_PATH.'/vim-visual-multi', { 'on':  [] }
    Plug VAR_PLUGIN_PATH.'/vim-surround', { 'on':  [] }
    Plug VAR_PLUGIN_PATH.'/QFEnter', { 'on':  [] }
else
    Plug VAR_PLUGIN_PATH.'/vim-ingo-library'
    Plug VAR_PLUGIN_PATH.'/tagbar'

    Plug VAR_PLUGIN_PATH.'/supertab'
    Plug VAR_PLUGIN_PATH.'/vim-visual-multi'
    Plug VAR_PLUGIN_PATH.'/vim-surround'
    Plug VAR_PLUGIN_PATH.'/QFEnter'
endif

" Initialize plugin system
call plug#end()


""""    Delay Loading
""""""""""""""""""""""""""""""""""""""""""""""""""""""
if VAR_PLUGIN_DEBUG == 0
    function! IDE_PlugInDealyLoading()
        " load redraw plugins first, to prevent status restore
        call plug#load('supertab') " this will restore line number
        call plug#load('vim-visual-multi')
        call plug#load('QFEnter')

        :GitGutterEnable

        " no redraw
        call plug#load('vim-surround')

        call plug#load('vim-ingo-library')
        call plug#load('tagbar')

        if has('nvim')
            " FIXME, It's just a temp fix for nvim cscope
            execute 'lua require("cscope_maps").setup()'
        endif

        " Tag setup
        " -------------------------------------------
        call TagSetup()
    endfunction
else
    function! IDE_PlugInDealyLoading()
        " Tag setup
        " -------------------------------------------
        call TagSetup()
    endfunction
endif
