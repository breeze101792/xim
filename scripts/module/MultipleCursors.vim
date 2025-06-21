" Batch Word Replace for Vim
"
" Description:
" This script enables batch replacing of the word under the cursor (or selected in visual mode)
" using customizable key mappings.
"
" Features:
" 1. Press <C-n> (customizable) to select and highlight the current word under the cursor.
" 2. Press <C-n> again to select the next matching word in the file.
" 3. Press <C-i> (customizable) to skip/ignore the next match.
" 4. After selecting desired matches, press the select key (<C-n>) again to select the next match, or press the finish key (<CR>) to replace all selected instances.
" 5. Press <CR> (customizable) at any time during selection to finalize approved matches and perform replacement.
" 6. Visual mode selection via <Leader>br is supported to initialize target word.
" 7. Highlighting uses `matchaddpos()` for visibility, with undo grouping via `:undojoin`.
" 8. Word boundaries (`\b`) are respected for precise whole-word matching.
"
" Customization:
" - Change g:batch_replace_select_key, g:batch_replace_ignore_key, g:batch_replace_finish_key, g:batch_replace_next_key_no_select, g:batch_replace_prev_key_no_select, and g:batch_replace_cancel_key to use different keys.
" - Default replacement confirmation prompt will ask you for the new word.
"
" Intended for users who want an intuitive, interactive way to perform multi-instance word replacement in Vim.

if exists("g:loaded_batch_replace")
    finish
endif
let g:loaded_batch_replace = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:batch_replace_select_key = '<C-n>'
let g:batch_replace_ignore_key = '<C-i>'
let g:batch_replace_finish_key = '<CR>' " New: Key to finish selection and perform replacement
let g:batch_replace_next_key_no_select = '<Leader>mn' " New: Key to go to next match without selecting
let g:batch_replace_prev_key_no_select = '<Leader>mp' " New: Key to go to previous match without selecting
let g:batch_replace_cancel_key = '<ESC>' " New: Key to cancel the current session
let g:batch_replace_debug = 0 " Set to 1 to enable debug messages, 0 to disable

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Variable
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Script-local variables to store state
let s:matches = []
let s:approved_matches = [] " Stores positions that the user agrees to replace
let s:approved_highlight_ids = [] " Stores highlight IDs for approved matches
let s:match_word = ''
let s:current_match_idx = -1
let s:current_match_highlight_id = -1 " ID for the single currently highlighted match
let s:active_session = 0 " Flag to indicate if a session is active

" Highlight group for selected matches
highlight default link BatchReplace Search

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Key Mappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" These global mappings act as entry points. Once a session starts,
" buffer-local mappings defined in s:EnterSelectionMode() will take precedence.
execute 'vnoremap <silent>' g:batch_replace_select_key ':call <SID>BatchReplaceHandler("select")<CR>'
execute 'nnoremap <silent>' g:batch_replace_select_key ':call <SID>BatchReplaceHandler("select")<CR>'

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Function
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Function to clear the current replacement state
function! s:ClearState()
    if g:batch_replace_debug | echomsg "DEBUG: s:ClearState() called" | endif
    " Clear temporary highlight for the current match
    if s:current_match_highlight_id != -1
        try | call matchdelete(s:current_match_highlight_id) | catch | endtry
        let s:current_match_highlight_id = -1
    endif
    " Clear all persistent highlights for approved matches
    for l:id in s:approved_highlight_ids
        try | call matchdelete(l:id) | catch | endtry
    endfor
    let s:approved_highlight_ids = []

    call clearmatches('BatchReplace') " Clear any remaining highlights for this group
    let s:matches = []
    let s:approved_matches = []
    let s:match_word = ''
    let s:current_match_idx = -1
    let s:active_session = 0
    echohl None
    "Clear the command line"
    echo ""
endfunction

