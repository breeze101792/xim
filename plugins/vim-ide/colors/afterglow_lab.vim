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
    fun <SID>X_HI(group, fg, bg, attr)
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
        call <SID>X_HI("Comment", s:comment, "", italic)
    else
        " make the global variable available to command mode
        let g:afterglow_italic_comments = 0
        call <SID>X_HI("Comment", s:comment, "", "")
    endif

    " Vim Highlighting
    call <SID>X_HI("NonText", s:selection, "", "")
    call <SID>X_HI("SpecialKey", s:selection, "", "")
    call <SID>X_HI("Search", s:background, s:yellow, "")
    call <SID>X_HI("TabLine", s:window, s:foreground, "reverse")
    call <SID>X_HI("TabLineFill", s:window, s:foreground, "reverse")
    call <SID>X_HI("StatusLine", s:window, s:yellow, "reverse")
    call <SID>X_HI("StatusLineNC", s:window, s:foreground, "reverse")
    call <SID>X_HI("VertSplit", s:window, s:window, "NONE")
    call <SID>X_HI("Visual", "", s:selection, "")
    call <SID>X_HI("Directory", s:blue, "", "")
    call <SID>X_HI("ModeMsg", s:green, "", "")
    call <SID>X_HI("MoreMsg", s:green, "", "")
    call <SID>X_HI("Question", s:green, "", "")
    call <SID>X_HI("WarningMsg", s:orange, "", "bold")
    call <SID>X_HI("MatchParen", "", s:selection, "")
    call <SID>X_HI("Folded", s:comment, s:background, "")
    call <SID>X_HI("FoldColumn", "", s:background, "")
    if version >= 700
        call <SID>X_HI("CursorLine", "", s:line, "NONE")
        call <SID>X_HI("CursorLineNR", s:orange, "", "NONE")
        call <SID>X_HI("CursorColumn", "", s:line, "NONE")
        call <SID>X_HI("PMenu", s:foreground, s:selection, "NONE")
        call <SID>X_HI("PMenuSel", s:foreground, s:selection, "reverse")
    end
    if version >= 703
        call <SID>X_HI("ColorColumn", "", s:line, "NONE")
    end

    " Standard Highlighting
    call <SID>X_HI("Title", s:comment, "", "bold")
    call <SID>X_HI("Identifier", s:orange, "", "")
    call <SID>X_HI("Statement", s:wine, "", "")
    call <SID>X_HI("Conditional", s:wine, "", "")
    call <SID>X_HI("Repeat", s:wine, "", "")
    call <SID>X_HI("Structure", s:wine, "", "")
    call <SID>X_HI("Function", s:orange, "", "")
    call <SID>X_HI("Constant", s:purple, "", "")
    call <SID>X_HI("Keyword", s:orange, "", "")
    call <SID>X_HI("String", s:yellow, "", "")
    call <SID>X_HI("Special", s:blue, "", "")
    call <SID>X_HI("PreProc", s:green, "", "")
    call <SID>X_HI("Operator", s:purple, "", "")
    call <SID>X_HI("Type", s:blue, "", "")
    call <SID>X_HI("Define", s:wine, "", "")
    call <SID>X_HI("Include", s:wine, "", "")
    call <SID>X_HI("Tag", s:orange, "", "bold")
    call <SID>X_HI("Underlined", s:orange, "", "underline")

    syntax match commonOperator "\(+\|=\|-\|*\|\^\|\/\||\)"
    hi! link commonOperator Operator

    " Vim Highlighting
    call <SID>X_HI("vimCommand", s:wine, "", "NONE")

    " C Highlighting
    call <SID>X_HI("cType", s:wine, "", "")
    call <SID>X_HI("cStorageClass", s:orange, "", "")
    call <SID>X_HI("cConditional", s:wine, "", "")
    call <SID>X_HI("cRepeat", s:wine, "", "")

    " PHP Highlighting
    augroup ft_php
        autocmd!
        autocmd FileType php call <SID>X_HI("phpVarSelector", s:wine, "", "")
        autocmd FileType php call <SID>X_HI("phpKeyword", s:wine, "", "")
        autocmd FileType php call <SID>X_HI("phpRepeat", s:wine, "", "")
        autocmd FileType php call <SID>X_HI("phpConditional", s:wine, "", "")
        autocmd FileType php call <SID>X_HI("phpStatement", s:wine, "", "")
        autocmd FileType php call <SID>X_HI("phpMemberSelector", s:foreground, "", "")
    augroup END

    " Ruby Highlighting
    augroup ft_ruby
        autocmd!
        autocmd FileType ruby call <SID>X_HI("rubySymbol", s:blue, "", "")
        autocmd FileType ruby call <SID>X_HI("rubyConstant", s:green, "", "")
        autocmd FileType ruby call <SID>X_HI("rubyAccess", s:yellow, "", "")
        autocmd FileType ruby call <SID>X_HI("rubyAttribute", s:blue, "", "")
        autocmd FileType ruby call <SID>X_HI("rubyInclude", s:blue, "", "")
        autocmd FileType ruby call <SID>X_HI("rubyLocalVariableOrMethod", s:orange, "", "")
        autocmd FileType ruby call <SID>X_HI("rubyCurlyBlock", s:orange, "", "")
        autocmd FileType ruby call <SID>X_HI("rubyStringDelimiter", s:yellow, "", "")
        autocmd FileType ruby call <SID>X_HI("rubyInterpolationDelimiter", s:orange, "", "")
        autocmd FileType ruby call <SID>X_HI("rubyConditional", s:wine, "", "")
        autocmd FileType ruby call <SID>X_HI("rubyRepeat", s:wine, "", "")
        autocmd FileType ruby call <SID>X_HI("rubyControl", s:wine, "", "")
        autocmd FileType ruby call <SID>X_HI("rubyException", s:wine, "", "")
    augroup END

    " Crystal Highlighting
    augroup ft_crystal
        autocmd!
        autocmd FileType crystal call <SID>X_HI("crystalSymbol", s:green, "", "")
        autocmd FileType crystal call <SID>X_HI("crystalConstant", s:yellow, "", "")
        autocmd FileType crystal call <SID>X_HI("crystalAccess", s:yellow, "", "")
        autocmd FileType crystal call <SID>X_HI("crystalAttribute", s:blue, "", "")
        autocmd FileType crystal call <SID>X_HI("crystalInclude", s:blue, "", "")
        autocmd FileType crystal call <SID>X_HI("crystalLocalVariableOrMethod", s:orange, "", "")
        autocmd FileType crystal call <SID>X_HI("crystalCurlyBlock", s:orange, "", "")
        autocmd FileType crystal call <SID>X_HI("crystalStringDelimiter", s:green, "", "")
        autocmd FileType crystal call <SID>X_HI("crystalInterpolationDelimiter", s:orange, "", "")
        autocmd FileType crystal call <SID>X_HI("crystalConditional", s:wine, "", "")
        autocmd FileType crystal call <SID>X_HI("crystalRepeat", s:wine, "", "")
        autocmd FileType crystal call <SID>X_HI("crystalControl", s:wine, "", "")
        autocmd FileType crystal call <SID>X_HI("crystalException", s:wine, "", "")
    augroup END

    " Python Highlighting
    augroup ft_python
        autocmd!
        autocmd FileType python call <SID>X_HI("pythonInclude", s:green, "", italic)
        autocmd FileType python call <SID>X_HI("pythonStatement", s:blue, "", "")
        autocmd FileType python call <SID>X_HI("pythonConditional", s:wine, "", "")
        autocmd FileType python call <SID>X_HI("pythonRepeat", s:wine, "", "")
        autocmd FileType python call <SID>X_HI("pythonException", s:orange, "", "")
        autocmd FileType python call <SID>X_HI("pythonFunction", s:green, "", italic)
        autocmd FileType python call <SID>X_HI("pythonPreCondit", s:wine, "", "")
        autocmd FileType python call <SID>X_HI("pythonExClass", s:orange, "", "")
        autocmd FileType python call <SID>X_HI("pythonBuiltin", s:blue, "", "")
        autocmd FileType python call <SID>X_HI("pythonOperator", s:wine, "", "")
        autocmd FileType python call <SID>X_HI("pythonNumber", s:purple, "", "")
        autocmd FileType python call <SID>X_HI("pythonString", s:yellow, "", "")
        autocmd FileType python call <SID>X_HI("pythonRawString", s:yellow, "", "")
        autocmd FileType python call <SID>X_HI("pythonDecorator", s:wine, "", "")
        autocmd FileType python call <SID>X_HI("pythonDoctest", s:yellow, "", "")
        autocmd FileType python call <SID>X_HI("pythonImportFunction", s:orange, "", "")
        autocmd FileType python call <SID>X_HI("pythonImportModule", s:orange, "", "")
        autocmd FileType python call <SID>X_HI("pythonImportObject", s:orange, "", "")
        autocmd FileType python call <SID>X_HI("pythonImportedClassDef", s:orange, "", "")
        autocmd FileType python call <SID>X_HI("pythonImportedFuncDef", s:orange, "", "")
        autocmd FileType python call <SID>X_HI("pythonImportedModule", s:orange, "", "")
        autocmd FileType python call <SID>X_HI("pythonImportedObject", s:orange, "", "")
    augroup END

    " JavaScript Highlighting
    augroup ft_Javascript
        autocmd!
        autocmd FileType javascript call <SID>X_HI("javaScriptEndColons", s:foreground, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptOpSymbols", s:foreground, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptLogicSymbols", s:foreground, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptBraces", s:foreground, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptParens", s:foreground, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptFunction", s:green, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptComment", s:comment, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptLineComment", s:comment, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptDocComment", s:comment, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptCommentTodo", s:red, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptString", s:yellow, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptRegexpString", s:yellow, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptTemplateString", s:yellow, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptNumber", s:purple, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptFloat", s:purple, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptGlobal", s:purple, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptCharacter", s:blue, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptPrototype", s:blue, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptConditional", s:blue, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptBranch", s:blue, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptIdentifier", s:orange, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptRepeat", s:blue, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptStatement", s:blue, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptMessage", s:blue, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptReserved", s:blue, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptOperator", s:blue, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptNull", s:purple, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptBoolean", s:purple, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptLabel", s:blue, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptSpecial", s:blue, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptExceptions", s:red, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptDeprecated", s:red, "", "")
        autocmd FileType javascript call <SID>X_HI("javaScriptError", s:red, "", "")
    augroup END

    " HTML Highlighting
    augroup ft_html
        autocmd!
        autocmd FileType html call <SID>X_HI("htmlTag", s:blue, "", "")
        autocmd FileType html call <SID>X_HI("htmlEndTag", s:blue, "", "")
        autocmd FileType html call <SID>X_HI("htmlTagName", s:wine, "", "bold")
        autocmd FileType html call <SID>X_HI("htmlArg", s:green, "", italic)
        autocmd FileType html call <SID>X_HI("htmlScriptTag", s:wine, "", "")
    augroup END

    " Go Highlighting
    augroup ft_go
        autocmd!
        autocmd FileType go call <SID>X_HI("goDirective", s:wine, "", "")
        autocmd FileType go call <SID>X_HI("goDeclaration", s:wine, "", "")
        autocmd FileType go call <SID>X_HI("goStatement", s:wine, "", "")
        autocmd FileType go call <SID>X_HI("goConditional", s:wine, "", "")
        autocmd FileType go call <SID>X_HI("goConstants", s:orange, "", "")
        autocmd FileType go call <SID>X_HI("goTodo", s:red, "", "")
        autocmd FileType go call <SID>X_HI("goDeclType", s:blue, "", "")
        autocmd FileType go call <SID>X_HI("goBuiltins", s:wine, "", "")
        autocmd FileType go call <SID>X_HI("goRepeat", s:wine, "", "")
        autocmd FileType go call <SID>X_HI("goLabel", s:wine, "", "")
    augroup END

    " LaTeX
    augroup ft_go
        autocmd!
        autocmd FileType tex call <SID>X_HI("texStatement",s:blue, "", "")
        autocmd FileType tex call <SID>X_HI("texMath", s:wine, "", "NONE")
        autocmd FileType tex call <SID>X_HI("texMathMacher", s:yellow, "", "NONE")
        autocmd FileType tex call <SID>X_HI("texRefLabel", s:wine, "", "NONE")
        autocmd FileType tex call <SID>X_HI("texRefZone", s:blue, "", "NONE")
        autocmd FileType tex call <SID>X_HI("texComment", s:comment, "", "NONE")
        autocmd FileType tex call <SID>X_HI("texDelimiter", s:purple, "", "NONE")
        autocmd FileType tex call <SID>X_HI("texMathZoneX", s:purple, "", "NONE")
    augroup END

    " " CoffeeScript Highlighting
    " call <SID>X_HI("coffeeRepeat", s:wine, "", "")
    " call <SID>X_HI("coffeeConditional", s:wine, "", "")
    " call <SID>X_HI("coffeeKeyword", s:wine, "", "")
    " call <SID>X_HI("coffeeObject", s:yellow, "", "")

    " " ShowMarks Highlighting
    " call <SID>X_HI("ShowMarksHLl", s:orange, s:background, "NONE")
    " call <SID>X_HI("ShowMarksHLo", s:wine, s:background, "NONE")
    " call <SID>X_HI("ShowMarksHLu", s:yellow, s:background, "NONE")
    " call <SID>X_HI("ShowMarksHLm", s:wine, s:background, "NONE")

    " " Lua Highlighting
    " call <SID>X_HI("luaStatement", s:wine, "", "")
    " call <SID>X_HI("luaRepeat", s:wine, "", "")
    " call <SID>X_HI("luaCondStart", s:wine, "", "")
    " call <SID>X_HI("luaCondElseif", s:wine, "", "")
    " call <SID>X_HI("luaCond", s:wine, "", "")
    " call <SID>X_HI("luaCondEnd", s:wine, "", "")

    " " Cucumber Highlighting
    " call <SID>X_HI("cucumberGiven", s:blue, "", "")
    " call <SID>X_HI("cucumberGivenAnd", s:blue, "", "")


    " " Clojure Highlighting
    " call <SID>X_HI("clojureConstant", s:orange, "", "")
    " call <SID>X_HI("clojureBoolean", s:orange, "", "")
    " call <SID>X_HI("clojureCharacter", s:orange, "", "")
    " call <SID>X_HI("clojureKeyword", s:green, "", "")
    " call <SID>X_HI("clojureNumber", s:orange, "", "")
    " call <SID>X_HI("clojureString", s:green, "", "")
    " call <SID>X_HI("clojureRegexp", s:green, "", "")
    " call <SID>X_HI("clojureParen", s:wine, "", "")
    " call <SID>X_HI("clojureVariable", s:yellow, "", "")
    " call <SID>X_HI("clojureCond", s:blue, "", "")
    " call <SID>X_HI("clojureDefine", s:wine, "", "")
    " call <SID>X_HI("clojureException", s:red, "", "")
    " call <SID>X_HI("clojureFunc", s:blue, "", "")
    " call <SID>X_HI("clojureMacro", s:blue, "", "")
    " call <SID>X_HI("clojureRepeat", s:blue, "", "")
    " call <SID>X_HI("clojureSpecial", s:wine, "", "")
    " call <SID>X_HI("clojureQuote", s:blue, "", "")
    " call <SID>X_HI("clojureUnquote", s:blue, "", "")
    " call <SID>X_HI("clojureMeta", s:blue, "", "")
    " call <SID>X_HI("clojureDeref", s:blue, "", "")
    " call <SID>X_HI("clojureAnonArg", s:blue, "", "")
    " call <SID>X_HI("clojureRepeat", s:blue, "", "")
    " call <SID>X_HI("clojureDispatch", s:blue, "", "")

    " " Scala Highlighting
    " call <SID>X_HI("scalaKeyword", s:wine, "", "")
    " call <SID>X_HI("scalaKeywordModifier", s:wine, "", "")
    " call <SID>X_HI("scalaOperator", s:blue, "", "")
    " call <SID>X_HI("scalaPackage", s:wine, "", "")
    " call <SID>X_HI("scalaFqn", s:foreground, "", "")
    " call <SID>X_HI("scalaFqnSet", s:foreground, "", "")
    " call <SID>X_HI("scalaImport", s:wine, "", "")
    " call <SID>X_HI("scalaBoolean", s:orange, "", "")
    " call <SID>X_HI("scalaDef", s:wine, "", "")
    " call <SID>X_HI("scalaVal", s:wine, "", "")
    " call <SID>X_HI("scalaVar", s:wine, "", "")
    " call <SID>X_HI("scalaClass", s:wine, "", "")
    " call <SID>X_HI("scalaObject", s:wine, "", "")
    " call <SID>X_HI("scalaTrait", s:wine, "", "")
    " call <SID>X_HI("scalaDefName", s:blue, "", "")
    " call <SID>X_HI("scalaValName", s:foreground, "", "")
    " call <SID>X_HI("scalaVarName", s:foreground, "", "")
    " call <SID>X_HI("scalaClassName", s:foreground, "", "")
    " call <SID>X_HI("scalaType", s:yellow, "", "")
    " call <SID>X_HI("scalaTypeSpecializer", s:yellow, "", "")
    " call <SID>X_HI("scalaAnnotation", s:orange, "", "")
    " call <SID>X_HI("scalaNumber", s:orange, "", "")
    " call <SID>X_HI("scalaDefSpecializer", s:yellow, "", "")
    " call <SID>X_HI("scalaClassSpecializer", s:yellow, "", "")
    " call <SID>X_HI("scalaBackTick", s:green, "", "")
    " call <SID>X_HI("scalaRoot", s:foreground, "", "")
    " call <SID>X_HI("scalaMethodCall", s:blue, "", "")
    " call <SID>X_HI("scalaCaseType", s:yellow, "", "")
    " call <SID>X_HI("scalaLineComment", s:comment, "", "")
    " call <SID>X_HI("scalaComment", s:comment, "", "")
    " call <SID>X_HI("scalaDocComment", s:comment, "", "")
    " call <SID>X_HI("scalaDocTags", s:comment, "", "")
    " call <SID>X_HI("scalaEmptyString", s:green, "", "")
    " call <SID>X_HI("scalaMultiLineString", s:green, "", "")
    " call <SID>X_HI("scalaUnicode", s:orange, "", "")
    " call <SID>X_HI("scalaString", s:green, "", "")
    " call <SID>X_HI("scalaStringEscape", s:green, "", "")
    " call <SID>X_HI("scalaSymbol", s:orange, "", "")
    " call <SID>X_HI("scalaChar", s:orange, "", "")
    " call <SID>X_HI("scalaXml", s:green, "", "")
    " call <SID>X_HI("scalaConstructorSpecializer", s:yellow, "", "")
    " call <SID>X_HI("scalaBackTick", s:blue, "", "")

    " Diff Highlighting
    call <SID>X_HI("diffAdd", "", "4c4e39", "")
    call <SID>X_HI("diffDelete", s:background, s:red, "")
    call <SID>X_HI("diffChange", "", "2B5B77", "")
    call <SID>X_HI("diffText", s:line, s:blue, "")


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
    call <SID>X_HI("gitFile", s:orange, "", "")
    call <SID>X_HI("gitcommitSummary", "", "", "bold")

    " " GitGutter
    " call <SID>X_HI("GitGutterAdd", s:green, s:chosen_background, "bold")
    " call <SID>X_HI("GitGutterChange", s:yellow, s:chosen_background, "bold")
    " call <SID>X_HI("GitGutterDelete", s:red, s:chosen_background, "bold")
    call <SID>X_HI("GitGutterChangeDelete", s:blue, s:chosen_background, "bold")

    " Vim-Bookmark
    call <SID>X_HI("BookmarkLine", s:foreground, s:selection, "bold")

    " " ALE (plugin)
    " call <SID>X_HI("ALEWarningSign", s:orange, s:chosen_background, "bold")
    " call <SID>X_HI("ALEErrorSign", s:red, s:chosen_background, "bold")

    " Option g:afterglow_blackout
    if !exists( "g:afterglow_blackout")
        let g:afterglow_blackout = 0
    endif

    "" Others
    " Settings dependent on g:afterglow_blackout
    call <SID>X_HI("Normal", s:foreground, s:chosen_background, "")
    call <SID>X_HI("LineNr", s:comment, s:chosen_background, "")
    if version >= 700
        call <SID>X_HI("SignColumn", "", s:chosen_background, "NONE")
    end
    call <SID>X_HI("Todo", s:red, s:chosen_background, "bold")

    " Diffs
    " Plugin GitGutter uses highlight link to some of the groups below
    call <SID>X_HI("DiffAdded", s:green, s:chosen_background, "")
    call <SID>X_HI("DiffChange", s:yellow, s:chosen_background, "")
    call <SID>X_HI("DiffDelete", s:red, s:chosen_background, "")
    call <SID>X_HI("DiffLine", s:blue, s:chosen_background, italic)
    call <SID>X_HI("DiffSubname", s:foreground, s:chosen_background, "")

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

    " Don't do this, beczuse we use au for fasten open speed
    " Delete Functions
    " delf <SID>X_HI
    " delf <SID>rgb
    " delf <SID>colour
    " delf <SID>rgb_colour
    " delf <SID>rgb_level
    " delf <SID>rgb_number
    " delf <SID>grey_colour
    " delf <SID>grey_level
    " delf <SID>grey_number
endif
