""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Start of Lite Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""    Vim Lite Session Overview
" Env
" Settings
" KeyMap
" AutoGroups
" Adaption
" Function

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Env setting
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:IDE_ENV_OS = "Linux"
let g:IDE_ENV_INS = "vim"
let g:IDE_ENV_IDE_TITLE = "LITE"

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""    Lite setting
""""""""""""""""""""""""""""""""""""""""""""""""""""""
try
    colorscheme industry
catch
    echom 'colorscheme industry not found.'
endtry

try
    syntax on
catch
    echom 'Syntax enable fail.'
endtry
" FIXME, remove this line, syntax issue.
" -------->
set listchars=tab:>-,trail:~,extends:>,precedes:<
" <--------

set noswapfile
if exists('&colorcolumn') 
    set colorcolumn=""
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    KeyMap
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Patch for disable anoying key mapping
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" nnoremap q: <nop>
" nnoremap q/ <nop>
" map q <nop>
"
" " for quick save and exit
" nnoremap <leader>wa :wa<CR>
" nnoremap <leader>qa :qa<CR>
" nnoremap <leader>q :q<CR>
" nnoremap <leader>qq :q!<ENTER>
" nnoremap <leader>wqa :wqa<CR>
" nnoremap qq :q!<ENTER>
" nnoremap qa :qa<CR>
"
" " open an shell without close vim
" nnoremap <leader>sh :sh<CR>
"
" " select all content
" map <C-a> <Esc>ggVG<CR>
"
" " Edit
" nmap <S-k> <Esc>dd<Up>p
" nnoremap <S-j> <Esc>dd<Down>p
" " inseart an line below
" nnoremap <leader><CR> o<Esc>
"
" " duplicate current tab
" map <leader>d <Esc>:tab split<CR>
"
" " tab manipulation with hjkl
" map <C-h> <Esc>:tabprev<CR>
" map <C-l> <Esc>:tabnext<CR>
" map <S-h> <Esc>:tabmove -1 <CR>
" map <S-l> <Esc>:tabmove +1 <CR>
"
" " tab manipulation with arror keys
" map <C-Left> <Esc>:tabprev<CR>
" map <C-Right> <Esc>:tabnext<CR>
" map <S-Left> <Esc>:tabmove -1 <CR>
" map <S-Right> <Esc>:tabmove +1 <CR>
" map <C-o> <Esc>:tabnew<SPACE>
"
" " Add hilighted word with " or '
" nnoremap "" viw<esc>a"<esc>hbi"<esc>wwl
" nnoremap '' viw<esc>a'<esc>hbi'<esc>wwl
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    AutoGroups
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" augroup file_open_gp
"     autocmd!
"     " memorize last open line
"     autocmd BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif
" augroup END
"
" " Call the function after opening a buffer
" augroup tab_gp
"     autocmd!
"     autocmd BufReadPost * call TabsOrSpaces()
" augroup END
"
" augroup syntax_hi_gp
"     autocmd!
"     autocmd Syntax * call matchadd(
"                 \ 'Debug',
"                 \ '\v\W\zs<(NOTE|CHANGED|BUG|HACK|TRICKY)>'
"                 \ )
" augroup END

" Open QF win on ther tab
" autocmd FileType qf nnoremap <buffer> <Enter> <C-W><Enter><C-W>T

"" Commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" comments
noremap <C-_> :SimpleCommentCode<CR>

" buff list
map <leader>b <Esc>:buffers<CR>

" Highlight words.
nnoremap <leader>m :call HighlightWordsToggle(expand('<cword>'))<CR>


""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Adaption
""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("nvim")
    cnoremap <expr> <up> wildmenumode() ? "\<left>" : "\<up>"
    cnoremap <expr> <down> wildmenumode() ? "\<right>" : "\<down>"
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Function
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" -------------------------------------------
"  TabsOrSpaces
" -------------------------------------------
function! TabsOrSpaces()
    let numTabs=len(filter(getbufline(bufname("%"), 1, 250), 'v:val =~ "^\\t"'))
    let numSpaces=len(filter(getbufline(bufname("%"), 1, 250), 'v:val =~ "^  "'))

    if numTabs > numSpaces
        setlocal noexpandtab
    else
        setlocal expandtab
    endif
endfunction
" -------------------------------------------
"  Mouse_on_off for cursor chage
" -------------------------------------------
if !exists("*Reload") ||  !exists(":Reload")
    command! Reload call Reload()
    function! Reload()
        if !empty(glob($MYVIMRC))
            source $MYVIMRC
            echom 'Lite reloaded.'
        else
            echom 'No RC file found.'. $MYVIMRC
        endif
    endfunc
end
" -------------------------------------------
"  Pure mode
" -------------------------------------------
command! PureToggle call PureToggle()

function! PureToggle()
    if &paste
        echo 'Disable Pure mode'
        " backup vars
        setlocal nopaste
        " setlocal cursorline
        setlocal number
        setlocal list
    else
        echo 'Enable Pure mode'
        setlocal paste
        " setlocal nocursorline
        setlocal nonumber
        setlocal nolist
    endif
endfunc

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    End of Lite Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
