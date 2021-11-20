" CodeEnhance Settings
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
        \ '    return self.<TMPL>',
        \ '@property.setter',
        \ '    def <TMPL>(self,val):',
        \ '        self._<TMPL> = val'
    \ ]
    call map(l:text, {k, v -> l:indent . substitute(v, '\C<TMPL>', l:tmpl, 'g')})
    call append('.', l:text)
endfunction
