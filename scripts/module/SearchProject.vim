" File: search_project.vim
" Description: Search for files in the root folder and display results in quickfix window

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Map leader key to trigger search
nnoremap <leader>sg :call SearchProjectGrep(expand("<cword>"))<CR>

" Map leader key to trigger search
nnoremap <leader>sf :call SearchProjectFind(expand("<cword>"))<CR>

nnoremap <C-p> :call SearchProjectFindInput()<CR>

command! SearchProjectFind call SearchProjectFind()
command! SearchProjectGrep call SearchProjectGrep()

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Function
""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! SearchProjectRoot()
    let git_root = system('git rev-parse --show-toplevel 2>/dev/null')
    if git_root != ''
        return trim(git_root)
    endif

    " If not in git repo, check for other repo indicators (e.g., .hg, .svn)
    let repo_root = system('pwd')
    if repo_root != ''
        return trim(repo_root)
    endif

    return ''
endfunction

function! SearchProjectFindInput()
    let pattern = input("Find file: ")
    call SearchProjectFind(pattern)
endfunction
function! SearchProjectGrepInput()
    let pattern = input("Grep file: ")
    call SearchProjectGrep(pattern)
endfunction

function! SearchProjectFind(pattern)
    " Get root directory (assuming project root is current working directory)
    let root = SearchProjectRoot()

    " Search for files matching the pattern
    " let command = 'find ' . root . ' -type f -iname ' . shellescape(a:pattern) . ' -print'
    let command = 'find ' . root . ' -type f -iname "*' . a:pattern . '*" -print'
    " return 0
    let output = system(command)

    " Parse results and populate location list
    let results = []
    let lines = split(output, "\n")

    for line in lines
        if line != ''
            let file = line
            let lnum = 1  " Default to line 1 since we're just searching by filename

            call add(results, {
                        \ 'bufnr': 0,
                        \ 'filename': file,
                        \ 'lnum': lnum,
                        \ 'text': 'Matched file',
                        \ 'vcol': 0
                        \ })
        endif
    endfor

    " Display results in location list
    if len(results) > 0
        call setloclist(0, results, 'r')
        lwindow
    else
        echo "No files found matching pattern: " . a:pattern
    endif
endfunction

function! SearchProjectGrep(pattern)
    " Get root directory (assuming project root is current working directory)
    let root = SearchProjectRoot()

    " Search for files containing the pattern
    let command = 'find ' . root . ' -type f -exec grep -Hn ' . shellescape(a:pattern) . ' {} +'
    let output = system(command)

    " Parse results and populate location list
    let results = []
    let lines = split(output, "\n")

    for line in lines
        if line =~ '^.*:'  " Match lines in format: file:line:content
            let parts = split(line, ":", 3)
            let file = parts[0]
            let lnum = parts[1]
            let text = parts[2]

            call add(results, {
                        \ 'bufnr': 0,
                        \ 'filename': file,
                        \ 'lnum': lnum,
                        \ 'text': text,
                        \ 'vcol': 0
                        \ })
        endif
    endfor

    " Display results in location list
    if len(results) > 0
        call setloclist(0, results, 'r')
        lwindow
    else
        echo "No results found"
    endif
endfunction
