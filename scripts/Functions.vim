" Function Settings
" ===========================================
" -------------------------------------------
"  Mouse_on_off for cursor chage
" -------------------------------------------
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

" -------------------------------------------
"  Reverse search function
" -------------------------------------------
function! Csc()
  cscope find c <cword>
  copen
endfunction
command! Csc call Csc()

" -------------------------------------------
