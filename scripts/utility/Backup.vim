" Test
" if exists('$TMUX')
"     let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
"     let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
" else
"     let &t_SI = "\<Esc>]50;CursorShape=1\x7"
"     let &t_EI = "\<Esc>]50;CursorShape=0\x7"
" endif
" -------------------------------------------
"  Session test
" -------------------------------------------
function! MakeSession(overwrite)
    let b:sessiondir = $HOME . "/.vim/sessions" . getcwd()
    if (filewritable(b:sessiondir) != 2)
        exe 'silent !mkdir -p ' b:sessiondir
        redraw!
    endif
    let b:filename = b:sessiondir . '/session.vim'
    if a:overwrite == 0 && !empty(glob(b:filename))
        return
    endif
    exe "mksession! " . b:filename
endfunction

function! LoadSession()
    let b:sessiondir = $HOME . "/.vim/sessions" . getcwd()
    let b:sessionfile = b:sessiondir . "/session.vim"
    if (filereadable(b:sessionfile))
        exe 'source ' b:sessionfile
    else
        echo "No session loaded."
    endif
endfunction

" " Adding automatons for when entering or leaving Vim
" if(argc() == 0)
"     au VimEnter * nested :call LoadSession()
"     au VimLeave * :call MakeSession(1)
" else
"     au VimLeave * :call MakeSession(0)
" endif

" -------------------------------------------
"  Reopen test
" -------------------------------------------
 augroup bufclosetrack
   au!
   autocmd WinLeave * let g:lastWinName = @%
 augroup END
 function! LastWindow()
   exe "split " . g:lastWinName
 endfunction
 command -nargs=0 LastWindow call LastWindow()



" -------------------------------------------
"  Tabline override
" -------------------------------------------
set tabline=%!MyTabLine()

" Set the entire tabline
function! MyTabLine()
    echo 'test'
    let s = ''
    for i in range(tabpagenr('$'))
        " select the highlighting
        if i + 1 == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif

        " set the tab page number (for mouse clicks)
        let s .= '%' . (i + 1) . 'T'

        " the label is made by MyTabLabel()
        let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
    endfor

    " after the last tab fill with TabLineFill and reset tab page nr
    let s .= '%#TabLineFill#%T'

    " right-align the label to close the current tab page
    if tabpagenr('$') > 1
        let s .= '%=%#TabLine#%999Xclose'
    endif

    return s
endfunction

" Set the label for a single tab
function! MyTabLabel(n)

    " This is run in the scope of the active tab, so t:name
    " won't work.
    let l:tabname = gettabvar(a:n, 'name', '')

    " This variable exists!
    if l:tabname != ''
        return l:tabname
    endif

    " If it's not found fall back to the buffer name
    let buflist = tabpagebuflist(a:n)
    let winnr = tabpagewinnr(a:n)
    let l:bname = bufname(buflist[winnr - 1])

    " Unnamed buffer, scratch buffer, etc. Could be more detailed.
    if l:bname == ''
        let l:bname = '[No Name]'
    endif

    return l:bname
endfunction

" -------------------------------------------
"  Visual mode test
" -------------------------------------------
function! CursorLineNrColorVisual()
    echo "test"
    return ''   " Return nothing to make the map-expr a no-op.
endfunction
vnoremap <expr> <SID>CursorLineNrColorVisual CursorLineNrColorVisual()
nnoremap <script> v v<SID>CursorLineNrColorVisual
nnoremap <script> V V<SID>CursorLineNrColorVisual
nnoremap <script> <C-v> <C-v><SID>CursorLineNrColorVisual

" Colorize line numbers in insert and visual modes
" ------------------------------------------------
function! SetCursorLineNrColorInsert(mode)
    " Insert mode: blue
    if a:mode == "i"
        highlight CursorLineNr ctermfg=4 guifg=#268bd2

    " Replace mode: red
    elseif a:mode == "r"
        highlight CursorLineNr ctermfg=1 guifg=#dc322f

    endif
endfunction


function! SetCursorLineNrColorVisual()
    set updatetime=0

    " Visual mode: orange
    highlight CursorLineNr cterm=none ctermfg=9 guifg=#cb4b16
endfunction


function! ResetCursorLineNrColor()
    set updatetime=4000
    highlight CursorLineNr cterm=none ctermfg=0 guifg=#073642
endfunction


vnoremap <silent> <expr> <SID>SetCursorLineNrColorVisual SetCursorLineNrColorVisual()
nnoremap <silent> <script> v v<SID>SetCursorLineNrColorVisual
nnoremap <silent> <script> V V<SID>SetCursorLineNrColorVisual

