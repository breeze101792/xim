""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Config vim env                            """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""    Themes
""""""""""""""""""""""""""""""""""""""""""""""""""""""
try
    " use generated color scheme to accerate start up speed
    colorscheme autogen
catch /^Vim\%((\a\+)\)\=:E185/
    try
        colorscheme afterglow_lab
        if empty(glob("~/.vim/colors/autogen.vim")) && g:IDE_CFG_CACHED_COLORSCHEME == "y"
            " silent source ~/.vim/tools/save_colorscheme.vim
            source ~/.vim/tools/save_colorscheme.vim
        endif
    catch /^Vim\%((\a\+)\)\=:E185/
        colorscheme vimdefault
    endtry
endtry

"""""    lightline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:lightline = {
            \ 'colorscheme'        : 'wombat_lab',
            \ 'active'             : {
            \ 'left'               : [['mode', 'paste'], ['readonly', 'filename', 'modified']],
            \ 'right'              : [['lineinfo', 'percent'], ['info'], ['CurrentFunction']]
            \ },
            \ 'inactive'           : {
            \ 'left'               : [['filename']],
            \ 'right'              : [['lineinfo'], ['percent']]
            \ },
            \ 'component_expand'   : {
            \ 'noet'               : 'LightlineNoexpandtab',
            \ },
            \ 'component_function' : {
            \ 'filename'           : 'LightlineFilename',
            \ 'CurrentFunction'    : 'LightlineFuncName',
            \ 'gitinfo'            : 'LightlineGitInfo',
            \ 'title'              : 'LightlineTitle',
            \ 'info'               : 'LightlineFileInfo',
            \ },
            \ 'tabline'            : {
            \ 'left'               : [['title'], ['tabs']],
            \ 'right'              : [['bufnum'], ['gitinfo'] ]
            \ },
            \ 'mode_map' : {
            \ 'v'        : 'V',
            \ 't'        : 'T',
            \ 's'        : 'S',
            \ 'n'        : 'N',
            \ 'i'        : 'I',
            \ 'c'        : 'C',
            \ 'V'        : 'V-LINE',
            \ 'S'        : 'S-LINE',
            \ 'R'        : 'R',
            \ "\<C-v>"   : 'V-BLOCK',
            \ "\<C-s>"   : 'S-BLOCK',
            \ },
            \ }

" \ 'right'           : [['lineinfo', 'percent'], ['status', 'noet', 'fileformat', 'fileencoding', 'filetype'], ['CurrentFunction']]
" \ 'component_type': {
    " \   'paste': 'warning',
    " \   'noet': 'error',
    " \ },

if g:IDE_CFG_SPECIAL_CHARS == "y"
    let g:lightline.separator = { 'left': '', 'right': '' }
    let g:lightline.subseparator = {'left': '', 'right': '' }
else
    let g:lightline.subseparator = {'left': '|', 'right': '|' }
endif

function! LightlineFileInfo()
    let msg = &filetype
    let sep = ' '.g:lightline.subseparator['right'].' '
    let smart_info = 1

    if winwidth(0) < 70 || smart_info == 1
        if &fileformat != 'unix'
            let msg = msg . sep . &fileformat
        endif

        if &fileencoding != 'utf-8'
            let msg = msg . sep . &fileencoding
        endif
        if !&expandtab
            " htab stand for hard tab
            " return &expandtab ? '' : 'htab'
            let msg = msg . sep . 'htab'
        endif
    else
        let msg = &filetype
        let msg = msg . sep  . &fileformat . sep  . &fileencoding
        if !&expandtab
            " htab stand for hard tab
            " return &expandtab ? '' : 'htab'
            let msg = msg . sep  . 'htab'
        endif
    endif
    return msg
endfunction

function! LightlineNoexpandtab()
    " htab stand for hard tab
    return &expandtab ? '' : 'htab'
endfunction

function! LightlineTitle()
    return winwidth(0) < 70 ? '' : g:IDE_ENV_IDE_TITLE
endfunction

function! LightlineFuncName()
    let current_fun = get(b:, 'IDE_ENV_CURRENT_FUNC', "")
    return winwidth(0) < 70 ? '' : l:current_fun
endfunction