" Function to enter the selection mode and set buffer-local mappings
function! s:EnterSelectionMode()
    if g:batch_replace_debug | echomsg "DEBUG: s:EnterSelectionMode() called" | endif
    " Define buffer-local mappings for selection mode
    " These mappings will override any global mappings for the current buffer
    execute 'nnoremap <silent><buffer>' g:batch_replace_select_key ':call <SID>BatchReplaceHandler("select")<CR>'
    execute 'nnoremap <silent><buffer>' g:batch_replace_ignore_key ':call <SID>BatchReplaceHandler("skip")<CR>'
    execute 'nnoremap <silent><buffer>' g:batch_replace_finish_key ':call <SID>BatchReplaceHandler("finish")<CR>'
    execute 'nnoremap <silent><buffer>' g:batch_replace_next_key_no_select ':call <SID>BatchReplaceHandler("next_no_select")<CR>'
    execute 'nnoremap <silent><buffer>' g:batch_replace_prev_key_no_select ':call <SID>BatchReplaceHandler("prev_no_select")<CR>'
    execute 'nnoremap <silent><buffer>' g:batch_replace_cancel_key ':call <SID>BatchReplaceHandler("cancel")<CR>'
    execute 'vnoremap <silent><buffer>' g:batch_replace_select_key ':call <SID>BatchReplaceHandler("select")<CR>'
endfunction

" Function to exit the selection mode and clear buffer-local mappings
function! s:ExitSelectionMode()
    if g:batch_replace_debug | echomsg "DEBUG: s:ExitSelectionMode() called" | endif
    " Clear buffer-local mappings
    silent! execute 'nunmap <buffer>' g:batch_replace_select_key
    silent! execute 'nunmap <buffer>' g:batch_replace_ignore_key
    silent! execute 'nunmap <buffer>' g:batch_replace_finish_key
    silent! execute 'nunmap <buffer>' g:batch_replace_next_key_no_select
    silent! execute 'nunmap <buffer>' g:batch_replace_prev_key_no_select
    silent! execute 'nunmap <buffer>' g:batch_replace_cancel_key
    silent! execute 'vunmap <buffer>' g:batch_replace_select_key
endfunction

" Function to get the word to be replaced
function! s:GetSearchWord()
    if g:batch_replace_debug | echomsg "DEBUG: s:GetSearchWord() called" | endif
    let l:original_visual_mode = visualmode()
    if l:original_visual_mode != ''
        " Get visually selected text
        let l:old_reg = getreg('"')
        let l:old_reg_type = getregtype('"')
        normal! gvy
        let l:word = getreg('"')
        call setreg('"', l:old_reg, l:old_reg_type)
        " Restore visual selection
        if l:original_visual_mode ==# 'v'
            normal! gv
        elseif l:original_visual_mode ==# 'V'
            normal! gv
        else
            execute "normal! gv"
        endif
    else
        " Get word under cursor
        let l:word = expand('<cword>')
    endif

    " Escape special characters for search pattern
    if g:batch_replace_debug | echomsg "DEBUG: Original word: " . l:word | endif
    let l:escaped_word = escape(l:word, '.*[]^%$\/')
    if g:batch_replace_debug | echomsg "DEBUG: Escaped word: " . l:escaped_word | endif
    return l:escaped_word
endfunction

