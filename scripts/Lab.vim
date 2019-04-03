" Test
let mouse_mode = 1 " 0 = a, 1 = c

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

function! Csc()
  cscope find c <cword>
  copen
endfunction
command! Csc call Csc()

if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" Commands
" Beautify Code
" gg=G