function! LightlineGitInfo()
    let l:git_chars=" "
    let proj_name = get(b:, 'IDE_ENV_GIT_PROJECT_NAME', "")
    let proj_branch = get(b:, 'IDE_ENV_GIT_BRANCH', "")

    if g:IDE_CFG_SPECIAL_CHARS == "y"
        let l:git_chars=" "
    endif
    " FIXME, there is a bug on 70 char check, i don't count the word like
    " @/@locl
    if winwidth(0) > 70
        if l:proj_name != '' && l:proj_branch != '' && len(l:proj_branch . l:proj_name) < 70
            return l:proj_branch == '' ? l:git_chars.l:proj_name : l:git_chars.l:proj_branch.'@'.l:proj_name
        elseif l:proj_name != '' && len(l:proj_name ) < 70
            return l:git_chars.'@'.l:proj_name
        elseif l:proj_branch != '' && len(l:proj_branch ) < 70
            return l:git_chars.l:proj_branch.'@local'
        endif
    endif
    return ''
endfunction

function! LightlineFilename()
    let proj_path = get(b:, 'IDE_ENV_GIT_PROJECT_PATH', "-1")
    let proj_name = get(b:, 'IDE_ENV_GIT_PROJECT_NAME', "-1")
    let name = expand('%:t')
    let full_name = expand('%:p')

    " FIXME, find an event when file not exist. so we don't need to call it.
    if proj_path == -1 || proj_name == -1
        call IDE_UpdateEnv_BufOpen()
    endif

    " :help expand
    " :echo expand("%:p")    " absolute path
    " :echo expand("%:p:h")  " absolute path dirname
    " :echo expand("%:p:h:h")" absolute path dirname dirname
    " :echo expand("%:.")    " relative path
    " :echo expand("%:.:h")  " relative path dirname
    " :echo expand("%:.:h:h")" relative path dirname dirname
    " :echo expand("<sfile>:p")  " absolute path to [this] vimscript
    " :help filename-modifiers

    " echo proj_path . '/' . name
    if len(name) == 0
        return "[No Name]"
    elseif winwidth(0) > 70
        if len(proj_path) != 0 && len(name) != 0 && len(proj_path.name) < 72
            return l:proj_path.l:name
        elseif len(full_name) <= 72
            return l:full_name
        else
            return substitute(getcwd(), '^.*/', '', '').'/'.l:name
        endif
    else
        return substitute(getcwd(), '^.*/', '', '').'/'.l:name
    endif
endfunction

let g:unite_force_overwrite_statusline = 0
let g:vimfiler_force_overwrite_statusline = 0
let g:vimshell_force_overwrite_statusline = 0

""""    Nertree
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:NERDTreeGlyphReadOnly = "RO"
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
" let NERDTreeNodeDelimiter="\u00b7"
let NERDTreeNodeDelimiter = "\t"
let g:NERDTreeWinPos = "left"

""""    ctrlp
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ctrlp_map = '<c-p>'
let g:ctrlp_by_filename = 1
let g:ctrlp_regexp = 1
let g:ctrlp_lazy_update = 250
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_switch_buffer = 'et'
let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:20,results:20'
let g:ctrlp_root_markers = ['vimproj', '.git', '.repo', 'Makefile', 'Android.mk', 'Android.bp', 'cscope.db']
let g:ctrlp_extensions = ['tag']
" ignore file on .gitignore
" while using user command, ignore will not work
let g:ctrlp_user_command = ['.git', "cd %s && git ls-files -co --exclude-standard | egrep -v '.*(exe|so|dll|a|o|d|bin)$'"]

" unlet g:ctrlp_custom_ignore
let g:ctrlp_custom_ignore = {
            \ 'dir'  : '\v[\/]\.(git|hg|svn)$\|*build*',
            \ 'file' : '\v\.(exe|so|dll|a|o|d|bin)$',
            \ 'link' : 'some_bad_symbolic_links',
            \ }

""""    Cpp Enhanced highlight
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:cpp_class_scope_highlight = 1
" let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_posix_standard = 1
let g:cpp_concepts_highlight = 1
" let g:cpp_no_function_highlight = 1
" Don't use it, it will slow down the vim
" let g:cpp_experimental_simple_template_highlight = 1
" let g:cpp_experimental_template_highlight = 1


""""    Bookmark
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Shortcut keys
" mm	:BookmarkToggle
" mi	:BookmarkAnnotate <TEXT>
" ma	:BookmarkShowAll
" mc	:BookmarkClear
" mx	:BookmarkClearAll
let g:bookmark_auto_save = 0
if g:IDE_CFG_SPECIAL_CHARS == "y"
    let g:bookmark_sign = '⚑'
else
    let g:bookmark_sign = '*'
endif
let g:bookmark_highlight_lines = 1
" autocmd VimEnter * highlight BookmarkLine ctermfg=0 ctermbg=11