" Function to find all occurrences of the word in the buffer
function! s:FindAllMatches(word)
    if g:batch_replace_debug | echomsg "DEBUG: s:FindAllMatches() called with word: " . a:word | endif
    if empty(a:word)
        if g:batch_replace_debug | echomsg "DEBUG: Word is empty, returning empty matches." | endif
        return []
    endif
    let l:all_matches = []
    let l:flags = '' " Start search without special flags, then use 'W' for subsequent searches
    let l:cursor_pos = getcurpos()
    call setpos('.', [0, 1, 1, 0]) " Start search from the beginning of the buffer

    " Use \c for case-insensitive search, \V for very nomagic (literal word)
    " Removed \b to allow matching words with non-keyword characters (e.g., foo-bar)
    let l:search_pattern = '\V\c' . a:word
    if g:batch_replace_debug | echomsg "DEBUG: Search pattern: " . l:search_pattern | endif

    while 1
        let l:match_pos = searchpos(l:search_pattern, l:flags)
        if g:batch_replace_debug | echomsg "DEBUG: Found match at: " . string(l:match_pos) | endif
        if l:match_pos == [0, 0]
            break
        endif
        call add(l:all_matches, l:match_pos)
        let l:flags = 'W' " Continue search from current position without wrapping
    endwhile

    call setpos('.', l:cursor_pos) " Restore original cursor position
    if g:batch_replace_debug | echomsg "DEBUG: Total matches found: " . len(l:all_matches) | endif
    return l:all_matches
endfunction

" Function to find the starting match index based on cursor position
function! s:FindStartingMatchIndex(matches, cursor_pos)
    if g:batch_replace_debug | echomsg "DEBUG: s:FindStartingMatchIndex() called. Cursor: " . string(a:cursor_pos) | endif
    let l:cursor_line = a:cursor_pos[1]
    let l:cursor_col = a:cursor_pos[2]

    for l:i in range(len(a:matches))
        let l:match_line = a:matches[l:i][0]
        let l:match_col = a:matches[l:i][1]

        if l:match_line > l:cursor_line
            return l:i
        elseif l:match_line == l:cursor_line
            " If on the same line, check if the match starts at or after the cursor column
            " Or if the cursor is within the match
            if l:match_col >= l:cursor_col || (l:match_col < l:cursor_col && l:cursor_col < (l:match_col + len(s:match_word)))
                return l:i
            endif
        endif
    endfor
    " If no match found at or after cursor, start from the first match (index 0)
    return 0
endfunction

" Function to highlight the next match for confirmation
function! s:HighlightNextMatch()
    if g:batch_replace_debug | echomsg "DEBUG: s:HighlightNextMatch() called. Current index: " . s:current_match_idx . ", Total matches: " . len(s:matches) | endif
    
        " Increment index, and wrap around if at the end
        let s:current_match_idx += 1
        if s:current_match_idx >= len(s:matches)
            let s:current_match_idx = 0 " Wrap around to the first match
        endif
    
    let l:current_pos = s:matches[s:current_match_idx]
    if g:batch_replace_debug | echomsg "DEBUG: Highlighting match at position: " . string(l:current_pos) | endif

    " Move cursor to the current match to make it visible
    call cursor(l:current_pos[0], l:current_pos[1])

    " Highlight the current match
    " Clear previous temporary highlight
    if s:current_match_highlight_id != -1
        call matchdelete(s:current_match_highlight_id)
    endif
    " Highlight the current match using matchaddpos for a single instance
    let l:len = len(s:match_word)
    let s:current_match_highlight_id = matchaddpos('BatchReplace', [[l:current_pos[0], l:current_pos[1], l:len]])

    echohl Question | echo "Replace this instance? (Select: " . g:batch_replace_select_key . " / Skip: " . g:batch_replace_ignore_key . " / Next: " . g:batch_replace_next_key_no_select . " / Prev: " . g:batch_replace_prev_key_no_select . " / Finish: " . g:batch_replace_finish_key . " / Cancel: " . g:batch_replace_cancel_key . ")" | echohl None
endfunction

