""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Map to add highlighting
nnoremap <leader>ha :call HighlightWordsAdd(expand('<cword>'))<CR>

" Map to remove highlighting
nnoremap <leader>hr :call HighlightWordsRemove(expand('<cword>'))<CR>

" Map to clear all highlights
nnoremap <leader>ch :call HighlightedAllWordsToggle()<CR>

" Map to toggle highlights
nnoremap <leader>m :call HighlightWordsToggle(expand('<cword>'))<CR>

" Commands
command! -nargs=1 HighlightWordsAdd call HighlightWordsAdd(<q-args>)
command! -nargs=1 HighlightWordsRemove call HighlightWordsRemove(<q-args>)
command! HighlightedAllWordsToggle call HighlightedAllWordsToggle()

" Global list maintenance
autocmd WinEnter,BufEnter * :call SyncGlobalHighlights()

""""    Variable
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Define a list of color schemes
let g:highlighted_color_list = [
            \ ['White', 'Red',    '#ffffff', '#ff0000'],
            \ ['Black', 'Yellow', '#000000', '#ffff00'],
            \ ['White', 'Blue',   '#ffffff', '#0000ff'],
            \ ['Black', 'Green',  '#000000', '#00ff00'],
            \ ['White', 'Magenta','#ffffff', '#ff00ff'],
            \ ['Black', 'Cyan',   '#000000', '#00ffff'],
            \ ['White', 'Black',  '#ffffff', '#000000'],
            \ ['Black', 'White',  '#000000', '#ffffff'],
            \ ]

" Global list of highlighted words and their colors
let g:global_highlighted_words = {}


" Get the current color index based on the global list
let g:highlight_color_index = len(g:global_highlighted_words) % len(g:highlighted_color_list)
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Function
""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! HighlightWord(word, color_idx)
    let l:group_name = 'UserHL_' . substitute(a:word, '\W', '_', 'g')
    let l:ctermfg = g:highlighted_color_list[a:color_idx][0]
    let l:ctermbg = g:highlighted_color_list[a:color_idx][1]
    let l:guifg   = g:highlighted_color_list[a:color_idx][2]
    let l:guibg   = g:highlighted_color_list[a:color_idx][3]

    " Update buffer-specific list
    " let b:highlighted_words[a:word] = a:word
    let b:highlighted_words[a:word] = {
                \ 'color_index': a:color_idx,
                \ 'group_name': l:group_name
                \ }

    " Apply highlighting
    execute 'highlight ' . l:group_name .
                \ ' ctermfg=' . l:ctermfg .
                \ ' ctermbg=' . l:ctermbg .
                \ ' guifg='   . l:guifg .
                \ ' guibg='   . l:guibg .
                \ ' cterm=bold gui=bold'

    execute 'syntax match ' . l:group_name . ' /\<'. escape(a:word, '/\') . '\>/ containedin=ALL'
    " execute 'syntax match ' . l:group_name . ' /\V' . escape(a:word, '/\') . '/ containedin=ALL'
endfunction

function! HighlightWordsToggle(...) abort
  if a:0 == 0
    let l:input = input('Enter words to toggle highlight (separate with spaces): ')
    let l:words = split(l:input)
  else
    let l:words = a:000
  endif

  " Ensure buffer-specific highlighted words exist
  if !exists('b:highlighted_words')
    let b:highlighted_words = {}
  endif

  for l:word in l:words
    " let l:group_name = 'UserHL_' . substitute(l:word, '\W', '_', 'g')

    if has_key(b:highlighted_words, l:word)
        call HighlightWordsRemove(l:word)
    else
        call HighlightWordsAdd(l:word)
    endif
  endfor
endfunction

" Function to add highlighting to specified words
function! HighlightWordsAdd(...) abort
  if a:0 == 0
    let l:input = input('Enter words to add highlight (separate with spaces): ')
    let l:words = split(l:input)
  else
    let l:words = a:000
  endif

  " Ensure buffer-specific highlighted words exist
  if !exists('b:highlighted_words')
    let b:highlighted_words = {}
  endif

  for l:word in l:words
    let l:group_name = 'UserHL_' . substitute(l:word, '\W', '_', 'g')

    if !has_key(b:highlighted_words, l:word)
      let l:ctermfg = g:highlighted_color_list[g:highlight_color_index][0]
      let l:ctermbg = g:highlighted_color_list[g:highlight_color_index][1]
      let l:guifg   = g:highlighted_color_list[g:highlight_color_index][2]
      let l:guibg   = g:highlighted_color_list[g:highlight_color_index][3]

      if !has_key(g:global_highlighted_words, l:word)
          " Update global list
          " let g:global_highlighted_words[l:word] = {
          "             \ 'color_index': g:highlight_color_index,
          "             \ 'group_name': l:group_name,
          "             \ 'ctermfg': l:ctermfg,
          "             \ 'ctermbg': l:ctermbg,
          "             \ 'guifg': l:guifg,
          "             \ 'guibg': l:guibg
          "             \ }
          let g:global_highlighted_words[l:word] = {
                      \ 'color_index': g:highlight_color_index,
                      \ 'group_name': l:group_name
                      \ }
      endif
      call HighlightWord(l:word, g:highlight_color_index)
      "
      " " Update buffer-specific list
      " " let b:highlighted_words[l:word] = l:word
      " let b:highlighted_words[l:word] = {
      "             \ 'color_index': g:highlight_color_index,
      "             \ 'group_name': l:group_name
      "             \ }
      "
      " " Apply highlighting
      " execute 'highlight ' . l:group_name .
      "       \ ' ctermfg=' . l:ctermfg .
      "       \ ' ctermbg=' . l:ctermbg .
      "       \ ' guifg='   . l:guifg .
      "       \ ' guibg='   . l:guibg .
      "       \ ' cterm=bold gui=bold'
      "
      " execute 'syntax match ' . l:group_name . ' /\<'. escape(l:word, '/\') . '\>/ containedin=ALL'
      " " execute 'syntax match ' . l:group_name . ' /\V' . escape(l:word, '/\') . '/ containedin=ALL'

      let g:highlight_color_index = (g:highlight_color_index + 1) % len(g:highlighted_color_list)
      echo 'Added highlight for "' . l:word . '".'
    else
      echo 'Highlight for "' . l:word . '" already exists.'
    endif
  endfor
endfunction

" Function to remove highlighting from specified words
function! HighlightWordsRemove(...) abort
  if a:0 == 0
    let l:input = input('Enter words to remove highlight (separate with spaces): ')
    let l:words = split(l:input)
  else
    let l:words = a:000
  endif

  " Ensure buffer-specific highlighted words exist
  if !exists('b:highlighted_words')
    let b:highlighted_words = {}
  endif

  for l:word in l:words
    let l:group_name = 'UserHL_' . substitute(l:word, '\W', '_', 'g')

    if has_key(b:highlighted_words, l:word)
      execute 'syntax clear ' . l:group_name
      execute 'highlight clear ' . l:group_name
      call remove(b:highlighted_words, l:word)
      echo 'Removed highlight for "' . l:word . '".'

      " Remove from global list
      if has_key(g:global_highlighted_words, l:word)
        call remove(g:global_highlighted_words, l:word)
      endif
    else
      echo 'Highlight for "' . l:word . '" does not exist.'
    endif
  endfor
endfunction

" Function to clear all highlights in the current buffer
function! HighlightedAllWordsToggle() abort
  if exists('b:highlighted_words')
    for l:word in keys(b:highlighted_words)
        let l:group_name = 'UserHL_' . substitute(l:word, '\W', '_', 'g')
      execute 'syntax clear ' . l:group_name
      execute 'highlight clear ' . l:group_name
    endfor
    unlet b:highlighted_words
    echo 'All highlights cleared.'

    " Clear global list
    let g:global_highlighted_words = {}
  else
    echo 'No highlights to clear.'
  endif
endfunction

" Function to synchronize global highlights with the current buffer
function! SyncGlobalHighlights() abort
    " echom "SyncGlobalHighlights"
    if !exists('b:highlighted_words')
        let b:highlighted_words = {}
    endif

    " Apply global highlights to the current buffer
    for l:word in keys(g:global_highlighted_words)
        " echom "Check Global:".l:word
        if !has_key(b:highlighted_words, l:word)
            let l:color_idx = g:global_highlighted_words[l:word].color_index
            let l:group_name = g:global_highlighted_words[l:word].group_name

            call HighlightWord(l:word, l:color_idx)

            " let b:highlighted_words[l:word] = l:word
            let b:highlighted_words[l:word] = {
                        \ 'color_index': l:color_idx,
                        \ 'group_name': l:group_name
                        \ }
        endif

      " let l:group_name = g:global_highlighted_words[l:word].group_name
      " let l:ctermfg = g:global_highlighted_words[l:word].ctermfg
      " let l:ctermbg = g:global_highlighted_words[l:word].ctermbg
      " let l:guifg = g:global_highlighted_words[l:word].guifg
      " let l:guibg = g:global_highlighted_words[l:word].guibg

      " execute 'highlight ' . l:group_name .
      "       \ ' ctermfg=' . l:ctermfg .
      "       \ ' ctermbg=' . l:ctermbg .
      "       \ ' guifg='   . l:guifg .
      "       \ ' guibg='   . l:guibg .
      "       \ ' cterm=bold gui=bold'
      "
      " execute 'syntax match ' . l:group_name . ' /\<'. escape(l:word, '/\') . '\>/ containedin=ALL'
    endfor

    " remove highligh if not exist on golable list
    for l:word in keys(b:highlighted_words)
        " echom "Check Buffer:".l:word
        if !has_key(g:global_highlighted_words, l:word)
            let l:color_idx = b:highlighted_words[l:word].color_index
            let l:group_name = b:highlighted_words[l:word].group_name

            call HighlightWord(l:word, l:color_idx)

            " let g:global_highlighted_words[l:word] = l:word
            let g:global_highlighted_words[l:word] = {
                        \ 'color_index': l:color_idx,
                        \ 'group_name': l:group_name
                        \ }
        endif
    endfor
endfunction

