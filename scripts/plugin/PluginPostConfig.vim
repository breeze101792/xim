""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Config vim env                            """"
""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""    Themes
""""""""""""""""""""""""""""""""""""""""""""""""""""""

" echom g:IDE_ENV_ROOT_PATH."/tools/save_colorscheme.vim"
" try
"     " use generated color scheme to accerate start up speed
"     if get(g:, 'IDE_CFG_CACHED_COLORSCHEME', "n") == "y"
"         if ! empty(glob(g:IDE_ENV_ROOT_PATH."/colors/". get(g:, 'IDE_ENV_CACHED_COLORSCHEME', "autogen") . ".vim"))
"             colorscheme autogen
"         else
"             execute "colorscheme " . get(g:, 'IDE_CFG_COLORSCHEME_NAME', "default")
"             " source g:IDE_ENV_ROOT_PATH."/tools/save_colorscheme.vim"
"             execute 'source '.g:IDE_ENV_ROOT_PATH."/tools/save_colorscheme.vim"
"         endif
"     elseif get(g:, 'IDE_CFG_COLORSCHEME_NAME', "") != ""
"         execute "colorscheme " . get(g:, 'IDE_CFG_COLORSCHEME_NAME', "")
"     endif
" catch /^Vim\%((\a\+)\)\=:E185/
"     " execute "colorscheme default"
"     echom "Fallback theme to default."
" endtry
if get(g:, 'IDE_CFG_CACHED_COLORSCHEME', "n") == "y"
    if empty(glob(g:IDE_ENV_ROOT_PATH."/colors/". get(g:, 'IDE_ENV_CACHED_COLORSCHEME', "autogen") . ".vim"))
        execute "colorscheme " . get(g:, 'IDE_CFG_COLORSCHEME_NAME', "default")
        " source g:IDE_ENV_ROOT_PATH."/tools/save_colorscheme.vim"
        execute 'source '.g:IDE_ENV_ROOT_PATH."/tools/save_colorscheme.vim"
    endif
elseif get(g:, 'IDE_CFG_CACHED_COLORSCHEME', "n") == "n"
    execute "colorscheme " . get(g:, 'IDE_CFG_COLORSCHEME_NAME', "")
elseif get(g:, 'IDE_CFG_COLORSCHEME_NAME', "") != "idecolor"
    execute "colorscheme " . get(g:, 'IDE_CFG_COLORSCHEME_NAME', "")
endif

" Plugins Functions
" ===========================================
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