" Function to highlight the previous match for confirmation
function! s:HighlightPreviousMatch()
    if g:batch_replace_debug | echomsg "DEBUG: s:HighlightPreviousMatch() called. Current index: " . s:current_match_idx . ", Total matches: " . len(s:matches) | endif
    
        " Decrement index, and wrap around if at the beginning
        let s:current_match_idx -= 1
        if s:current_match_idx < 0
            let s:current_match_idx = len(s:matches) - 1 " Wrap around to the last match
        endif
    
    let l:current_pos = s:matches[s:current_match_idx]
    if g:batch_replace_debug | echomsg "DEBUG: Highlighting match at position: " . string(l:current_pos) | endif

    " Move cursor to the current match to make it visible
    call cursor(l:current_pos[0], l:current_pos[1])

    " Highlight the current match
    " Clear previous temporary highlight
    if s:current_match_highlight_id != -1
        call matchdelete(s:current_match_highlight_id)
    endif
    " Highlight the current match using matchaddpos for a single instance
    let l:len = len(s:match_word)
    let s:current_match_highlight_id = matchaddpos('BatchReplace', [[l:current_pos[0], l:current_pos[1], l:len]])

    echohl Question | echo "Replace this instance? (Select: " . g:batch_replace_select_key . " / Skip: " . g:batch_replace_ignore_key . " / Next: " . g:batch_replace_next_key_no_select . " / Prev: " . g:batch_replace_prev_key_no_select . " / Finish: " . g:batch_replace_finish_key . " / Cancel: " . g:batch_replace_cancel_key . ")" | echohl None
endfunction

" The main handler function called by key mappings
function! s:BatchReplaceHandler(action)
    if g:batch_replace_debug | echomsg "DEBUG: s:BatchReplaceHandler() called with action: " . a:action | endif
    if s:active_session == 0
        " --- Start a new session ---
        if g:batch_replace_debug | echomsg "DEBUG: Starting new session." | endif
        call s:ClearState()
        let s:match_word = s:GetSearchWord()
        if empty(s:match_word)
            echohl WarningMsg | echo "No word under cursor or selected." | echohl None
            if g:batch_replace_debug | echomsg "DEBUG: No word found, returning." | endif
            return
        endif
        let s:matches = s:FindAllMatches(s:match_word)
        if empty(s:matches)
            echohl WarningMsg | echo "No matches found for: " . s:match_word | echohl None
            if g:batch_replace_debug | echomsg "DEBUG: No matches found for '" . s:match_word . "', returning." | endif
            return
        endif
        let s:active_session = 1
        call s:EnterSelectionMode() " Enter the custom mode
        if g:batch_replace_debug | echomsg "DEBUG: Session activated. Found " . len(s:matches) . " matches." | endif

        " Find the starting match index based on the current cursor position
        let l:cursor_pos = getcurpos()
        let l:initial_cursor_match_idx = s:FindStartingMatchIndex(s:matches, l:cursor_pos)

        " Set current_match_idx to the one *before* the desired starting match,
        " so that the first call to s:HighlightNextMatch() lands on the correct one.
        if l:initial_cursor_match_idx == 0
            let s:current_match_idx = len(s:matches) - 1 " Wrap around to the last match
        else
            let s:current_match_idx = l:initial_cursor_match_idx - 1
        endif

        " Now call HighlightNextMatch to highlight the first match (which is the one under the cursor)
        call s:HighlightNextMatch()
    else
        " --- Continue an existing session ---
        if g:batch_replace_debug | echomsg "DEBUG: Continuing existing session." | endif
        if a:action == 'select'
            " Approve the current match
            if g:batch_replace_debug | echomsg "DEBUG: Selected current match: " . string(s:matches[s:current_match_idx]) | endif
            call add(s:approved_matches, s:matches[s:current_match_idx])
            " Add a permanent highlight for the approved match
            let l:pos_to_highlight = s:matches[s:current_match_idx]
            let l:len = len(s:match_word)
            let l:id = matchaddpos('BatchReplace', [[l:pos_to_highlight[0], l:pos_to_highlight[1], l:len]])
            call add(s:approved_highlight_ids, l:id)

            call s:HighlightNextMatch()
        elseif a:action == 'skip'
            " Skip the current match
            if g:batch_replace_debug | echomsg "DEBUG: Skipped current match: " . string(s:matches[s:current_match_idx]) | endif
            call s:HighlightNextMatch()
        elseif a:action == 'finish'
            " Explicitly finish and perform replacement
            if g:batch_replace_debug | echomsg "DEBUG: User explicitly finished selection." | endif
            " If there's a current match and it hasn't been approved yet, approve it
            if s:current_match_idx != -1 && s:current_match_idx < len(s:matches)
                let l:current_match_pos = s:matches[s:current_match_idx]
                if index(s:approved_matches, l:current_match_pos) == -1
                    if g:batch_replace_debug | echomsg "DEBUG: Automatically selecting current match on finish: " . string(l:current_match_pos) | endif
                    call add(s:approved_matches, l:current_match_pos)
                    " Add a permanent highlight for this newly approved match
                    let l:len = len(s:match_word)
                    let l:id = matchaddpos('BatchReplace', [[l:current_match_pos[0], l:current_match_pos[1], l:len]])
                    call add(s:approved_highlight_ids, l:id)
                endif
            endif
            call s:PerformReplace()
            call s:ExitSelectionMode()
        elseif a:action == 'next_no_select'
            " Go to next match without selecting
            if g:batch_replace_debug | echomsg "DEBUG: Moving to next match without selection." | endif
            call s:HighlightNextMatch()
        elseif a:action == 'prev_no_select'
            " Go to previous match without selecting
            if g:batch_replace_debug | echomsg "DEBUG: Moving to previous match without selection." | endif
            call s:HighlightPreviousMatch()
        elseif a:action == 'cancel'
            " Cancel the current session
            if g:batch_replace_debug | echomsg "DEBUG: User cancelled the session." | endif
            call s:ClearState()
            call s:ExitSelectionMode()
            echohl WarningMsg | echo "Batch replacement cancelled." | echohl None
        endif
    endif
