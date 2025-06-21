
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Map shortcut keys
nnoremap ml :call MarkJumpToMarkList()<CR>
nnoremap mm :call MarkToggleLine()<CR>
nnoremap mn :call MarkJumpToNext()<CR>
nnoremap mp :call MarkJumpToPrev()<CR>
nnoremap mt :call MarkingToggle()<CR>

" Commands
command! MarkJumpToMarkList call MarkJumpToMarkList()
command! MarkJumpToNext call MarkJumpToNext()
command! MarkJumpToPrev call MarkJumpToPrev()
command! MarkToggleLine call MarkToggleLine()
command! MarkingToggle call MarkingToggle()

" Debuging
augroup BookmarkSync
    autocmd!
    autocmd WinEnter,BufEnter * call MarkSyncMarks()
augroup END

""""    Variable
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Define global variables
let g:bookmark_marking_enabled = 1

 " Use a dictionary to store line numbers and match IDs
" let b:bookmark_marked_lines = {}

" Center jumped line.
let g:bookmark_center_jumped_line = 0

" Define highlight group, 232~255 gray scal
highlight BookMarkLine cterm=bold ctermbg=240 gui=bold guibg=#585858
" highlight BookMarkLine ctermbg=236 guibg=#303030
" highlight BookMarkLine ctermbg=240 guibg=#585858

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Function
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Toggle marking functionality
function! MarkingToggle()
    if g:bookmark_marking_enabled
        let g:bookmark_marking_enabled = 0
        echo "Marking functionality disabled."
        " Clear all highlights
        call ClearAllMarks()
    else
        let g:bookmark_marking_enabled = 1
        echo "Marking functionality enabled."
    endif
endfunction

" Mark the current line
function! MarkLine()
    if !g:bookmark_marking_enabled
        echo "Please enable marking functionality first."
        return
    endif
    if ! exists('b:bookmark_marked_lines')
        call ClearAllMarks()
    endif
    let l:lnum = line('.')
    if !has_key(b:bookmark_marked_lines, l:lnum)
        " Highlight the current line
        let l:matchid = matchadd('BookMarkLine', '\%' . l:lnum . 'l')
        " Store line number and match ID
        let b:bookmark_marked_lines[l:lnum] = l:matchid
        " Record matched id
        if !exists('w:match_ids')
            let w:match_ids = {}
        endif
        let w:match_ids[l:lnum] = l:matchid
        echo "Marked line " . l:lnum . "."
    else
        echo "Line " . l:lnum . " is already marked."
    endif
endfunction

" Unmark the current line
function! UnmarkLine()
    if ! exists('b:bookmark_marked_lines')
        call ClearAllMarks()
    endif
    let l:lnum = line('.')
    if has_key(b:bookmark_marked_lines, l:lnum)
        " Get match ID and delete highlight
        let l:matchid = b:bookmark_marked_lines[l:lnum]
        call matchdelete(l:matchid)
        " Remove line number from marked lines
        call remove(b:bookmark_marked_lines, l:lnum)
        " Remove line number from marked lines on windows variable
        if exists('w:match_ids') && has_key(w:match_ids, l:lnum)
            call remove(w:match_ids, l:lnum)
        endif
        echo "Unmarked line " . l:lnum . "."
    else
        echo "Line " . l:lnum . " is not marked."
    endif
endfunction

" Toggle mark on the current line
function! MarkToggleLine()
    if !g:bookmark_marking_enabled
        echo "Please enable marking functionality first."
        return
    endif
    if ! exists('b:bookmark_marked_lines')
        call ClearAllMarks()
    endif
    let l:lnum = line('.')
    if has_key(b:bookmark_marked_lines, l:lnum)
        " If line is marked, unmark it
        call UnmarkLine()
    else
        " If line is not marked, mark it
        call MarkLine()
    endif
endfunction

" Clear all marks and highlights
function! ClearAllMarks()
    if exists('w:match_ids')
        for l:lnum in keys(w:match_ids)
            let l:matchid = w:match_ids[l:lnum]
            call matchdelete(l:matchid)
        endfor
    endif
    let w:match_ids = {}
    let b:bookmark_marked_lines = {}
endfunction

" Jump to a marked line from a list
function! MarkJumpToMarkList()
    if ! exists('b:bookmark_marked_lines')
        call ClearAllMarks()
    endif
    if empty(keys(b:bookmark_marked_lines))
        echo "No marked lines."
        return
    endif
    " Sort line numbers
    let l:marked_lnums = sort(map(keys(b:bookmark_marked_lines), 'str2nr(v:val)'))
    " Build choice list
    let l:choices = []
    for l:lnum in l:marked_lnums
        let l:line_text = getline(l:lnum)
        call add(l:choices, l:lnum . ': ' . substitute(l:line_text, '^\s*', '', ''))
    endfor
    let l:choice = inputlist(['Select a line to jump to:'] + l:choices)
    if l:choice > 0 && l:choice <= len(l:marked_lnums)
        execute l:marked_lnums[l:choice - 1]
        if g:bookmark_center_jumped_line == 1
            normal! zz " Center the jumped line
        endif
    else
        echo "Invalid choice."
    endif
endfunction

" Jump to previous marked line
function! MarkJumpToPrev()
    if ! exists('b:bookmark_marked_lines')
        call ClearAllMarks()
    endif
    if empty(keys(b:bookmark_marked_lines))
        echo "No marked lines."
        return
    endif
    let l:current_line = line('.')
    " Get marked line numbers
    let l:marked_lnums = sort(map(keys(b:bookmark_marked_lines), 'str2nr(v:val)'))
    " Filter lines less than current line
    let l:prev_marks = filter(copy(l:marked_lnums), 'v:val < l:current_line')
    if !empty(l:prev_marks)
        let l:target_line = l:prev_marks[-1]
        execute l:target_line
        if g:bookmark_center_jumped_line == 1
            normal! zz " Center the jumped line
        endif
        echo "Jumped to previous marked line " . l:target_line . "."
    else
        echo "No previous marked line."
    endif
endfunction

" Jump to next marked line
function! MarkJumpToNext()
    if ! exists('b:bookmark_marked_lines')
        call ClearAllMarks()
    endif
    if empty(keys(b:bookmark_marked_lines))
        echo "No marked lines."
        return
    endif
    let l:current_line = line('.')
    " Get marked line numbers
    let l:marked_lnums = sort(map(keys(b:bookmark_marked_lines), 'str2nr(v:val)'))
    " Filter lines greater than current line
    let l:next_marks = filter(copy(l:marked_lnums), 'v:val > l:current_line')
    if !empty(l:next_marks)
        let l:target_line = l:next_marks[0]
        execute l:target_line
        if g:bookmark_center_jumped_line == 1
            normal! zz " Center the jumped line
        endif
        echo "Jumped to next marked line " . l:target_line . "."
    else
        echo "No next marked line."
    endif
endfunction

" Sync mark between files.
function! MarkSyncMarks()
    if ! exists('b:bookmark_marked_lines')
        call ClearAllMarks()
    endif
    if ! exists('w:match_ids')
        let w:match_ids = {}
    endif
    " Add bookmark
    for l:lnum in keys(b:bookmark_marked_lines)
        let l:matchid = b:bookmark_marked_lines[l:lnum]
        " Check If id exist.
        if !exists('w:match_ids') || !has_key(w:match_ids, l:lnum)
            " echom "Add ID:".matchid
            call matchadd('BookMarkLine', '\%' . l:lnum . 'l', 10, l:matchid)
            " Record matched id
            if !exists('w:match_ids')
                let w:match_ids = {}
            endif
            let w:match_ids[l:lnum] = l:matchid
        endif
    endfor

    try
        " Remove bookmark
        for l:lnum in keys(w:match_ids)
            let l:matchid = w:match_ids[l:lnum]
            " Check If id exist.
            if !exists('b:bookmark_marked_lines') || !has_key(b:bookmark_marked_lines, l:lnum)
                " echom "Remove ID:".matchid
                " delete highlight
                call matchdelete(l:matchid)
                " Remove line number from marked lines
                call remove(w:match_ids, l:lnum)
            endif
        endfor
    endtry
endfunction