""""    Vim Mark
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:mwPalettes = {
                    \ 'mypalette': [
                    \ { 'ctermbg':'Blue',         'ctermfg' :'Black', 'guibg':'#A1B7FF', 'guifg':'#001E80' },
                    \ { 'ctermbg':'Cyan',         'ctermfg' :'Black', 'guibg':'#A1FEFF', 'guifg':'#007F80' },
                    \ { 'ctermbg':'Gray',         'ctermfg' :'Black', 'guibg':'#A3A396', 'guifg':'#222222' },
                    \ { 'ctermbg':'Green',        'ctermfg' :'Black', 'guibg':'#ACFFA1', 'guifg':'#0F8000' },
                    \ { 'ctermbg':'Magenta',      'ctermfg' :'White', 'guibg':'#FFA1C6', 'guifg':'#80005D' },
                    \ { 'ctermbg':'Red',          'ctermfg' :'Black', 'guibg':'#F3FFA1', 'guifg':'#6F8000' },
                    \ { 'ctermbg':'White',        'ctermfg' :'Black', 'guibg':'#E3E3D2', 'guifg':'#999999' },
                    \ { 'ctermbg':'Yellow',       'ctermfg' :'Black', 'guibg':'#FFE8A1', 'guifg':'#806000' },
                    \ { 'ctermbg':'Brown',        'ctermfg' :'White', 'guibg':'#FFC4A1', 'guifg':'#803000' },
                    \ { 'ctermbg':'DarkCyan',     'ctermfg' :'Black', 'guibg':'#D2A1FF', 'guifg':'#420080' },
                    \ { 'ctermbg':'DarkGreen',    'ctermfg' :'Black', 'guibg':'#D0FFA1', 'guifg':'#3F8000' },
                    \ { 'ctermbg':'DarkBlue',     'ctermfg' :'White', 'guibg':'#A1DBFF', 'guifg':'#004E80' },
                    \ { 'ctermbg':'DarkMagenta',  'ctermfg' :'White', 'guibg':'#A29CCF', 'guifg':'#120080' },
                    \ { 'ctermbg':'DarkRed',      'ctermfg' :'White', 'guibg':'#F5A1FF', 'guifg':'#720080' },
                    \ { 'ctermbg':'DarkYellow',   'ctermfg' :'Black', 'guibg':'#FFFF00', 'guifg':'#6F6F4C' },
                    \ { 'ctermbg':'LightCyan',    'ctermfg' :'Black', 'guibg':'#FFFFFF', 'guifg':'#FFFFFF' },
                    \ { 'ctermbg':'LightGray',    'ctermfg' :'Black', 'guibg':'#FFFFFF', 'guifg':'#FFFFFF' },
                    \ { 'ctermbg':'LightGreen',   'ctermfg' :'Black', 'guibg':'#FFFFFF', 'guifg':'#FFFFFF' },
                    \ { 'ctermbg':'LightMagenta', 'ctermfg' :'Black', 'guibg':'#FFFFFF', 'guifg':'#FFFFFF' },
                    \ { 'ctermbg':'LightRed',     'ctermfg' :'Black', 'guibg':'#FFFFFF', 'guifg':'#FFFFFF' },
                    \ { 'ctermbg':'LightYellow',  'ctermfg' :'Black', 'guibg':'#FFFFFF', 'guifg':'#000000' },
                    \ ],
                    \ }

" Make it the default:
" extended can be used up to 18 color
" maximum can be used up to 27, 58, or even 77 colors
" let g:mwDefaultHighlightingPalette = 'maximum'
let g:mwDefaultHighlightingPalette = 'mypalette'
let g:mwDefaultHighlightingNum = 21

let g:mwAutoSaveMarks = 0
let g:mwAutoLoadMarks = 0
let g:mwIgnoreCase = 0

""""    vim-multiple-cursors
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" If set to 0, insert mappings won't be supported in _Insert_ mode anymore.
let g:multi_cursor_support_imap=1
let g:multi_cursor_exit_from_visual_mode=1
let g:multi_cursor_exit_from_insert_mode=1

""""    Src Expl
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:SrcExpl_winHeight = 10
" let g:SrcExpl_refreshTime = 100
" let g:SrcExpl_jumpKey = "<ENTER>"
" let g:SrcExpl_gobackKey = "<SPACE>"
" let g:SrcExpl_searchLocalDef = 1
" let g:SrcExpl_nestedAutoCmd = 0
let g:SrcExpl_isUpdateTags = 0
" let g:SrcExpl_pluginList = [
"             \ "__Tag_List__",
"             \ "_NERD_tree_",
"             \ "Source_Explorer"
"             \ ]
" let g:SrcExpl_colorSchemeList = [
"             \ "Red",
"             \ "Cyan",
"             \ "Green",
"             \ "Yellow",
"             \ "Magenta"
"             \ ]

""""    CCTree
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:CCTreeDisplayMode = 3
" let g:CCTreeWindowVertical = 1
" let g:CCTreeWindowMinWidth = 40
let g:CCTreeUseUTF8Symbols = 1
let g:CCTreeDbFileMaxSize  = 40000000 " (40 Mbytes)


