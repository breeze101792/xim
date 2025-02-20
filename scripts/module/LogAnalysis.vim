" File: log_analysis.vim
" Description: Log file analysis script with filter functions
" Author: [Your Name]

" Define filter patterns
" Lines to include (mandatory patterns)
" Lines to exclude (exclusion patterns)
" Filter status
let g:log_filters = {
    \ 'include': [],
    \ 'exclude': [],
    \ 'enabled': v:true
\ }

" Example filter patterns (modify according to your needs)
" Include patterns (mandatory matches)
" Include lines with ERROR
" Include lines with CRITICAL
" Include lines with WARN
" Include lines with timestamp
let g:log_filters.include = [
    \ 'ERROR',
    \ 'CRITICAL',
    \ 'WARN',
    \ '\d\+:\d\+:\d\+',
\ ]

" Exclude patterns (lines to remove)
" Exclude DEBUG lines
" Exclude INFO lines
" Exclude kernel messages
let g:log_filters.exclude = [
    \ 'DEBUG',
    \ 'INFO',
    \ 'kernel:',
\ ]

" Function: Toggle filters
function! ToggleFilters()
    let g:log_filters.enabled = !g:log_filters.enabled
    echo 'Log filters ' . (g:log_filters.enabled ? 'enabled' : 'disabled')
    call UpdateLogView()
endfunction

" Function: Update log view based on filters
" function! UpdateLogView()
"     if g:log_filters.enabled
"         " Apply include and exclude filters
"         %s/\\(.*\\)\n/\=submatch(1) =~? join(g:log_filters.include, '\|') && submatch(1) !~? join(g:log_filters.exclude, '\|') ? submatch(0) : ''/ge
"     else
"         " Show all lines
"         %s/\n/\r/g
"     endif
"     redraw
" endfunction
function! UpdateLogView()
    if g:log_filters.enabled
        echom 'Filters are enabled'
        echom 'Include patterns: ' . join(g:log_filters.include, ', ')
        echom 'Exclude patterns: ' . join(g:log_filters.exclude, ', ')
        " Apply include and exclude filters
        " %s/\\(.*\\)\n/\=submatch(1) =~? join(g:log_filters.include, '\|') && submatch(1) !~? join('DEBUG', '\|') ? submatch(0) : ''/ge
        %s/\\(.*\\)\n/\=submatch(1) !~? join('DEBUG', '\|') ? submatch(0) : ''/ge
    else
        echom 'Filters are disabled'
        " Show all lines
        %s/\n/\r/g
    endif
    redraw
endfunction

" Function: Add new filter pattern
function! AddFilter(pattern, type)
    call add(g:log_filters[a:type], a:pattern)
    call UpdateLogView()
endfunction

" Function: Remove filter pattern
function! RemoveFilter(pattern, type)
    let idx = index(g:log_filters[a:type], a:pattern)
    if idx != -1
        call remove(g:log_filters[a:type], idx)
        call UpdateLogView()
    endif
endfunction

" Key mappings
nnoremap <F5> :call ToggleFilters()<CR>
nnoremap <F6> :call AddFilter(input('Enter include pattern: '), 'include')<CR>
nnoremap <F7> :call AddFilter(input('Enter exclude pattern: '), 'exclude')<CR>
nnoremap <F8> :call RemoveFilter(input('Enter pattern to remove: '), input('Enter type (include/exclude): '))<CR>

" Auto-update when filters change
augroup LogFilters
    autocmd!
    autocmd CursorHold * call UpdateLogView()
augroup END

" Initialize
call UpdateLogView()
