" Test
" if exists('$TMUX')
"     let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
"     let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
" else
"     let &t_SI = "\<Esc>]50;CursorShape=1\x7"
"     let &t_EI = "\<Esc>]50;CursorShape=0\x7"
" endif

" -------------------------------------------
"  Test
" -------------------------------------------
function! Test() range
    :'<,'> %s/\s\+$//e
endfunction
command! Test call Test()

" function! SuperTab()
"   let l:part = strpart(getline('.'),col('.')-2,1)
"   if (l:part =~ '^\W\?$')
"       return "\<Tab>"
"   else
"       return "\<C-n>"
"   endif
" endfunction

" imap <Tab> <C-R>=SuperTab()<CR>
" -------------------------------------------
"  Test
" -------------------------------------------
function! Test() range
    s/\s\+$//g
endfunction
command! Test call Test()
" -------------------------------------------
"  PVupdate
" -------------------------------------------
function! Pvupdate()
    :silent !pvupdate
endfunction
command! Pvupdate call Pvupdate()
" -------------------------------------------
"  DisplayColorSchemes
" -------------------------------------------
function! DisplayColorSchemes()
   let currDir = getcwd()
   exec "cd $VIMRUNTIME/colors"
   for myCol in split(glob("*"), '\n')
      if myCol =~ '\.vim'
         let mycol = substitute(myCol, '\.vim', '', '')
         exec "colorscheme " . mycol
         exec "redraw!"
         echo "colorscheme = ". myCol
         sleep 2
      endif
   endfor
   exec "cd " . currDir
endfunction
command! Dcs call DisplayColorSchemes()