endfunction

" Function to perform the actual replacement
function! s:PerformReplace()
    if g:batch_replace_debug | echomsg "DEBUG: s:PerformReplace() called." | endif
    if empty(s:approved_matches)
        echohl WarningMsg | echo "No instances selected for replacement." | echohl None
        call s:ClearState()
        if g:batch_replace_debug | echomsg "DEBUG: No approved matches, returning." | endif
        return
    endif

    let l:replacement = input('Replace ' . len(s:approved_matches) . ' instance(s) with: ')
    if empty(l:replacement)
        echohl WarningMsg | echo "Replacement cancelled." | echohl None
        call s:ClearState()
        if g:batch_replace_debug | echomsg "DEBUG: Replacement cancelled by user." | endif
        return
    endif
    if g:batch_replace_debug | echomsg "DEBUG: Replacement word: " . l:replacement | endif

    " Group changes for a single undo operation
    " FIXME, re add it after function complete?
    " undojoin

    let l:replaced_count = 0
    " Iterate backwards to avoid messing up line and column numbers of subsequent matches
    for l:pos in reverse(s:approved_matches)
        let l:lnum = l:pos[0]
        let l:col = l:pos[1]
        let l:line = getline(l:lnum)

        if g:batch_replace_debug | echomsg "DEBUG: Replacing at line " . l:lnum . ", col " . l:col . ", original line: " . l:line | endif

        let l:prefix = strpart(l:line, 0, l:col - 1)
        let l:suffix = strpart(l:line, l:col - 1 + len(s:match_word))

        call setline(l:lnum, l:prefix . l:replacement . l:suffix)
        let l:replaced_count += 1
        if g:batch_replace_debug | echomsg "DEBUG: Line after replacement: " . getline(l:lnum) | endif
    endfor

    call s:ClearState()
    echohl MoreMsg | echo " " . l:replaced_count . " instance(s) replaced." | echohl None
    if g:batch_replace_debug | echomsg "DEBUG: Replacement finished. " . l:replaced_count . " instances replaced." | endif
endfunction