""""    gitgutter
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:gitgutter_enabled = 0
" let g:gitgutter_sign_added = '+'
" let g:gitgutter_sign_modified = '~'
let g:gitgutter_sign_removed = '-'
" let g:gitgutter_sign_removed_first_line = '¯'
" let g:gitgutter_sign_removed_above_and_below = '_¯'
" let g:gitgutter_sign_modified_removed = '~_'

let g:gitgutter_override_sign_column_highlight = 1
" highlight clear SignColumn
" autocmd VimEnter * highlight GitGutterAdd ctermfg=2 ctermbg=None
" autocmd VimEnter * highlight GitGutterChange ctermfg=3 ctermbg=None
" autocmd VimEnter * highlight GitGutterDelete ctermfg=1 ctermbg=None
" autocmd VimEnter * highlight GitGutterChangeDelete ctermfg=4 ctermbg=None

""""    bufexplorer
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:bufExplorerSortBy='name'

""""    Syntastic
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1
let g:syntastic_aggregate_errors = 1

" Python
let g:syntastic_python_checkers = ['pylint']

" C
let g:syntastic_c_remove_include_errors = 1
" let g:syntastic_c_compiler = ['clang','gcc', 'make']
let g:syntastic_c_compiler = 'cppcheck'
" let g:syntastic_c_compiler_options ='-Wpedantic -g'

"""""    Ale
"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:ale_lint_on_enter = 0
" let g:ale_set_signs = 1
" let g:ale_sign_error = '◈'
" let g:ale_sign_warning = '◈'
" " let g:ale_statusline_format = ['E:%d', 'W:%d', 'ok']
" let g:ale_echo_msg_error_str = 'E'
" let g:ale_echo_msg_warning_str = 'W'
" let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
"  let g:airline#extensions#ale#error_symbol = 'E'
"  let g:airline#extensions#ale#warning_symbol = 'W'
" let g:ale_pattern_options = {
"             \   '.*\.sh$': {'ale_enabled': 0},
"             \   '.*\.json$': {'ale_enabled': 0},
"             \   '.*some/folder/.*\.js$': {'ale_enabled': 0},
"             \}
let g:ale_linters = {
            \   'cpp': ['cppcheck'],
            \   'c': ['cppcheck'],
            \   'python': ['pylint'],
            \}
" let g:ale_c_cppcheck_options='-f -q --std=c99 --enable=unusedFunction'
let g:ale_c_cppcheck_options='-f -q --std=c99'

""""    TComment
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:tcomment#replacements_c = {
            \     '/*': {'guard_rx': '^\s*/\?\*', 'subst': '//|*'},
            \     '*/': {'guard_rx': '^\s*/\?\*', 'subst': '*|'},
            \ }
let g:tcomment_maps=0

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    EasyGrep
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 0 - quickfix
" 1 - location list
" let g:EasyGrepWindow=1
let g:EasyGrepRoot="repository"

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    pathogen
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Load pathogen
" execute pathogen#infect()

" remove color under line
" autocmd VimEnter * highlight CursorLine   cterm=NONE " hi color in content area
" autocmd VimEnter * highlight CursorLineNR cterm=NONE " hi color in number line
" autocmd VimEnter * highlight LineNr ctermbg=NONE " set line color

" Fix first single column issue background issue
" autocmd VimEnter * highlight! link SignColumn LineNr

" if version <= 800
"     " highlight Normal ctermbg=NONE " avoid background block
"     autocmd VimEnter * highlight Normal ctermbg=NONE
" endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Others
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""    Airline
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:airline#extensions#tabline#enabled = 1
" let g:airline#extensions#tabline#left_sep = ' '
" let g:airline#extensions#tabline#left_alt_sep = '|'
" let g:airline#extensions#tabline#formatter = 'unique_tail'
" let g:airline_theme='afterglow'
" " Avoid ui not refresh
" " if version >= 802
" "     autocmd VimEnter * :AirlineRefresh
" " endif

""""    Taglist
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let Tlist_Show_One_File = 1
" let Tlist_Enable_Fold_Column=1

