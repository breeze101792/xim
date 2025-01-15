" -------------------------------------------
"  Mouse_on_off for cursor chage
" -------------------------------------------
command! MouseToggle call MouseToggle()

function! MouseToggle()
    if &mouse == 'c'
        set mouse=a
    else
        set mouse=c
    endif
    return
endfunc

command! LineNumToggle call LineNumToggle()

function! LineNumToggle()
    if &relativenumber
        set norelativenumber
    else
        set relativenumber
    endif
    return
endfunc

" -------------------------------------------
"  SimpleCommenCode
" -------------------------------------------
command! -range -nargs=? SimpleCommentCode <line1>,<line2>call SimpleCommentCode(<q-args>)
function! SimpleCommentCode(pattern) range
    let b:comment_padding = ' '
    let b:comment_leader = '#'
    if a:pattern != ''
        let b:comment_leader = '#'
    elseif &filetype ==# 'c' || &filetype ==# 'cpp'
        let b:comment_leader = '\/\/'
    elseif &filetype ==# 'sh' || &filetype ==# 'conf' || &filetype ==# 'bash'
        let b:comment_leader = '#'
    elseif &filetype ==# 'python' || &filetype ==# 'ruby'
        let b:comment_leader = '#'
    elseif &filetype ==# 'vim'
        let b:comment_leader = '"'
    endif
    let flag_comment=0
    let match_ret=0

    let b:comment_pattern = b:comment_leader.b:comment_padding
    try
        let match_ret=execute(a:firstline.','.a:lastline.'s/^\s*'.b:comment_leader.'/ /n')

        let token=split(match_ret[1:], ' ')
        if len(token) < 4
            let flag_comment=1
        else
            let pattern_matches=token[0]
            let line_matches=token[3]
            let test=char2nr(pattern_matches[0])

            if a:lastline - a:firstline + 1== pattern_matches
                let flag_comment=0
            else
                let flag_comment=1
            endif
        endif
    catch
        let flag_comment=1
    endtry

    echom "Comment Code: '".b:comment_leader."', comment: ".flag_comment.", cnt:".match_ret
    " Toggle
    if flag_comment == 1
        " Do comment
        call execute(a:firstline.','.a:lastline.'s/^/'.b:comment_pattern.'/g')
    else
        " Do uncomment
        call execute(a:firstline.','.a:lastline.'g/^\s*'.b:comment_leader.'/s/'.b:comment_leader.'[ ]\?//')
    endif

endfunction

" -------------------------------------------
"  Tab op
" -------------------------------------------
function! TabCloseOthers(bang)
    let cur=tabpagenr()
    while cur < tabpagenr('$')
        exe 'tabclose' . a:bang . ' ' . (cur + 1)
    endwhile
    while tabpagenr() > 1
        exe 'tabclose' . a:bang . ' 1'
    endwhile
endfunction

function! TabCloseRight(bang)
    let cur=tabpagenr()
    while cur < tabpagenr('$')
        exe 'tabclose' . a:bang . ' ' . (cur + 1)
    endwhile
endfunction

function! TabCloseLeft(bang)
    while tabpagenr() > 1
        exe 'tabclose' . a:bang . ' 1'
    endwhile
endfunction

command! -bang Tabcloseothers call TabCloseOthers('<bang>')
command! -bang Tabcloseright call TabCloseRight('<bang>')
command! -bang Tabcloseleft call TabCloseLeft('<bang>')

