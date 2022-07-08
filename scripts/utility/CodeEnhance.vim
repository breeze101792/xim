" CodeEnhance Settings
" ===========================================
" Shell Function
" ===========================================
" -------------------------------------------
"  Shell Function
" -------------------------------------------
command! -nargs=? SHIf :call <SID>SHIf(<q-args>)
function! s:SHIf(variable)
    let l:indent = repeat(' ', indent('.'))
    let l:tmpl=a:variable
    if l:tmpl == ""
        let l:tmpl="var_tmp"
    endif
    let l:text = [
                \ "if [ \"${<TMPL>}\" = \"value\" ]",
                \ "then",
                \ "    echo \"<TMPL>: ${<TMPL>}\"",
                \ "fi",
                \ ""
                \ ]
    call map(l:text, {k, v -> l:indent . substitute(v, '\C<TMPL>', l:tmpl, 'g')})
    call append('.', l:text)
endfunction

" -------------------------------------------
"  Shell Parentheses
" -------------------------------------------
command! -range SHParentness <line1>,<line2>call s:SHParentness()
function! s:SHParentness() range
    echo 'First Line:'.a:firstline.', Last Line:'.a:lastline

    " :g/\$[0-9A-Za-z_@*]\+/ s//\${&}/g
    " s/\${\$/\${/g
    silent! execute a:firstline.','.a:lastline.'g/\$[0-9A-Za-z_@*]\+/ s//\${&}/g'
    silent! execute a:firstline.','.a:lastline.'s/\${\$/\${/g'
endfunction

" command! -nargs=? SHParentheses :call <SID>SHParentheses(<q-args>)
" function! s:SHParentheses(variable)
"     let l:indent = repeat(' ', indent('.'))
"     let l:tmpl=a:variable
"     let l:ctmp=expand('<cword>')
"     if l:tmpl == "" && l:ctmp != ""
"         let l:tmpl=l:ctmp
"     elseif l:tmpl == ""
"         let l:tmpl="var_tmp"
"     endif
"     let l:text = [
"                 \ "\"${<TMPL>}\""
"                 \ ]
"     call map(l:text, {k, v -> l:indent . substitute(v, '\C<TMPL>', l:tmpl, 'g')})
"     call append('.', l:text)
" endfunction
" ===========================================
" C/C++ Function
" ===========================================
" -------------------------------------------
"  C Function
" -------------------------------------------
command! -nargs=? CFun :call <SID>CFun(<q-args>)
function! s:CFun(fun_name)
    let l:indent = repeat(' ', indent('.'))
    let l:tmpl=a:fun_name
    if l:tmpl == ""
        let l:tmpl="function_name"
    endif
    let l:text = [
                \ "u32retCode = <TMPL>;",
                \ "if (u32retCode != TRUE)",
                \ "{",
                \ "    printf(\"Fail to call <TMPL>. Return Code:%u\\n\", __func__, __LINE__, u32retCode);",
                \ "    return u32retCode;",
                \ "}",
                \ ""
                \ ]
    call map(l:text, {k, v -> l:indent . substitute(v, '\C<TMPL>', l:tmpl, 'g')})
    call append('.', l:text)
endfunction
" -------------------------------------------
"  C Printf
" -------------------------------------------
command! -nargs=? CPrintf :call <SID>CPrintf(<q-args>)
command! CPrintf :call <SID>CPrintf("")
function! s:CPrintf(content)
    let l:indent = repeat(' ', indent('.'))
    let l:tmpl=a:content
    if l:tmpl == ""
        let l:tmpl="message"
    endif
    let l:text = [
                \ "printf(\"[Debug %s,%d] <TMPL> \\n\", __func__, __LINE__);",
                \ ""
                \ ]
    call map(l:text, {k, v -> l:indent . substitute(v, '\C<TMPL>', l:tmpl, 'g')})
    call append('.', l:text)
endfunction
" -------------------------------------------
"  C Macro if
" -------------------------------------------
command! -nargs=? CMIf :call <SID>CMIf(<q-args>)
command! CMIf :call <SID>CMIf("")
function! s:CMIf(content)
    let l:indent = repeat(' ', indent('.'))
    let l:tmpl=a:content
    if l:tmpl == ""
        let l:tmpl="MACRO_DEF"
    endif
    let l:text = [
                \ "#if defined(<TMPL>) && (<TMPL> == value)",
                \ "#else // <TMPL>  Else",
                \ "#endif // <TMPL> End",
                \ ""
                \ ]
    call map(l:text, {k, v -> l:indent . substitute(v, '\C<TMPL>', l:tmpl, 'g')})
    call append('.', l:text)
endfunction
" ===========================================
" Python Function
" ===========================================
" -------------------------------------------
"  Python Prop
" -------------------------------------------
command! -nargs=? PyProp :call <SID>PyProp(<q-args>)
command! PyProp :call <SID>PyProp("python_prop")
function! s:PyProp(property)
    let l:indent = repeat(' ', indent('.'))
    let l:tmpl=a:property
    if l:tmpl == ""
        let l:tmpl="py_prop"
    endif
    let l:text = [
        \ '@property',
        \ 'def <TMPL>(self):',
        \ '    return self._<TMPL>',
        \ '@<TMPL>.setter',
        \ '    def <TMPL>(self,val):',
        \ '        self._<TMPL> = val'
    \ ]
    call map(l:text, {k, v -> l:indent . substitute(v, '\C<TMPL>', l:tmpl, 'g')})
    call append('.', l:text)
endfunction
