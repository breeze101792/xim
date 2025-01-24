" Plugins Functions
" ===========================================
let g:IDE_MDOULE_STATUSLINE = 'n'
let g:IDE_MDOULE_HIGHLIGHTWORD = 'n'
let g:IDE_MDOULE_BOOKMARK = 'n'

" -------------------------------------------
"  Highlighter Toggle #Plugins
" -------------------------------------------
command! HighlighterList echo HiList()

command! HighlighterClear call HighlighterClear()
function! HighlighterClear()
    exe "HI clear"
endfunction

command! HighlighterToggle call HighlighterToggle()
function! HighlighterToggle()
    let target_pattern=""
    let menual_mark=0

    let l:pattern = expand("<cword>")
    let pattern_prefix='\V\<'
    let pattern_postfix='\>'

    " Block need to within \V\<pattern\>
    silent! exe "HI"
    for each_hi in HiList()
        " \m looks like menual mark.
        let pure_pattern = substitute(each_hi['pattern'], '\\m', '', '')
        let pure_pattern = substitute(pure_pattern, '\\V\\<', '', '')
        let pure_pattern = substitute(pure_pattern, '\\>', '', '')

        " echom 'Pure:'.pure_pattern.', pattern:'.pattern
        if pattern == pure_pattern
            let target_pattern=pure_pattern
            if StartsWith(each_hi['pattern'], "\\m")
                let menual_mark=1
            endif
        endif
    endfor

    " echom 'target:'.target_pattern.', pattern:'.pattern
    if target_pattern != ""
        if menual_mark == 1
            " echo "Menual mark remove"
            exe "HI - ". pattern_prefix.pattern.pattern_postfix
        else
            " echo "System mark remove"
            exe "HI -" 
        endif
    else
        exe "HI + ". pattern_prefix.pattern.pattern_postfix
    endif
    " echom HiList()
endfunc
