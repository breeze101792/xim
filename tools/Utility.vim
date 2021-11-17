" -------------------------------------------
"  VimColorTest & GvimColorTest
" -------------------------------------------
" Color test: Save this file, then enter ':so %'
" Then enter one of following commands:
"   :VimColorTest    "(for console/terminal Vim)
"   :GvimColorTest   "(for GUI gvim)
function! VimColorTest(outfile, fgend, bgend)
    let result = []
    for fg in range(a:fgend)
        for bg in range(a:bgend)
            let kw = printf('%-7s', printf('c_%d_%d', fg, bg))
            let h = printf('hi %s ctermfg=%d ctermbg=%d', kw, fg, bg)
            let s = printf('syn keyword %s %s', kw, kw)
            call add(result, printf('%-32s | %s', h, s))
        endfor
    endfor
    call writefile(result, a:outfile)
    execute 'edit '.a:outfile
    source %
endfunction
" Increase numbers in next line to see more colors.
command! VimColorTest call VimColorTest('vim-color-test.tmp', 15, 255)

function! GvimColorTest(outfile)
    let result = []
    for red in range(0, 255, 16)
        for green in range(0, 255, 16)
            for blue in range(0, 255, 16)
                let kw = printf('%-13s', printf('c_%d_%d_%d', red, green, blue))
                let fg = printf('#%02x%02x%02x', red, green, blue)
                let bg = '#fafafa'
                let h = printf('hi %s guifg=%s guibg=%s', kw, fg, bg)
                let s = printf('syn keyword %s %s', kw, kw)
                call add(result, printf('%s | %s', h, s))
            endfor
        endfor
    endfor
    call writefile(result, a:outfile)
    execute 'edit '.a:outfile
    source %
endfunction
command! GvimColorTest call GvimColorTest('gvim-color-test.tmp')

" -------------------------------------------
"  GetFiletypes
" -------------------------------------------
function! GetFiletypes(outfile)
    " Get a list of all the runtime directories by taking the value of that
    " option and splitting it using a comma as the separator.
    let rtps = split(&runtimepath, ",")
    " This will be the list of filetypes that the function returns
    let filetypes = []

    " Loop through each individual item in the list of runtime paths
    for rtp in rtps
        let syntax_dir = rtp . "/syntax"
        " Check to see if there is a syntax directory in this runtimepath.
        if (isdirectory(syntax_dir))
            " Loop through each vimscript file in the syntax directory
            for syntax_file in split(glob(syntax_dir . "/*.vim"), "\n")
                " Add this file to the filetypes list with its everything
                " except its name removed.
                call add(filetypes, fnamemodify(syntax_file, ":t:r"))
            endfor
        endif
    endfor

    call writefile(uniq(sort(filetypes)), a:outfile)
    execute 'edit '.a:outfile

    " This removes any duplicates and returns the resulting list.
    " NOTE: This might not be the best way to do this, suggestions are welcome.
    " return uniq(sort(filetypes))
endfunction
command! GetFiletypes call GetFiletypes('vim-filetype.tmp')