" -------------------------------------------
"  Mylog
" -------------------------------------------
function! Mylog(message, file)
  new
  setlocal buftype=nofile bufhidden=hide noswapfile nobuflisted
  put=a:message
  execute 'w >>' a:file
  q
endfun
" -------------------------------------------
"  Selbuffer by pattern
" -------------------------------------------
function! BufSel(pattern)
    let bufcount = bufnr("$")
    let currbufnr = 1
    let nummatches = 0
    let firstmatchingbufnr = 0
    while currbufnr <= bufcount
        if(bufexists(currbufnr))
            let currbufname = bufname(currbufnr)
            if(match(currbufname, a:pattern) > -1)
                echo currbufnr . ": ". bufname(currbufnr)
                let nummatches += 1
                let firstmatchingbufnr = currbufnr
            endif
        endif
        let currbufnr = currbufnr + 1
    endwhile
    if(nummatches == 1)
        execute ":buffer ". firstmatchingbufnr
    elseif(nummatches > 1)
        let desiredbufnr = input("Enter buffer number: ")
        if(strlen(desiredbufnr) != 0)
            execute ":buffer ". desiredbufnr
        endif
    else
        echo "No matching buffers"
    endif
endfunction

"Bind the BufSel() function to a user-command
command! -nargs=1 Bs :call BufSel("<args>")
" -------------------------------------------
"  Get sync stack
" -------------------------------------------
"command! InspectSynHL call InspectSynHL()
nnoremap <leader>z :call SyntaxStack()<CR>:let g:var02=':silent execute "normal /' . g:str2Search_SyntaxStack . '\' .'<' .'CR' .'>"'<CR>:execute(g:var02)<CR>:echo "Searched: ". substitute(g:str2Search_SyntaxStack, '\\\\\\', '\', 'g')<CR>

nnoremap <leader>z! :call SyntaxStack(1)<CR>:let g:var02=':silent execute "normal /' . g:str2Search_SyntaxStack . '\' .'<' .'CR' .'>"'<CR>:execute(g:var02)<CR>:echo "Searched: ". substitute(g:str2Search_SyntaxStack, '\\\\\\', '\', 'g')<CR><CR>

function! SyntaxStack(append_to_file_bool=0)
  if !exists("*synstack")
    return
  endif

  let l:str2Search=List_to_strings_to_search(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'), 1)

  let l:file__after_syntax=Get_file__after_syntax()

  " read current highlight for <group> under cursor
  " and append to syntax file
  if (a:append_to_file_bool)
    for l:syntaxID in synstack(line("."), col("."))
      let l:hi_group=execute('hi ' . synIDattr(l:syntaxID, "name"))
      let l:hi_group=substitute(l:hi_group, "\n", '', 'g') " remove new lines
      let l:hi_group=substitute(l:hi_group, "xxx", '', 'g') " remove 'xxx' added to show highlight settings default (I think)
      let l:hi_group="highlight " . l:hi_group
      if l:hi_group =~ "clear"
        " if cleared (noone should) from colorscheme plugin, then comment line before appending
        let l:hi_group= '" ' . l:hi_group
      endif
      call writefile([l:hi_group], l:file__after_syntax, "a")
    endfor
  endif

 " 1st I must open a buffer, and then search in it, so it cannot be all in same function
 " therefore, I need a global variable to return from an <SID> fcn
 let g:str2Search_SyntaxStack=l:str2Search

  " open syntax file with last syntaxID highlighted
  execute ":tabnew " . l:file__after_syntax

endfunc
function! List_to_strings_to_search(list01,slash_double_bool=0)
  " https://vim.fandom.com/wiki/Search_patterns#Finding_this_or_that
  let str01=""
  let cnt01=0
  let list01_len=len(a:list01)
  for l:str02 in a:list01
    let l:cnt01+=1
    " remove single quotes
    let l:str03=substitute(l:str02, "'", '', 'g')
    let l:str01=l:str01 . l:str03
    if l:cnt01 < l:list01_len
        if (a:slash_double_bool)
          let l:str01=l:str01 . '\\\' .'|'
        else
          let l:str01=l:str01 . '\' .'|'
        endif
    endif
  endfor
  return l:str01
endfunc

function! Get_filetype()
  let l:filetype_str=&filetype  " get filetype
  let l:filetype_str=substitute(string(l:filetype_str), "'", '', 'g') " remove single quotes
  return l:filetype_str
endfunc
function! Get_file__after_syntax()
  let l:filetype_str=Get_filetype()
  let l:file__after_syntax=expand('~/.vim/after/syntax/' . l:filetype_str . '.vim') " expand() to avoid tilde errors
  return l:file__after_syntax
endfunc
