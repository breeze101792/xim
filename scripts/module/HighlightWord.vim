
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Map to toggle highlighting
" nnoremap <leader>th :call HighlightWordsToggle(expand('<cexpr>'))<CR>
nnoremap <leader>th :call HighlightWordsToggle(expand('<cword>'))<CR>

" Map to clear all highlights
nnoremap <leader>ch :call HighlightedAllWordsToggle()<CR>

" Commands
command! -nargs=1 HighlightWordsToggle call HighlightWordsToggle(<q-args>)

command! HighlightedAllWordsToggle call HighlightedAllWordsToggle()

""""    Variable
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:highlighted_words = {}

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Function
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Define a function to toggle highlighting of specified words with different colors
function! HighlightWordsToggle(...) abort
  " If no arguments are provided, prompt the user to enter words
  if a:0 == 0
    let l:input = input('Enter words to toggle highlight (separate with spaces): ')
    let l:words = split(l:input)
  else
    " Use the provided arguments as the list of words
    let l:words = a:000
  endif

  " Ensure the global variable for tracking highlighted words exists
  if !exists('g:highlighted_words')
    let g:highlighted_words = {}
  endif

  " Define a list of color schemes
  let l:color_list = [
        \ ['White', 'Red',    '#ffffff', '#ff0000'],
        \ ['Black', 'Yellow', '#000000', '#ffff00'],
        \ ['White', 'Blue',   '#ffffff', '#0000ff'],
        \ ['Black', 'Green',  '#000000', '#00ff00'],
        \ ['White', 'Magenta','#ffffff', '#ff00ff'],
        \ ['Black', 'Cyan',   '#000000', '#00ffff'],
        \ ['White', 'Black',  '#ffffff', '#000000'],
        \ ['Black', 'White',  '#000000', '#ffffff'],
        \ ]
  " let l:color_list = [['White', 'Red',    '#ffffff', '#ff0000']]

  " Initialize color index
  let l:color_index = len(g:highlighted_words) % len(color_list)

  " Iterate over each word to toggle its highlight
  for l:word in l:words
    " Generate a unique highlight group name based on the word
    let l:group_name = 'UserHL_' . substitute(l:word, '\W', '_', 'g')

    " Check if the highlight group already exists
    if has_key(g:highlighted_words, l:group_name)
      " If it exists, remove the highlight
      execute 'syntax clear ' . l:group_name
      execute 'highlight clear ' . l:group_name
      " Remove the entry from the tracking list
      call remove(g:highlighted_words, l:group_name)
      echo 'Removed highlight for "' . l:word . '".'
    else
      " If it does not exist, add the highlight
      " Get the color scheme for the current word
      let l:ctermfg = l:color_list[l:color_index][0]
      let l:ctermbg = l:color_list[l:color_index][1]
      let l:guifg   = l:color_list[l:color_index][2]
      let l:guibg   = l:color_list[l:color_index][3]

      " Increment color index and wrap around if necessary
      let l:color_index = (l:color_index + 1) % len(l:color_list)

      " Define the highlight group style
      execute 'highlight ' . l:group_name .
            \ ' ctermfg=' . l:ctermfg .
            \ ' ctermbg=' . l:ctermbg .
            \ ' guifg='   . l:guifg .
            \ ' guibg='   . l:guibg .
            \ ' cterm=bold gui=bold'

      " Define the syntax match to highlight the whole word, case-sensitive
      " execute 'syntax match ' . l:group_name . ' /\<'. escape(l:word, '/\') . '\>/ containedin=ALL'
      execute 'syntax match ' . l:group_name . ' /\V' . escape(l:word, '/\') . '/ containedin=ALL'

      " Add the highlight group to the tracking list
      let g:highlighted_words[l:group_name] = l:word
      echo 'Added highlight for "' . l:word . '".'
    endif
  endfor
endfunction

" Define a function to clear all highlighted words
function! HighlightedAllWordsToggle() abort
  if exists('g:highlighted_words')
    for l:group_name in keys(g:highlighted_words)
      " Remove syntax and highlight settings for each group
      execute 'syntax clear ' . l:group_name
      execute 'highlight clear ' . l:group_name
    endfor
    unlet g:highlighted_words
    echo 'All highlights cleared.'
  else
    echo 'No highlights to clear.'
  endif
endfunction
