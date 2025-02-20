" File: CodeTags.vim
" Description: Setup ctags and cscope databases for the project

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Auto-command to setup tags when entering a directory
" augroup ProjectTags
"     autocmd!
"     autocmd BufEnter * call CodeTagSetup()
" augroup END

" Map a key to trigger the setup
" nnoremap <leader>st :call SetupCtagsCscope()<CR>
if has('cscope')
    nnoremap <silent>ca :cscope find a <cword><CR>
    nnoremap <silent>cc :cscope find c <cword><CR>
    nnoremap <silent>cd :cscope find d <cword><CR>
    nnoremap <silent>ce :cscope find e <cword><CR>
    nnoremap <silent>cf :cscope find f <cword><CR>
    nnoremap <silent>cg :cscope find g <cword><CR>
    nnoremap <silent>ci :cscope find i <cword><CR>
    nnoremap <silent>cs :cscope find s <cword><CR>
    nnoremap <silent>ct :cscope find t <cword><CR>
endif

" command! CodeTagGenerateTags call CodeTagGenerateTags()
command! CodeTagLoadTags call CodeTagLoadTags()
command! CodeTagSetup call CodeTagSetup()
command! CodeTagUpdateTags call CodeTagUpdateTags()

""""    Variable
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:codetag_folder_name='.vimproject'
let g:codetag_ctag_name='tags'
let g:codetag_proj_list_name='proj.files'
let g:codetag_cscope_name='cscope.db'

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Function
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Function to find the root directory (git root or repo root)
function! CodeTagGetProjectRoot()
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

" Function to generate source list
function! CodeTagGenerateSourceList(search_path, src_list_path)
    call system('find ' . a:search_path . ' -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" > ' . a:src_list_path)
endfunc

" Function to generate source tags
function! CodeTagGenerateCtags(tag_path, src_list_path)
    if ! filereadable(a:src_list_path)
        echoe "Project list file not found.".a:src_list_path
        return 1
    endif
    call system('ctags -R --c++-kinds=+p --C-kinds=+p --fields=+iaS --extra=+q -L ' . a:src_list_path . ' -f ' . a:tag_path)
endfunc
function! CodeTagGenerateCscope(tag_path, src_list_path)
    if ! filereadable(a:src_list_path)
        echoe "Project list file not found.".a:src_list_path
        return 1
    endif
    call system('cscope -c -b -R -q -U -i ' . a:src_list_path . ' -f '. a:tag_path)
endfunc

" Function to generate ctags and cscope databases
function! CodeTagGenerateTags()
    let user_input=0
    let root = CodeTagGetProjectRoot()
    if root == ''
        echo "Error: Could not determine project root"
        return
    endif

    " Create tags directory if it doesn't exist
    " let tags_dir = root . '/tags'
    let tags_dir = root . '/' . g:codetag_folder_name

    if !isdirectory(tags_dir)
        call system('mkdir -p ' . tags_dir)
    endif

    " Generate project list
    let project_list_file = tags_dir . '/'.g:codetag_proj_list_name
    echom "Generate project srouce code list ".project_list_file
    if filereadable(project_list_file)
        " echo "Project list already exists. Do you want to rebuild it? (y/n)"
        let answer = input("Cscope list already exists. Do you want to rebuild it? (y/n)")
        echo ""
        if answer =~ '^[Yy]$'
            " call system('find ' . root . ' -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" > ' . project_list_file)
            call CodeTagGenerateSourceList(root, project_list_file)
        endif
    else
        " call system('find ' . root . ' -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" > ' . project_list_file)
        call CodeTagGenerateSourceList(root, project_list_file)
    endif

    " Generate ctags
    let ctags_file = tags_dir . '/'.g:codetag_ctag_name
    echom "Generate ctags ". ctags_file
    if filereadable(ctags_file) && l:user_input
        " echo "CTags file already exists. Do you want to rebuild it? (y/n)"
        let answer = input("CTags file already exists. Do you want to rebuild it? (y/n)")
        echo ""
        if answer =~ '^[Yy]$'
            " call system('ctags -R --c++-kinds=+p --C-kinds=+p --fields=+iaS --extra=+q -L ' . project_list_file . ' -f ' . ctags_file)
            " call system('ctags -R --fields=+iaS --extra=+q --language-force=c++ -f ' . ctags_file . ' ' . root)
        call CodeTagGenerateCtags(ctags_file, project_list_file)
        endif
    else
        " call system('ctags -R --c++-kinds=+p --C-kinds=+p --fields=+iaS --extra=+q -L ' . project_list_file . ' -f ' . ctags_file)
        " call system('ctags -R --fields=+iaS --extra=+q --language-force=c++ -f ' . ctags_file . ' ' . root)
        call CodeTagGenerateCtags(ctags_file, project_list_file)
    endif

    " Generate cscope
    let cscope_tags = tags_dir . '/'.g:codetag_cscope_name
    echom "Generate cscope ".cscope_tags
    if filereadable(cscope_tags) && l:user_input
        " echo "Cscope file already exists. Do you want to rebuild it? (y/n)"
        let answer = input("Cscope file already exists. Do you want to rebuild it? (y/n)")
        echo ""
        if answer =~ '^[Yy]$'
            " call system('cscope -cRbq -i ' . project_list_file)
            " call system('cscope -c -b -R -q -U -i ' . project_list_file . ' -f '. cscope_tags)
            call CodeTagGenerateCscope(cscope_tags, project_list_file)
        endif
    else
        " call system('cscope -c -b -R -q -U -i ' . project_list_file . ' -f '. cscope_tags)
        " call system('cscope -cRbq -i ' . project_list_file)
        call CodeTagGenerateCscope(cscope_tags, project_list_file)
    endif

endfunction

" Function to generate ctags and cscope databases
function! CodeTagUpdateTags()
    let user_input=0
    let root = CodeTagGetProjectRoot()
    if root == ''
        echo "Error: Could not determine project root"
        return
    endif

    " Create tags directory if it doesn't exist
    " let tags_dir = root . '/tags'
    let tags_dir = root . '/' . g:codetag_folder_name

    if !isdirectory(tags_dir)
        call system('mkdir -p ' . tags_dir)
    endif

    " Generate project list
    let project_list_file = tags_dir . '/'.g:codetag_proj_list_name
    " echom "Generate project srouce code list ".project_list_file
    if ! filereadable(project_list_file)
        echom "Generate project srouce code list ".project_list_file
        call CodeTagGenerateSourceList(root, project_list_file)
    endif

    " Generate ctags
    let ctags_file = tags_dir . '/'.g:codetag_ctag_name
    " echom "Generate ctags ". ctags_file
    call CodeTagGenerateCtags(ctags_file, project_list_file)

    " Generate cscope
    let cscope_tags = tags_dir . '/'.g:codetag_cscope_name
    " echom "Generate cscope ".cscope_tags
    call CodeTagGenerateCscope(cscope_tags, project_list_file)

    echo "Tag update finished."
endfunction

" Function to load ctags and cscope
function! CodeTagLoadTags()
    let root = CodeTagGetProjectRoot()
    if root == ''
        echo "Error: Could not determine project root"
        return
    endif

    " let tags_dir = root . '/tags'
    let tags_dir = root . '/' . g:codetag_folder_name
    echom "Load tag from ".tags_dir
    if isdirectory(tags_dir)
        execute 'set tags^='.tags_dir.'/'.g:codetag_ctag_name
        execute 'helptags '.tags_dir

        if has('cscope')
            " Setup cscope
            " set csprg=cscope
            " set cscope='/usr/bin/cscope'
            execute 'cscope add '.tags_dir.'/'.g:codetag_cscope_name
        endif
    endif
endfunction

" Main function to setup ctags and cscope
function! CodeTagSetup()
    silent call CodeTagUpdateTags()
    silent call CodeTagLoadTags()
    echo "Tag setup finished."
endfunction
