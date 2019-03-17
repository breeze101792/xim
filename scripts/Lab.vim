" Test
let mouse_mode = 0 " 0 = c, 1 = a

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

" Commands
" Beautify Code
" gg=G
