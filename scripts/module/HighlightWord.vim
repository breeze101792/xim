""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Map to add highlighting
nnoremap <leader>ha :call HighlightWordsAdd(expand('<cword>'))<CR>

" Map to remove highlighting
nnoremap <leader>hr :call HighlightWordsRemove(expand('<cword>'))<CR>

" Map to toggle highlights
nnoremap <leader>m :call HighlightWordsToggle(expand('<cword>'))<CR>

" Map to clear all highlights
nnoremap <leader>ch :call HighlightClearAllWords()<CR>

" Commands
command! -nargs=1 HighlightWordsAdd call HighlightWordsAdd(<q-args>)
command! -nargs=1 HighlightWordsRemove call HighlightWordsRemove(<q-args>)
command! HighlightClearAllWords call HighlightClearAllWords()
command! HighlightSyncGlobal call HighlightSyncGlobal()

" Global list maintenance
autocmd WinEnter,BufEnter * :call HighlightSyncGlobal()

""""    Variable
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Define a list of color schemes
" let g:highlighted_color_list = [
"             \ ['White', 'Red',    '#ffffff', '#ff0000'],
"             \ ['Black', 'Yellow', '#000000', '#ffff00'],
"             \ ['White', 'Blue',   '#ffffff', '#0000ff'],
"             \ ['Black', 'Green',  '#000000', '#00ff00'],
"             \ ['White', 'Magenta','#ffffff', '#ff00ff'],
"             \ ['Black', 'Cyan',   '#000000', '#00ffff'],
"             \ ['White', 'Black',  '#ffffff', '#000000'],
"             \ ['Black', 'White',  '#000000', '#ffffff'],
"             \ ]

" \ [255 , 196 , '#ffffff' , '#ff0000'] ,
" \ [232 , 226 , '#000000' , '#ffff00'] ,
" \ [255 , 27  , '#ffffff' , '#0000ff'] ,
" \ [232 , 46  , '#000000' , '#00ff00'] ,
" \ [255 , 199 , '#ffffff' , '#ff00ff'] ,
" \ [232 , 51  , '#000000' , '#00ffff'] ,
" \ [255 , 16  , '#ffffff' , '#000000'] ,
" \ [232 , 15  , '#000000' , '#ffffff'] ,
let g:highlighted_color_list = [
            \ ['Black', 'Cyan',   '#000000', '#00ffff'],
            \ ['Black', 'White',  '#000000', '#ffffff'],
            \ ['Black', 'Yellow', '#000000', '#ffff00'],
            \ ['White', 'Black',  '#ffffff', '#000000'],
            \ ['White', 'Blue',   '#ffffff', '#0000ff'],
            \ ['White', 'Green',  '#ffffff', '#00ff00'],
            \ ['White', 'Magenta','#ffffff', '#ff00ff'],
            \ ['White', 'Red',    '#ffffff', '#ff0000'],
            \ [232 , 117 , '#000000' , '#40e0d0'] ,
            \ [232 , 166 , '#000000' , '#98fb98'] ,
            \ [232 , 179 , '#000000' , '#cd7f32'] ,
            \ [232 , 208 , '#000000' , '#ffa500'] ,
            \ [232 , 213 , '#000000' , '#ffbf00'] ,
            \ [232 , 214 , '#000000' , '#ff7f50'] ,
            \ [232 , 219 , '#000000' , '#ff69b4'] ,
            \ [232 , 220 , '#000000' , '#ffd700'] ,
            \ [232 , 227 , '#000000' , '#f4a460'] ,
            \ [232 , 229 , '#000000' , '#dda0dd'] ,
            \ [232 , 235 , '#000000' , '#ee82ee'] ,
            \ [232 , 245 , '#000000' , '#808080'] ,
            \ [232 , 250 , '#000000' , '#c0c0c0'] ,
            \ [232 , 255 , '#000000' , '#f5f5dc'] ,
            \ [232 , 82  , '#000000' , '#32cd32'] ,
            \ [255 , 118 , '#ffffff' , '#4682b4'] ,
            \ [255 , 124 , '#ffffff' , '#800000'] ,
            \ [255 , 130 , '#ffffff' , '#4b0082'] ,
            \ [255 , 135 , '#ffffff' , '#8a2be2'] ,
            \ [255 , 140 , '#ffffff' , '#808000'] ,
            \ [255 , 171 , '#ffffff' , '#a52a2a'] ,
            \ [255 , 196 , '#ffffff' , '#ff0000'] ,
            \ [255 , 23  , '#ffffff' , '#000080'] ,
            \ [255 , 44  , '#ffffff' , '#008080'] ,
            \ ]

" Global list of highlighted words and their colors
if ! exists('g:global_highlighted_words')
    let g:global_highlighted_words = {}
endif

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

    " execute 'syntax match ' . l:group_name . ' /\<'. escape(a:word, '/\') . '\>/ containedin=ALL'
    " There is a bug, when doing a 2nd hl, will cuase ignore case.
    execute 'syntax match ' . l:group_name . ' /'. escape(a:word, '/\') . '\C/ containedin=ALL'
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
          let g:global_highlighted_words[l:word] = {
                      \ 'color_index': g:highlight_color_index,
                      \ 'group_name': l:group_name
                      \ }
      endif
      call HighlightWord(l:word, g:highlight_color_index)

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
function! HighlightClearAllWords() abort
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
function! HighlightSyncGlobal() abort
    " echom "HighlightSyncGlobal"
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

