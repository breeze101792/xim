""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    UI Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""

" -------------------------------------------
"  Session
" -------------------------------------------
" Status line override
" Tabline override
let g:StatusLine_extra_info_function = get(g:, 'StatusLine_extra_info_function', '')

" -------------------------------------------
"  Status line override
" -------------------------------------------
function! StatusLineGetCurrentMode()
    let l:mode = mode()
    let l:mode_name = ''
    if l:mode == 'n'
        let l:mode_name = 'Normal '
    elseif l:mode == 'no'
        let l:mode_name = 'N·Operator Pending '
    elseif l:mode == 'v'
        let l:mode_name = 'Visual '
    elseif l:mode == 'V'
        let l:mode_name = 'V·Line '
    elseif l:mode ==# "\<C-V>"
        let l:mode_name = 'V·Block '
    elseif l:mode == 'i'
        let l:mode_name = 'Insert '
    elseif l:mode == 'R'
        let l:mode_name = 'Replace '
    elseif l:mode == 'Rv'
        let l:mode_name = 'V·Replace '
    elseif l:mode == 'c'
        let l:mode_name = 'Command '
    elseif l:mode == 'ce'
        let l:mode_name = 'Ex '
    else
        let l:mode_name = l:mode
    endif
    return l:mode_name
endfunction
function! StatusLineUpdateColor()
    let currentmode=StatusLineGetCurrentMode()
    " exe 'hi! StatusLine ctermbg=008' 
    if (mode() ==# 'i')
        exe 'hi! User1 ctermfg=000 ctermbg=001' 
    elseif (mode() =~# '\v(v|V)' || currentmode ==# 'V·Block')
        exe 'hi! User1 ctermfg=000 ctermbg=002' 
    elseif (mode() ==# 'R')
        exe 'hi! User1 ctermfg=000 ctermbg=006' 
    " elseif (mode() =~# '\v(n|no)' || currentmode ==# 'N')
    "     exe 'hi! User1 ctermfg=000 ctermbg=003' 
    else
        exe 'hi! User1 ctermfg=000 ctermbg=003' 
    endif
    return ''
endfunction

function! StatusLineGetReadOnly()
    if &readonly || !&modifiable
        return ''
    else
        return ''
endfunction
function! StatusLineGetFilePositon()
    return printf('%.2f%%', ( 100.0 * line('.') / line('$') ))
endfunction

"  Tabline Settings
" -------------------------------------------
" status line %n defined color.
" Color Idx. 0~7 Dark, 9~16 Bright
" Black     : 0
" Red       : 1
" Green     : 2
" Yellow    : 3
" Blue      : 4
" Magenta   : 5
" Cyan      : 6
" White     : 7
hi! StatusLine  ctermfg=000 ctermbg=003
hi! User1 ctermfg=000 ctermbg=003
hi! User2 ctermfg=007 ctermbg=000
" Right
hi! User3 ctermfg=007 ctermbg=236
hi! User4 ctermfg=007 ctermbg=240
hi! User5 ctermfg=007 ctermbg=008
" Left
hi! User7 ctermfg=007 ctermbg=240
hi! User8 ctermfg=007 ctermbg=236
hi! User9 ctermfg=015 ctermbg=232

set! statusline=
" Left
set statusline+=%{StatusLineUpdateColor()}                 " Changing the statusline color
set statusline+=%1*\ %{toupper(StatusLineGetCurrentMode())}          " Current mode
set statusline+=%8*\ %<%F\ %{StatusLineGetReadOnly()}\ %m\ %w\       " File+path
set statusline+=%*
set statusline+=%8*\ %=                                    " Space

" Right
" add extra info if exist.
if g:StatusLine_extra_info_function != ''
    set statusline+=%8*\ %{g:StatusLine_extra_info_function()}\                     " Col, Rownumber/total (%)
endif
" set statusline+=%5*\ %{&filetype} " FileType
set statusline+=%5*\ %{(&filetype!=''?&filetype:'None')}   " FileType
set statusline+=%5*\ \[%{(&fenc!=''?&fenc:&enc)}\|%{&ff}]\ " Encoding & Fileformat
" set statusline+=%1*\ %-2c\ %2l\ %2p%%\                     " Col, Rownumber/total (%)
set statusline+=%1*\ %2l:%-2c\ %{StatusLineGetFilePositon()}\                     " Col, Rownumber/total (%)

" -------------------------------------------
"  Tabline override
" -------------------------------------------
set tabline=%!TabLineCompose()

" Color theme
hi! TabLine cterm=None ctermfg=007 ctermbg=240
hi! TabLineSel cterm=None ctermfg=000 ctermbg=003
hi! TabLineFill cterm=None ctermfg=007 ctermbg=236
hi! TabTitle cterm=bold ctermfg=000 ctermbg=014

" Set the entire tabline
function! TabLineCompose() " acclamation to avoid conflict
    let s = '' " complete tabline goes here
    " FIXME, maybe use some script variable to define title name.
    let title = get(g:, 'IDE_ENV_IDE_TITLE', "VIM")

    " Title
    let s .= '%#TabTitle# ' . title . ' '
    " loop through each tab page
    for t in range(tabpagenr('$'))
        " set highlight
        if t + 1 == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif
        " set the tab page number (for mouse clicks)
        let s .= '%' . (t + 1) . 'T'
        let s .= ' '

        " set page number string
        let s .= t + 1 . ' '

        let s .= TabLineLabel(t + 1) . ' '
        " let s .= '%{MyTabLabel(' . (t + 1) . ')} '
    endfor

    " after the last tab fill with TabLineFill and reset tab page nr
    let s .= '%#TabLineFill#%T'
    " right-align the label to close the current tab page
    " if tabpagenr('$') > 1
    "     let s .= '%=%#TabLineFill#%999Xclose'
    " endif
    let s .= '%=%#TabLine# %n '
    return s
endfunction"

" Set the label for a single tab
function! TabLineLabel(n)

    let t = a:n
    let bname = ''
    " get buffer names and statuses
    let tmp_str = ''      " temp string for buffer names while we loop and check buftype
    let modify_cnt = 0       " &modified counter
    let buf_cnt = len(tabpagebuflist(t))     " counter to avoid last ' '
    " loop through each buffer in a tab
    for each_buf_in_tab in tabpagebuflist(t)
        " buffer types: quickfix gets a [Q], help gets [H]{base fname}
        " others get 1dir/2dir/3dir/fname shortened to 1/2/3/fname
        if getbufvar( each_buf_in_tab, "&buftype"  ) == 'help'
            let tmp_str .= '[H]' . fnamemodify( bufname(each_buf_in_tab), ':t:bname/.txt$//'  )
        elseif getbufvar( each_buf_in_tab, "&buftype"  ) == 'quickfix'
            let tmp_str .= '[Q]'
        else
            " let tmp_str .= pathshorten(bufname(each_buf_in_tab))
            let tmp_str .= fnamemodify(bufname(each_buf_in_tab), ':t')
        endif
        " check and ++ tab'bname &modified count
        if getbufvar( each_buf_in_tab, "&modified"  )
            let modify_cnt += 1
        endif
        " no final ' ' added...formatting looks better done later
        if buf_cnt > 1
            let tmp_str .= ' '
        endif
        let buf_cnt -= 1
    endfor
    " select the highlighting for the buffer names
    " my default highlighting only underlines the active tab
    " buffer names.
    if t == tabpagenr()
        let bname .= '%#TabLineSel#'
    else
        let bname .= '%#TabLine#'
    endif
    " add buffer names
    if tmp_str == ''
        let bname.= '[New]'
    else
        let bname .= tmp_str
    endif

    " add modified label [tmp_str+] where tmp_str pages in tab are modified
    if modify_cnt > 0
        " let bname .= ' [' . modify_cnt . '+]'
        let bname .= ' +'
    endif
    return bname
endfunction

" Set the label for a single tab
" function! MyTabLabel(n)
"
"     " This is run in the scope of the active tab, so t:name
"     " won't work.
"     let l:tabname = gettabvar(a:n, 'name', '')
"
"     " This variable exists!
"     if l:tabname != ''
"         return l:tabname
"     endif
"
"     " If it's not found fall back to the buffer name
"     let buflist = tabpagebuflist(a:n)
"     let winnr = tabpagewinnr(a:n)
"     let l:bname = bufname(buflist[winnr - 1])
"
"     " Unnamed buffer, scratch buffer, etc. Could be more detailed.
"     if l:bname == ''
"         let l:bname = '[No Name]'
"     endif
"
"     return l:bname
" endfunction
