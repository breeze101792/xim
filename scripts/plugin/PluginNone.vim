" -------------------------------------------
"  Plugin None
" -------------------------------------------
let g:IDE_MDOULE_STATUSLINE = 'y'
let g:IDE_MDOULE_HIGHLIGHTWORD = 'y'

" -------------------------------------------
"  Tabline override
" -------------------------------------------
" set statusline=\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ %{&encoding}\ %c:%l/%L%)
"
" set tabline=%!MyTabLine()
"
" " Set the entire tabline
" function! MyTabLine()
"     let s = ''
"     for i in range(tabpagenr('$'))
"         " select the highlighting
"         if i + 1 == tabpagenr()
"             let s .= '%#TabLineSel#'
"         else
"             let s .= '%#TabLine#'
"         endif
"
"         " set the tab page number (for mouse clicks)
"         let s .= '%' . (i + 1) . 'T'
"
"         " the label is made by MyTabLabel()
"         let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
"     endfor
"
"     " after the last tab fill with TabLineFill and reset tab page nr
"     let s .= '%#TabLineFill#%T'
"
"     " right-align the label to close the current tab page
"     if tabpagenr('$') > 1
"         let s .= '%=%#TabLine#%999Xclose'
"     endif
"
"     return s
" endfunction
"
" " Set the label for a single tab
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
