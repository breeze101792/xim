
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Map shortcut keys
nnoremap mt :call MarkingToggle()<CR>
nnoremap mp :call MarkJumpToPrev()<CR>
nnoremap mn :call MarkJumpToNext()<CR>
nnoremap mm :call MarkToggleLine()<CR>
nnoremap ml :call MarkJumpToMarkList()<CR>

" Commands
command! MarkingToggle call MarkingToggle()
command! MarkJumpToMarkList call MarkJumpToMarkList()

""""    Variable
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Define global variables
let g:marking_enabled = 1
let g:marked_lines = {} " Use a dictionary to store line numbers and match IDs

" Define highlight group
highlight MarkedLine cterm=bold ctermbg=DarkGrey gui=bold guibg=DarkGrey

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Function
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Toggle marking functionality
function! MarkingToggle()
    if g:marking_enabled
        let g:marking_enabled = 0
        echo "Marking functionality disabled."
        " Clear all highlights
        call ClearAllMarks()
    else
        let g:marking_enabled = 1
        echo "Marking functionality enabled."
    endif
endfunction

" Mark the current line
function! MarkLine()
    if !g:marking_enabled
        echo "Please enable marking functionality first."
        return
    endif
    let l:lnum = line('.')
    if !has_key(g:marked_lines, l:lnum)
        " Highlight the current line
        let l:matchid = matchadd('MarkedLine', '\%' . l:lnum . 'l')
        " Store line number and match ID
        let g:marked_lines[l:lnum] = l:matchid
        echo "Marked line " . l:lnum . "."
    else
        echo "Line " . l:lnum . " is already marked."
    endif
endfunction

" Unmark the current line
function! UnmarkLine()
    let l:lnum = line('.')
    if has_key(g:marked_lines, l:lnum)
        " Get match ID and delete highlight
        let l:matchid = g:marked_lines[l:lnum]
        call matchdelete(l:matchid)
        " Remove line number from marked lines
        call remove(g:marked_lines, l:lnum)
        echo "Unmarked line " . l:lnum . "."
    else
        echo "Line " . l:lnum . " is not marked."
    endif
endfunction

" Toggle mark on the current line
function! MarkToggleLine()
    if !g:marking_enabled
        echo "Please enable marking functionality first."
        return
    endif
    let l:lnum = line('.')
    if has_key(g:marked_lines, l:lnum)
        " If line is marked, unmark it
        call UnmarkLine()
    else
        " If line is not marked, mark it
        call MarkLine()
    endif
endfunction

" Clear all marks and highlights
function! ClearAllMarks()
    for l:lnum in keys(g:marked_lines)
        let l:matchid = g:marked_lines[l:lnum]
        call matchdelete(l:matchid)
    endfor
    let g:marked_lines = {}
endfunction

" Jump to a marked line from a list
function! MarkJumpToMarkList()
    if empty(keys(g:marked_lines))
        echo "No marked lines."
        return
    endif
    " Sort line numbers
    let l:marked_lnums = sort(map(keys(g:marked_lines), 'str2nr(v:val)'))
    " Build choice list
    let l:choices = []
    for l:lnum in l:marked_lnums
        let l:line_text = getline(l:lnum)
        call add(l:choices, l:lnum . ': ' . substitute(l:line_text, '^\s*', '', ''))
    endfor
    let l:choice = inputlist(['Select a line to jump to:'] + l:choices)
    if l:choice > 0 && l:choice <= len(l:marked_lnums)
        execute l:marked_lnums[l:choice - 1]
        normal! zz " Center the jumped line
    else
        echo "Invalid choice."
    endif
endfunction

" Jump to previous marked line
function! MarkJumpToPrev()
    if empty(keys(g:marked_lines))
        echo "No marked lines."
        return
    endif
    let l:current_line = line('.')
    " Get marked line numbers
    let l:marked_lnums = sort(map(keys(g:marked_lines), 'str2nr(v:val)'))
    " Filter lines less than current line
    let l:prev_marks = filter(copy(l:marked_lnums), 'v:val < l:current_line')
    if !empty(l:prev_marks)
        let l:target_line = l:prev_marks[-1]
        execute l:target_line
        normal! zz
        echo "Jumped to previous marked line " . l:target_line . "."
    else
        echo "No previous marked line."
    endif
endfunction

" Jump to next marked line
function! MarkJumpToNext()
    if empty(keys(g:marked_lines))
        echo "No marked lines."
        return
    endif
    let l:current_line = line('.')
    " Get marked line numbers
    let l:marked_lnums = sort(map(keys(g:marked_lines), 'str2nr(v:val)'))
    " Filter lines greater than current line
    let l:next_marks = filter(copy(l:marked_lnums), 'v:val > l:current_line')
    if !empty(l:next_marks)
        let l:target_line = l:next_marks[0]
        execute l:target_line
        normal! zz
        echo "Jumped to next marked line " . l:target_line . "."
    else
        echo "No next marked line."
    endif
endfunction
