" File: afterglow_lab.vim
" Author: Danilo Augusto
" Date: 2017-02-27
" Vim color file - Afterglow (monokai version)
"
" Hex color conversion functions borrowed from the theme 'Desert256'

set background=dark
if version > 580
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif

let g:colors_name = "afterglow_lab"
" set None as background
let g:afterglow_inherit_background=1

" Default GUI Colours
let s:foreground = "d6d6d6"
let s:background = "1a1a1a"
let s:selection = "5a647e"
let s:line = "393939"
let s:comment = "797979"
let s:red = "ac4142"
let s:orange = "e87d3e"
let s:yellow = "e5b567"
let s:green = "b4c973"
let s:blue = "6c99bb"
let s:wine = "b05279"
let s:purple = "9e86c8"
let s:window = "4d5057"

" Auxiliar colors
let s:black = "000000"

if has("gui_running") || &t_Co == 88 || &t_Co == 256
    " Returns an approximate grey index for the given grey level
    fun <SID>grey_number(x)
        if &t_Co == 88
            if a:x < 23
                return 0
            elseif a:x < 69
                return 1
            elseif a:x < 103
                return 2
            elseif a:x < 127
                return 3
            elseif a:x < 150
                return 4
            elseif a:x < 173
                return 5
            elseif a:x < 196
                return 6
            elseif a:x < 219
                return 7
            elseif a:x < 243
                return 8
            else
                return 9
            endif
        else
            if a:x < 14
                return 0
            else
                let l:n = (a:x - 8) / 10
                let l:m = (a:x - 8) % 10
                if l:m < 5
                    return l:n
                else
                    return l:n + 1
                endif
            endif
        endif
    endfun

    " Returns the actual grey level represented by the grey index
    fun <SID>grey_level(n)
        if &t_Co == 88
            if a:n == 0
                return 0
            elseif a:n == 1
                return 46
            elseif a:n == 2
                return 92
            elseif a:n == 3
                return 115
            elseif a:n == 4
                return 139
            elseif a:n == 5
                return 162
            elseif a:n == 6
                return 185
            elseif a:n == 7
                return 208
            elseif a:n == 8
                return 231
            else
                return 255
            endif
        else
            if a:n == 0
                return 0
            else
                return 8 + (a:n * 10)
            endif
        endif
    endfun

    " Returns the palette index for the given grey index
    fun <SID>grey_colour(n)
        if &t_Co == 88
            if a:n == 0
                return 16
            elseif a:n == 9
                return 79
            else
                return 79 + a:n
            endif
        else
            if a:n == 0
                return 16
            elseif a:n == 25
                return 231
            else
                return 231 + a:n
            endif
        endif
    endfun

    " Returns an approximate colour index for the given colour level
    fun <SID>rgb_number(x)
        if &t_Co == 88
            if a:x < 69
                return 0
            elseif a:x < 172
                return 1
            elseif a:x < 230
                return 2
            else
                return 3
            endif
        else
            if a:x < 75
                return 0
            else
                let l:n = (a:x - 55) / 40
                let l:m = (a:x - 55) % 40
                if l:m < 20
                    return l:n
                else
                    return l:n + 1
                endif
            endif
        endif
    endfun

    " Returns the actual colour level for the given colour index
    fun <SID>rgb_level(n)
        if &t_Co == 88
            if a:n == 0
                return 0
            elseif a:n == 1
                return 139
            elseif a:n == 2
                return 205
            else
                return 255
            endif
        else
            if a:n == 0
                return 0
            else
                return 55 + (a:n * 40)
            endif
        endif
    endfun

    " Returns the palette index for the given R/G/B colour indices
    fun <SID>rgb_colour(x, y, z)
        if &t_Co == 88
            return 16 + (a:x * 16) + (a:y * 4) + a:z
        else
            return 16 + (a:x * 36) + (a:y * 6) + a:z
        endif
    endfun

    " Returns the palette index to approximate the given R/G/B colour levels
    fun <SID>colour(r, g, b)
        " Get the closest grey
        let l:gx = <SID>grey_number(a:r)
        let l:gy = <SID>grey_number(a:g)
        let l:gz = <SID>grey_number(a:b)

        " Get the closest colour
        let l:x = <SID>rgb_number(a:r)
        let l:y = <SID>rgb_number(a:g)
        let l:z = <SID>rgb_number(a:b)

        if l:gx == l:gy && l:gy == l:gz
            " There are two possibilities
            let l:dgr = <SID>grey_level(l:gx) - a:r
            let l:dgg = <SID>grey_level(l:gy) - a:g
            let l:dgb = <SID>grey_level(l:gz) - a:b
            let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb)
            let l:dr = <SID>rgb_level(l:gx) - a:r
            let l:dg = <SID>rgb_level(l:gy) - a:g
            let l:db = <SID>rgb_level(l:gz) - a:b
            let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
            if l:dgrey < l:drgb
                " Use the grey
                return <SID>grey_colour(l:gx)
            else
                " Use the colour
                return <SID>rgb_colour(l:x, l:y, l:z)
            endif
        else
            " Only one possibility
            return <SID>rgb_colour(l:x, l:y, l:z)
        endif
    endfun

    " Returns the palette index to approximate the 'rrggbb' hex string
    fun <SID>rgb(rgb)
        let l:r = ("0x" . strpart(a:rgb, 0, 2)) + 0
        let l:g = ("0x" . strpart(a:rgb, 2, 2)) + 0
        let l:b = ("0x" . strpart(a:rgb, 4, 2)) + 0

        return <SID>colour(l:r, l:g, l:b)
    endfun

    " Sets the highlighting for the given group
    fun <SID>X(group, fg, bg, attr)
        if a:fg != ""
            if a:fg == "NONE"
                exec "hi " . a:group . " guifg=NONE ctermfg=NONE"
            else
                exec "hi " . a:group . " guifg=#" . a:fg . " ctermfg=" . <SID>rgb(a:fg)
            endif
        endif
        if a:bg != ""
            if a:bg == "NONE"
                exec "hi " . a:group . " guibg=NONE ctermbg=NONE"
            else
                exec "hi " . a:group . " guibg=#" . a:bg . " ctermbg=" . <SID>rgb(a:bg)
            endif
        endif
        if a:attr != ""
            exec "hi " . a:group . " gui=" . a:attr . " cterm=" . a:attr
        endif
    endfun

    " by default: toggled on (backcompatibility with g:afterglow_italic_comments)
    " option g:afterglow_use_italics
    if exists("g:afterglow_use_italics") && !g:afterglow_use_italics
        let italic = ""
    else
        " make the global variable available to command mode
        let g:afterglow_use_italics = 1
        let italic = "italic"
    endif

    " option g:afterglow_italic_comments
    if exists("g:afterglow_italic_comments") && g:afterglow_italic_comments
        call <SID>X("Comment", s:comment, "", italic)
    else
        " make the global variable available to command mode
        let g:afterglow_italic_comments = 0
        call <SID>X("Comment", s:comment, "", "")
    endif

    " Vim Highlighting
    call <SID>X("NonText", s:selection, "", "")
    call <SID>X("SpecialKey", s:selection, "", "")
    call <SID>X("Search", s:background, s:yellow, "")
    call <SID>X("TabLine", s:window, s:foreground, "reverse")
    call <SID>X("TabLineFill", s:window, s:foreground, "reverse")
    call <SID>X("StatusLine", s:window, s:yellow, "reverse")
    call <SID>X("StatusLineNC", s:window, s:foreground, "reverse")
    call <SID>X("VertSplit", s:window, s:window, "NONE")
    call <SID>X("Visual", "", s:selection, "")
    call <SID>X("Directory", s:blue, "", "")
    call <SID>X("ModeMsg", s:green, "", "")
    call <SID>X("MoreMsg", s:green, "", "")
    call <SID>X("Question", s:green, "", "")
    call <SID>X("WarningMsg", s:orange, "", "bold")
    call <SID>X("MatchParen", "", s:selection, "")
    call <SID>X("Folded", s:comment, s:background, "")
    call <SID>X("FoldColumn", "", s:background, "")
    if version >= 700
        call <SID>X("CursorLine", "", s:line, "NONE")
        call <SID>X("CursorLineNR", s:orange, "", "NONE")
        call <SID>X("CursorColumn", "", s:line, "NONE")
        call <SID>X("PMenu", s:foreground, s:selection, "NONE")
        call <SID>X("PMenuSel", s:foreground, s:selection, "reverse")
    end
    if version >= 703
        call <SID>X("ColorColumn", "", s:line, "NONE")
    end

    " Standard Highlighting
    call <SID>X("Title", s:comment, "", "bold")
    call <SID>X("Identifier", s:orange, "", "")
    call <SID>X("Statement", s:wine, "", "")
    call <SID>X("Conditional", s:wine, "", "")
    call <SID>X("Repeat", s:wine, "", "")
    call <SID>X("Structure", s:wine, "", "")
    call <SID>X("Function", s:orange, "", "")
    call <SID>X("Constant", s:purple, "", "")
    call <SID>X("Keyword", s:orange, "", "")
    call <SID>X("String", s:yellow, "", "")
    call <SID>X("Special", s:blue, "", "")
    call <SID>X("PreProc", s:green, "", "")
    call <SID>X("Operator", s:purple, "", "")
    call <SID>X("Type", s:blue, "", "")
    call <SID>X("Define", s:wine, "", "")
    call <SID>X("Include", s:wine, "", "")
    call <SID>X("Tag", s:orange, "", "bold")
    call <SID>X("Underlined", s:orange, "", "underline")

    syntax match commonOperator "\(+\|=\|-\|*\|\^\|\/\||\)"
    hi! link commonOperator Operator

    " Vim Highlighting
    call <SID>X("vimCommand", s:wine, "", "NONE")

    " C Highlighting
    call <SID>X("cType", s:wine, "", "")
    call <SID>X("cStorageClass", s:orange, "", "")
    call <SID>X("cConditional", s:wine, "", "")
    call <SID>X("cRepeat", s:wine, "", "")

    " PHP Highlighting
    augroup ft_php
        autocmd!
        autocmd FileType php call <SID>X("phpVarSelector", s:wine, "", "")
        autocmd FileType php call <SID>X("phpKeyword", s:wine, "", "")
        autocmd FileType php call <SID>X("phpRepeat", s:wine, "", "")
        autocmd FileType php call <SID>X("phpConditional", s:wine, "", "")
        autocmd FileType php call <SID>X("phpStatement", s:wine, "", "")
        autocmd FileType php call <SID>X("phpMemberSelector", s:foreground, "", "")
    augroup END

    " Ruby Highlighting
    augroup ft_ruby
        autocmd!
        autocmd FileType ruby call <SID>X("rubySymbol", s:blue, "", "")
        autocmd FileType ruby call <SID>X("rubyConstant", s:green, "", "")
        autocmd FileType ruby call <SID>X("rubyAccess", s:yellow, "", "")
        autocmd FileType ruby call <SID>X("rubyAttribute", s:blue, "", "")
        autocmd FileType ruby call <SID>X("rubyInclude", s:blue, "", "")
        autocmd FileType ruby call <SID>X("rubyLocalVariableOrMethod", s:orange, "", "")
        autocmd FileType ruby call <SID>X("rubyCurlyBlock", s:orange, "", "")
        autocmd FileType ruby call <SID>X("rubyStringDelimiter", s:yellow, "", "")
        autocmd FileType ruby call <SID>X("rubyInterpolationDelimiter", s:orange, "", "")
        autocmd FileType ruby call <SID>X("rubyConditional", s:wine, "", "")
        autocmd FileType ruby call <SID>X("rubyRepeat", s:wine, "", "")
        autocmd FileType ruby call <SID>X("rubyControl", s:wine, "", "")
        autocmd FileType ruby call <SID>X("rubyException", s:wine, "", "")
    augroup END

    " Crystal Highlighting
    augroup ft_crystal
        autocmd!
        autocmd FileType crystal call <SID>X("crystalSymbol", s:green, "", "")
        autocmd FileType crystal call <SID>X("crystalConstant", s:yellow, "", "")
        autocmd FileType crystal call <SID>X("crystalAccess", s:yellow, "", "")
        autocmd FileType crystal call <SID>X("crystalAttribute", s:blue, "", "")
        autocmd FileType crystal call <SID>X("crystalInclude", s:blue, "", "")
        autocmd FileType crystal call <SID>X("crystalLocalVariableOrMethod", s:orange, "", "")
        autocmd FileType crystal call <SID>X("crystalCurlyBlock", s:orange, "", "")
        autocmd FileType crystal call <SID>X("crystalStringDelimiter", s:green, "", "")
        autocmd FileType crystal call <SID>X("crystalInterpolationDelimiter", s:orange, "", "")
        autocmd FileType crystal call <SID>X("crystalConditional", s:wine, "", "")
        autocmd FileType crystal call <SID>X("crystalRepeat", s:wine, "", "")
        autocmd FileType crystal call <SID>X("crystalControl", s:wine, "", "")
        autocmd FileType crystal call <SID>X("crystalException", s:wine, "", "")
    augroup END

    " Python Highlighting
    augroup ft_python
        autocmd!
        autocmd FileType python call <SID>X("pythonInclude", s:green, "", italic)
        autocmd FileType python call <SID>X("pythonStatement", s:blue, "", "")
        autocmd FileType python call <SID>X("pythonConditional", s:wine, "", "")
        autocmd FileType python call <SID>X("pythonRepeat", s:wine, "", "")
        autocmd FileType python call <SID>X("pythonException", s:orange, "", "")
        autocmd FileType python call <SID>X("pythonFunction", s:green, "", italic)
        autocmd FileType python call <SID>X("pythonPreCondit", s:wine, "", "")
        autocmd FileType python call <SID>X("pythonExClass", s:orange, "", "")
        autocmd FileType python call <SID>X("pythonBuiltin", s:blue, "", "")
        autocmd FileType python call <SID>X("pythonOperator", s:wine, "", "")
        autocmd FileType python call <SID>X("pythonNumber", s:purple, "", "")
        autocmd FileType python call <SID>X("pythonString", s:yellow, "", "")
        autocmd FileType python call <SID>X("pythonRawString", s:yellow, "", "")
        autocmd FileType python call <SID>X("pythonDecorator", s:wine, "", "")
        autocmd FileType python call <SID>X("pythonDoctest", s:yellow, "", "")
        autocmd FileType python call <SID>X("pythonImportFunction", s:orange, "", "")
        autocmd FileType python call <SID>X("pythonImportModule", s:orange, "", "")
        autocmd FileType python call <SID>X("pythonImportObject", s:orange, "", "")
        autocmd FileType python call <SID>X("pythonImportedClassDef", s:orange, "", "")
        autocmd FileType python call <SID>X("pythonImportedFuncDef", s:orange, "", "")
        autocmd FileType python call <SID>X("pythonImportedModule", s:orange, "", "")
        autocmd FileType python call <SID>X("pythonImportedObject", s:orange, "", "")
    augroup END

    " JavaScript Highlighting
    augroup ft_Javascript
        autocmd!
        autocmd FileType javascript call <SID>X("javaScriptEndColons", s:foreground, "", "")
        autocmd FileType javascript call <SID>X("javaScriptOpSymbols", s:foreground, "", "")
        autocmd FileType javascript call <SID>X("javaScriptLogicSymbols", s:foreground, "", "")
        autocmd FileType javascript call <SID>X("javaScriptBraces", s:foreground, "", "")
        autocmd FileType javascript call <SID>X("javaScriptParens", s:foreground, "", "")
        autocmd FileType javascript call <SID>X("javaScriptFunction", s:green, "", "")
        autocmd FileType javascript call <SID>X("javaScriptComment", s:comment, "", "")
        autocmd FileType javascript call <SID>X("javaScriptLineComment", s:comment, "", "")
        autocmd FileType javascript call <SID>X("javaScriptDocComment", s:comment, "", "")
        autocmd FileType javascript call <SID>X("javaScriptCommentTodo", s:red, "", "")
        autocmd FileType javascript call <SID>X("javaScriptString", s:yellow, "", "")
        autocmd FileType javascript call <SID>X("javaScriptRegexpString", s:yellow, "", "")
        autocmd FileType javascript call <SID>X("javaScriptTemplateString", s:yellow, "", "")
        autocmd FileType javascript call <SID>X("javaScriptNumber", s:purple, "", "")
        autocmd FileType javascript call <SID>X("javaScriptFloat", s:purple, "", "")
        autocmd FileType javascript call <SID>X("javaScriptGlobal", s:purple, "", "")
        autocmd FileType javascript call <SID>X("javaScriptCharacter", s:blue, "", "")
        autocmd FileType javascript call <SID>X("javaScriptPrototype", s:blue, "", "")
        autocmd FileType javascript call <SID>X("javaScriptConditional", s:blue, "", "")
        autocmd FileType javascript call <SID>X("javaScriptBranch", s:blue, "", "")
        autocmd FileType javascript call <SID>X("javaScriptIdentifier", s:orange, "", "")
        autocmd FileType javascript call <SID>X("javaScriptRepeat", s:blue, "", "")
        autocmd FileType javascript call <SID>X("javaScriptStatement", s:blue, "", "")
        autocmd FileType javascript call <SID>X("javaScriptMessage", s:blue, "", "")
        autocmd FileType javascript call <SID>X("javaScriptReserved", s:blue, "", "")
        autocmd FileType javascript call <SID>X("javaScriptOperator", s:blue, "", "")
        autocmd FileType javascript call <SID>X("javaScriptNull", s:purple, "", "")
        autocmd FileType javascript call <SID>X("javaScriptBoolean", s:purple, "", "")
        autocmd FileType javascript call <SID>X("javaScriptLabel", s:blue, "", "")
        autocmd FileType javascript call <SID>X("javaScriptSpecial", s:blue, "", "")
        autocmd FileType javascript call <SID>X("javaScriptExceptions", s:red, "", "")
        autocmd FileType javascript call <SID>X("javaScriptDeprecated", s:red, "", "")
        autocmd FileType javascript call <SID>X("javaScriptError", s:red, "", "")
    augroup END

    " HTML Highlighting
    augroup ft_html
        autocmd!
        autocmd FileType html call <SID>X("htmlTag", s:blue, "", "")
        autocmd FileType html call <SID>X("htmlEndTag", s:blue, "", "")
        autocmd FileType html call <SID>X("htmlTagName", s:wine, "", "bold")
        autocmd FileType html call <SID>X("htmlArg", s:green, "", italic)
        autocmd FileType html call <SID>X("htmlScriptTag", s:wine, "", "")
    augroup END

    " Go Highlighting
    augroup ft_go
        autocmd!
        autocmd FileType go call <SID>X("goDirective", s:wine, "", "")
        autocmd FileType go call <SID>X("goDeclaration", s:wine, "", "")
        autocmd FileType go call <SID>X("goStatement", s:wine, "", "")
        autocmd FileType go call <SID>X("goConditional", s:wine, "", "")
        autocmd FileType go call <SID>X("goConstants", s:orange, "", "")
        autocmd FileType go call <SID>X("goTodo", s:red, "", "")
        autocmd FileType go call <SID>X("goDeclType", s:blue, "", "")
        autocmd FileType go call <SID>X("goBuiltins", s:wine, "", "")
        autocmd FileType go call <SID>X("goRepeat", s:wine, "", "")
        autocmd FileType go call <SID>X("goLabel", s:wine, "", "")
    augroup END

    " LaTeX
    augroup ft_go
        autocmd!
        autocmd FileType tex call <SID>X("texStatement",s:blue, "", "")
        autocmd FileType tex call <SID>X("texMath", s:wine, "", "NONE")
        autocmd FileType tex call <SID>X("texMathMacher", s:yellow, "", "NONE")
        autocmd FileType tex call <SID>X("texRefLabel", s:wine, "", "NONE")
        autocmd FileType tex call <SID>X("texRefZone", s:blue, "", "NONE")
        autocmd FileType tex call <SID>X("texComment", s:comment, "", "NONE")
        autocmd FileType tex call <SID>X("texDelimiter", s:purple, "", "NONE")
        autocmd FileType tex call <SID>X("texMathZoneX", s:purple, "", "NONE")
    augroup END

    " " CoffeeScript Highlighting
    " call <SID>X("coffeeRepeat", s:wine, "", "")
    " call <SID>X("coffeeConditional", s:wine, "", "")
    " call <SID>X("coffeeKeyword", s:wine, "", "")
    " call <SID>X("coffeeObject", s:yellow, "", "")

    " " ShowMarks Highlighting
    " call <SID>X("ShowMarksHLl", s:orange, s:background, "NONE")
    " call <SID>X("ShowMarksHLo", s:wine, s:background, "NONE")
    " call <SID>X("ShowMarksHLu", s:yellow, s:background, "NONE")
    " call <SID>X("ShowMarksHLm", s:wine, s:background, "NONE")

    " " Lua Highlighting
    " call <SID>X("luaStatement", s:wine, "", "")
    " call <SID>X("luaRepeat", s:wine, "", "")
    " call <SID>X("luaCondStart", s:wine, "", "")
    " call <SID>X("luaCondElseif", s:wine, "", "")
    " call <SID>X("luaCond", s:wine, "", "")
    " call <SID>X("luaCondEnd", s:wine, "", "")

    " " Cucumber Highlighting
    " call <SID>X("cucumberGiven", s:blue, "", "")
    " call <SID>X("cucumberGivenAnd", s:blue, "", "")


    " " Clojure Highlighting
    " call <SID>X("clojureConstant", s:orange, "", "")
    " call <SID>X("clojureBoolean", s:orange, "", "")
    " call <SID>X("clojureCharacter", s:orange, "", "")
    " call <SID>X("clojureKeyword", s:green, "", "")
    " call <SID>X("clojureNumber", s:orange, "", "")
    " call <SID>X("clojureString", s:green, "", "")
    " call <SID>X("clojureRegexp", s:green, "", "")
    " call <SID>X("clojureParen", s:wine, "", "")
    " call <SID>X("clojureVariable", s:yellow, "", "")
    " call <SID>X("clojureCond", s:blue, "", "")
    " call <SID>X("clojureDefine", s:wine, "", "")
    " call <SID>X("clojureException", s:red, "", "")
    " call <SID>X("clojureFunc", s:blue, "", "")
    " call <SID>X("clojureMacro", s:blue, "", "")
    " call <SID>X("clojureRepeat", s:blue, "", "")
    " call <SID>X("clojureSpecial", s:wine, "", "")
    " call <SID>X("clojureQuote", s:blue, "", "")
    " call <SID>X("clojureUnquote", s:blue, "", "")
    " call <SID>X("clojureMeta", s:blue, "", "")
    " call <SID>X("clojureDeref", s:blue, "", "")
    " call <SID>X("clojureAnonArg", s:blue, "", "")
    " call <SID>X("clojureRepeat", s:blue, "", "")
    " call <SID>X("clojureDispatch", s:blue, "", "")

    " " Scala Highlighting
    " call <SID>X("scalaKeyword", s:wine, "", "")
    " call <SID>X("scalaKeywordModifier", s:wine, "", "")
    " call <SID>X("scalaOperator", s:blue, "", "")
    " call <SID>X("scalaPackage", s:wine, "", "")
    " call <SID>X("scalaFqn", s:foreground, "", "")
    " call <SID>X("scalaFqnSet", s:foreground, "", "")
    " call <SID>X("scalaImport", s:wine, "", "")
    " call <SID>X("scalaBoolean", s:orange, "", "")
    " call <SID>X("scalaDef", s:wine, "", "")
    " call <SID>X("scalaVal", s:wine, "", "")
    " call <SID>X("scalaVar", s:wine, "", "")
    " call <SID>X("scalaClass", s:wine, "", "")
    " call <SID>X("scalaObject", s:wine, "", "")
    " call <SID>X("scalaTrait", s:wine, "", "")
    " call <SID>X("scalaDefName", s:blue, "", "")
    " call <SID>X("scalaValName", s:foreground, "", "")
    " call <SID>X("scalaVarName", s:foreground, "", "")
    " call <SID>X("scalaClassName", s:foreground, "", "")
    " call <SID>X("scalaType", s:yellow, "", "")
    " call <SID>X("scalaTypeSpecializer", s:yellow, "", "")
    " call <SID>X("scalaAnnotation", s:orange, "", "")
    " call <SID>X("scalaNumber", s:orange, "", "")
    " call <SID>X("scalaDefSpecializer", s:yellow, "", "")
    " call <SID>X("scalaClassSpecializer", s:yellow, "", "")
    " call <SID>X("scalaBackTick", s:green, "", "")
    " call <SID>X("scalaRoot", s:foreground, "", "")
    " call <SID>X("scalaMethodCall", s:blue, "", "")
    " call <SID>X("scalaCaseType", s:yellow, "", "")
    " call <SID>X("scalaLineComment", s:comment, "", "")
    " call <SID>X("scalaComment", s:comment, "", "")
    " call <SID>X("scalaDocComment", s:comment, "", "")
    " call <SID>X("scalaDocTags", s:comment, "", "")
    " call <SID>X("scalaEmptyString", s:green, "", "")
    " call <SID>X("scalaMultiLineString", s:green, "", "")
    " call <SID>X("scalaUnicode", s:orange, "", "")
    " call <SID>X("scalaString", s:green, "", "")
    " call <SID>X("scalaStringEscape", s:green, "", "")
    " call <SID>X("scalaSymbol", s:orange, "", "")
    " call <SID>X("scalaChar", s:orange, "", "")
    " call <SID>X("scalaXml", s:green, "", "")
    " call <SID>X("scalaConstructorSpecializer", s:yellow, "", "")
    " call <SID>X("scalaBackTick", s:blue, "", "")

    " Diff Highlighting
    call <SID>X("diffAdd", "", "4c4e39", "")
    call <SID>X("diffDelete", s:background, s:red, "")
    call <SID>X("diffChange", "", "2B5B77", "")
    call <SID>X("diffText", s:line, s:blue, "")


    " Option g:afterglow_no_terminal_background
    if !exists("g:afterglow_inherit_background")
        let g:afterglow_inherit_background = 0
    endif

    " Background behavior inference here
    if g:afterglow_inherit_background && has("gui_running")
        echohl WarningMsg | echom "Inherit background is ignored in GUI." | echohl NONE
        let g:afterglow_inherit_background = 0
    endif

    if g:afterglow_inherit_background
        let s:chosen_background = "NONE"
    elseif g:afterglow_blackout
        let s:chosen_background = s:black
    else
        let s:chosen_background = s:background
    endif

    "" Plugins
    " Git
    call <SID>X("gitFile", s:orange, "", "")
    call <SID>X("gitcommitSummary", "", "", "bold")

    " " GitGutter
    " call <SID>X("GitGutterAdd", s:green, s:chosen_background, "bold")
    " call <SID>X("GitGutterChange", s:yellow, s:chosen_background, "bold")
    " call <SID>X("GitGutterDelete", s:red, s:chosen_background, "bold")
    call <SID>X("GitGutterChangeDelete", s:blue, s:chosen_background, "bold")

    " Vim-Bookmark
    call <SID>X("BookmarkLine", s:foreground, s:selection, "bold")

    " " ALE (plugin)
    " call <SID>X("ALEWarningSign", s:orange, s:chosen_background, "bold")
    " call <SID>X("ALEErrorSign", s:red, s:chosen_background, "bold")

    " Option g:afterglow_blackout
    if !exists( "g:afterglow_blackout")
        let g:afterglow_blackout = 0
    endif

    "" Others
    " Settings dependent on g:afterglow_blackout
    call <SID>X("Normal", s:foreground, s:chosen_background, "")
    call <SID>X("LineNr", s:comment, s:chosen_background, "")
    if version >= 700
        call <SID>X("SignColumn", "", s:chosen_background, "NONE")
    end
    call <SID>X("Todo", s:red, s:chosen_background, "bold")

    " Diffs
    " Plugin GitGutter uses highlight link to some of the groups below
    call <SID>X("DiffAdded", s:green, s:chosen_background, "")
    call <SID>X("DiffChange", s:yellow, s:chosen_background, "")
    call <SID>X("DiffDelete", s:red, s:chosen_background, "")
    call <SID>X("DiffLine", s:blue, s:chosen_background, italic)
    call <SID>X("DiffSubname", s:foreground, s:chosen_background, "")

    " Aliases
    " For plugins compatibility and some backcompatibility
    " cf. https://github.com/vim/vim-history/blob/c2257f84a000fd08d3ba80d6b1a5d1c0148a39ea/runtime/syntax/diff.vim#L13
    hi! link diffAdded DiffAdded
    hi! link diffChange DiffChange
    hi! link diffDelete DiffDelete
    hi! link diffLine DiffLine
    hi! link diffSubname DiffSubname
    hi! link DiffRemoved DiffDelete
    hi! link diffRemoved DiffDelete
    hi! link GitGutterChangeLineDefault DiffDelete
    hi! link DiffAdd DiffAdded
    hi! link diffAdd DiffAdded

    " Delete Functions
    delf <SID>X
    delf <SID>rgb
    delf <SID>colour
    delf <SID>rgb_colour
    delf <SID>rgb_level
    delf <SID>rgb_number
    delf <SID>grey_colour
    delf <SID>grey_level
    delf <SID>grey_number
endif
