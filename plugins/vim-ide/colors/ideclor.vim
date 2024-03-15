" File: idecolor.vim
" Author: Danilo Augusto
" Date: 2017-02-27
" Vim color file - idecolor (monokai version)
"
" Hex color conversion functions borrowed from the theme 'Desert256'

" if has("gui_running") || &t_Co == 88 || &t_Co == 256
"     return
" endif

""""    Preset
""""""""""""""""""""""""""""""""""""""""""""""""""""""
set background=dark
if version > 580
    hi clear
    " already done by hi clear
    " if exists("syntax_on")
    "     syntax reset
    " endif
endif

let g:colors_name = "idecolor"
" set None as background
let g:flag_inherit_background=1

" Option g:flag_no_terminal_background
if !exists("g:flag_inherit_background")
    let g:flag_inherit_background = 0
endif

" Background behavior inference here
if g:flag_inherit_background && has("gui_running")
    echohl WarningMsg | echom "Inherit background is ignored in GUI." | echohl NONE
    let g:flag_inherit_background = 0
endif

""""    Default GUI Colours
""""""""""""""""""""""""""""""""""""""""""""""""""""""

"" Color Table
let s:red = "ac4142"
let s:orange = "e87d3e"
let s:yellow = "e5b567"
let s:green = "b4c973"
let s:blue = "6c99bb"
let s:wine = "b05279"
let s:purple = "9e86c8"
let s:black = "000000"
""""""""""""""""""""""""""""""""""""""""""
" Different Background
let s:background = "1a1a1a"
if g:flag_inherit_background
    let s:chosen_background = "NONE"
elseif g:flag_blackout
    let s:chosen_background = s:black
else
    let s:chosen_background = s:background
endif

let s:foreground = "d6d6d6"
let s:line = "393939"
let s:comment = "797979"
let s:fg_selection = "5a647e"
let s:bg_selection = "555500"
""""""""""""""""""""""""""""""""""""""""""

"" Window Defines
let s:fg_status = "4d5057"
let s:bg_status = s:foreground

let s:fg_menu = s:foreground
let s:bg_menu = "797979"
let s:fg_menu_sel = s:foreground
let s:bg_menu_sel = s:fg_selection

let s:fg_highlight = s:background
let s:bg_highlight = s:yellow

"" content
let s:non_text = s:fg_selection
let s:text_highlight = s:orange

"" content
let s:error = s:red
let s:warning = s:orange
let s:message = s:green
let s:todo = s:red

"" content
let s:code_identifier = s:orange
let s:code_function = s:orange
let s:code_class = s:orange
let s:code_constant = s:purple
let s:code_operator = s:purple
let s:code_include = s:wine
let s:code_tag = s:orange
let s:code_type = s:blue
let s:code_string = s:yellow
let s:code_preproc = s:green
let s:code_statment = s:wine


"" Plugins
" let s:diff_del = s:blue
" let s:diff_add = "4c4e39"
" let s:diff_change = "2B5B77"
" let s:diff_content = s:blue"
let s:diff_del = s:red
let s:diff_add = s:green
let s:diff_change = s:wine
let s:diff_content = s:blue

""""    Function Preset
""""""""""""""""""""""""""""""""""""""""""""""""""""""

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

" by default: toggled on (backcompatibility with g:flag_italic_comments)
" option g:flag_use_italics
if exists("g:flag_use_italics") && !g:flag_use_italics
    let italic = ""
else
    " make the global variable available to command mode
    let g:flag_use_italics = 1
    let italic = "italic"
endif

" option g:flag_italic_comments
if exists("g:flag_italic_comments") && g:flag_italic_comments
    call <SID>X_HI("Comment", s:comment, "", italic)
else
    " make the global variable available to command mode
    let g:flag_italic_comments = 0
    call <SID>X_HI("Comment", s:comment, "", "")
endif


""""    Collor setting
""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Vim Highlighting
call <SID>X_HI("NonText", s:non_text, "", "")
call <SID>X_HI("SpecialKey", s:non_text, "", "")

" Highlight
call <SID>X_HI("Search", s:fg_highlight, s:bg_highlight, "")
call <SID>X_HI("MatchParen", "", s:fg_selection, "")

" Status Lines
call <SID>X_HI("TabLine", s:fg_status, s:bg_status, "reverse")
call <SID>X_HI("TabLineFill", s:fg_status, s:bg_status, "reverse")
call <SID>X_HI("StatusLineNC", s:fg_status, s:bg_status, "reverse")

call <SID>X_HI("VertSplit", s:fg_status, s:fg_status, "NONE")
call <SID>X_HI("Visual", "", s:fg_selection, "")
call <SID>X_HI("ModeMsg", s:message, "", "")
call <SID>X_HI("MoreMsg", s:message, "", "")
call <SID>X_HI("Question", s:message, "", "")

call <SID>X_HI("WarningMsg", s:warning, "", "bold")
call <SID>X_HI("Folded", s:comment, s:background, "")
call <SID>X_HI("FoldColumn", "", s:background, "")
" Others
call <SID>X_HI("StatusLine", s:fg_status, s:yellow, "reverse")
call <SID>X_HI("Directory", s:blue, "", "")

" Lines
if version >= 700
    call <SID>X_HI("CursorLine", "", s:line, "NONE")
    call <SID>X_HI("CursorLineNR", s:text_highlight, "", "NONE")
    call <SID>X_HI("CursorColumn", "", s:line, "NONE")
    call <SID>X_HI("PMenu", s:fg_menu, s:bg_menu, "NONE")
    call <SID>X_HI("PMenuSel", s:fg_menu_sel, s:bg_menu_sel, "reverse")
end
if version >= 703
    call <SID>X_HI("ColorColumn", "", s:line, "NONE")
end

" Standard Highlighting
call <SID>X_HI("Title", s:comment, "", "bold")
call <SID>X_HI("Identifier", s:code_identifier, "", "")
call <SID>X_HI("Statement", s:code_statment, "", "")
call <SID>X_HI("Conditional", s:code_statment, "", "")
call <SID>X_HI("Repeat", s:code_statment, "", "")
call <SID>X_HI("Structure", s:code_statment, "", "")
call <SID>X_HI("Function", s:code_function, "", "")
call <SID>X_HI("Constant", s:code_constant, "", "")
call <SID>X_HI("Keyword", s:code_identifier, "", "bold")
call <SID>X_HI("String", s:code_string, "", "")
call <SID>X_HI("Special", s:code_type, "", "")
call <SID>X_HI("PreProc", s:code_preproc, "", "")
call <SID>X_HI("Operator", s:code_operator, "", "")
call <SID>X_HI("Type", s:code_type, "", "")
call <SID>X_HI("Define", s:code_statment, "", "")
call <SID>X_HI("Include", s:code_include, "", "")
call <SID>X_HI("Tag", s:code_tag, "", "bold")
call <SID>X_HI("Underlined", s:code_tag, "", "underline")

syntax match commonOperator "\(+\|=\|-\|*\|\^\|\/\||\)"
hi! link commonOperator Operator

" Vim Highlighting
call <SID>X_HI("vimCommand", s:wine, "", "NONE")

" C Highlighting
call <SID>X_HI("cType", s:code_type, "", "")
call <SID>X_HI("cStorageClass", s:code_class, "", "")
call <SID>X_HI("cConditional", s:wine, "", "")
call <SID>X_HI("cRepeat", s:wine, "", "")

" Python Highlighting
call <SID>X_HI("pythonInclude", s:green, "", italic)
call <SID>X_HI("pythonStatement", s:blue, "", "")
call <SID>X_HI("pythonConditional", s:wine, "", "")
call <SID>X_HI("pythonRepeat", s:wine, "", "")
call <SID>X_HI("pythonException", s:orange, "", "")
call <SID>X_HI("pythonFunction", s:green, "", italic)
call <SID>X_HI("pythonPreCondit", s:wine, "", "")
call <SID>X_HI("pythonExClass", s:orange, "", "")
call <SID>X_HI("pythonBuiltin", s:blue, "", "")
call <SID>X_HI("pythonOperator", s:wine, "", "")
call <SID>X_HI("pythonNumber", s:purple, "", "")
call <SID>X_HI("pythonString", s:yellow, "", "")
call <SID>X_HI("pythonRawString", s:yellow, "", "")
call <SID>X_HI("pythonDecorator", s:wine, "", "")
call <SID>X_HI("pythonDoctest", s:yellow, "", "")
call <SID>X_HI("pythonImportFunction", s:orange, "", "")
call <SID>X_HI("pythonImportModule", s:orange, "", "")
call <SID>X_HI("pythonImportObject", s:orange, "", "")
call <SID>X_HI("pythonImportedClassDef", s:orange, "", "")
call <SID>X_HI("pythonImportedFuncDef", s:orange, "", "")
call <SID>X_HI("pythonImportedModule", s:orange, "", "")
call <SID>X_HI("pythonImportedObject", s:orange, "", "")

" PHP Highlighting
call <SID>X_HI("phpVarSelector", s:wine, "", "")
call <SID>X_HI("phpKeyword", s:wine, "", "")
call <SID>X_HI("phpRepeat", s:wine, "", "")
call <SID>X_HI("phpConditional", s:wine, "", "")
call <SID>X_HI("phpStatement", s:wine, "", "")
call <SID>X_HI("phpMemberSelector", s:foreground, "", "")

" Ruby Highlighting
call <SID>X_HI("rubySymbol", s:blue, "", "")
call <SID>X_HI("rubyConstant", s:green, "", "")
call <SID>X_HI("rubyAccess", s:yellow, "", "")
call <SID>X_HI("rubyAttribute", s:blue, "", "")
call <SID>X_HI("rubyInclude", s:blue, "", "")
call <SID>X_HI("rubyLocalVariableOrMethod", s:orange, "", "")
call <SID>X_HI("rubyCurlyBlock", s:orange, "", "")
call <SID>X_HI("rubyStringDelimiter", s:yellow, "", "")
call <SID>X_HI("rubyInterpolationDelimiter", s:orange, "", "")
call <SID>X_HI("rubyConditional", s:wine, "", "")
call <SID>X_HI("rubyRepeat", s:wine, "", "")
call <SID>X_HI("rubyControl", s:wine, "", "")
call <SID>X_HI("rubyException", s:wine, "", "")

" Crystal Highlighting
" call <SID>X_HI("crystalSymbol", s:green, "", "")
" call <SID>X_HI("crystalConstant", s:yellow, "", "")
" call <SID>X_HI("crystalAccess", s:yellow, "", "")
" call <SID>X_HI("crystalAttribute", s:blue, "", "")
" call <SID>X_HI("crystalInclude", s:blue, "", "")
" call <SID>X_HI("crystalLocalVariableOrMethod", s:orange, "", "")
" call <SID>X_HI("crystalCurlyBlock", s:orange, "", "")
" call <SID>X_HI("crystalStringDelimiter", s:green, "", "")
" call <SID>X_HI("crystalInterpolationDelimiter", s:orange, "", "")
" call <SID>X_HI("crystalConditional", s:wine, "", "")
" call <SID>X_HI("crystalRepeat", s:wine, "", "")
" call <SID>X_HI("crystalControl", s:wine, "", "")
" call <SID>X_HI("crystalException", s:wine, "", "")

" JavaScript Highlighting
" call <SID>X_HI("javaScriptEndColons", s:foreground, "", "")
" call <SID>X_HI("javaScriptOpSymbols", s:foreground, "", "")
" call <SID>X_HI("javaScriptLogicSymbols", s:foreground, "", "")
" call <SID>X_HI("javaScriptBraces", s:foreground, "", "")
" call <SID>X_HI("javaScriptParens", s:foreground, "", "")
" call <SID>X_HI("javaScriptFunction", s:green, "", "")
" call <SID>X_HI("javaScriptComment", s:comment, "", "")
" call <SID>X_HI("javaScriptLineComment", s:comment, "", "")
" call <SID>X_HI("javaScriptDocComment", s:comment, "", "")
" call <SID>X_HI("javaScriptCommentTodo", s:red, "", "")
" call <SID>X_HI("javaScriptString", s:yellow, "", "")
" call <SID>X_HI("javaScriptRegexpString", s:yellow, "", "")
" call <SID>X_HI("javaScriptTemplateString", s:yellow, "", "")
" call <SID>X_HI("javaScriptNumber", s:purple, "", "")
" call <SID>X_HI("javaScriptFloat", s:purple, "", "")
" call <SID>X_HI("javaScriptGlobal", s:purple, "", "")
" call <SID>X_HI("javaScriptCharacter", s:blue, "", "")
" call <SID>X_HI("javaScriptPrototype", s:blue, "", "")
" call <SID>X_HI("javaScriptConditional", s:blue, "", "")
" call <SID>X_HI("javaScriptBranch", s:blue, "", "")
" call <SID>X_HI("javaScriptIdentifier", s:orange, "", "")
" call <SID>X_HI("javaScriptRepeat", s:blue, "", "")
" call <SID>X_HI("javaScriptStatement", s:blue, "", "")
" call <SID>X_HI("javaScriptMessage", s:blue, "", "")
" call <SID>X_HI("javaScriptReserved", s:blue, "", "")
" call <SID>X_HI("javaScriptOperator", s:blue, "", "")
" call <SID>X_HI("javaScriptNull", s:purple, "", "")
" call <SID>X_HI("javaScriptBoolean", s:purple, "", "")
" call <SID>X_HI("javaScriptLabel", s:blue, "", "")
" call <SID>X_HI("javaScriptSpecial", s:blue, "", "")
" call <SID>X_HI("javaScriptExceptions", s:red, "", "")
" call <SID>X_HI("javaScriptDeprecated", s:red, "", "")
" call <SID>X_HI("javaScriptError", s:red, "", "")

" HTML Highlighting
" call <SID>X_HI("htmlTag", s:blue, "", "")
" call <SID>X_HI("htmlEndTag", s:blue, "", "")
" call <SID>X_HI("htmlTagName", s:wine, "", "bold")
" call <SID>X_HI("htmlArg", s:green, "", italic)
" call <SID>X_HI("htmlScriptTag", s:wine, "", "")

" Go Highlighting
" call <SID>X_HI("goDirective", s:wine, "", "")
" call <SID>X_HI("goDeclaration", s:wine, "", "")
" call <SID>X_HI("goStatement", s:wine, "", "")
" call <SID>X_HI("goConditional", s:wine, "", "")
" call <SID>X_HI("goConstants", s:orange, "", "")
" call <SID>X_HI("goTodo", s:red, "", "")
" call <SID>X_HI("goDeclType", s:blue, "", "")
" call <SID>X_HI("goBuiltins", s:wine, "", "")
" call <SID>X_HI("goRepeat", s:wine, "", "")
" call <SID>X_HI("goLabel", s:wine, "", "")

" LaTeX
" call <SID>X_HI("texStatement",s:blue, "", "")
" call <SID>X_HI("texMath", s:wine, "", "NONE")
" call <SID>X_HI("texMathMacher", s:yellow, "", "NONE")
" call <SID>X_HI("texRefLabel", s:wine, "", "NONE")
" call <SID>X_HI("texRefZone", s:blue, "", "NONE")
" call <SID>X_HI("texComment", s:comment, "", "NONE")
" call <SID>X_HI("texDelimiter", s:purple, "", "NONE")
" call <SID>X_HI("texMathZoneX", s:purple, "", "NONE")

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
call <SID>X_HI("diffAdd", "", s:diff_add, "")
call <SID>X_HI("diffDelete", s:background, s:diff_del, "")
call <SID>X_HI("diffChange", "", s:diff_change, "")
call <SID>X_HI("diffText", s:line, s:diff_content, "")

""""    Plugins
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Git
call <SID>X_HI("gitFile", s:orange, "", "")
call <SID>X_HI("gitcommitSummary", "", "", "bold")

" " GitGutter
" call <SID>X_HI("GitGutterAdd", s:green, s:chosen_background, "bold")
" call <SID>X_HI("GitGutterChange", s:yellow, s:chosen_background, "bold")
" call <SID>X_HI("GitGutterDelete", s:red, s:chosen_background, "bold")
call <SID>X_HI("GitGutterChangeDelete", s:diff_del, s:chosen_background, "bold")

" Vim-Bookmark
" call <SID>X_HI("BookmarkLine", s:foreground, s:fg_selection, "bold")
call <SID>X_HI("BookmarkLine", "", "", "reverse")

" " ALE (plugin)
" call <SID>X_HI("ALEWarningSign", s:orange, s:chosen_background, "bold")
" call <SID>X_HI("ALEErrorSign", s:red, s:chosen_background, "bold")

" Option g:flag_blackout
if !exists( "g:flag_blackout")
    let g:flag_blackout = 0
endif

"" Others
" Settings dependent on g:flag_blackout
call <SID>X_HI("Normal", s:foreground, s:chosen_background, "")
call <SID>X_HI("LineNr", s:comment, s:chosen_background, "")
if version >= 700
    call <SID>X_HI("SignColumn", "", s:chosen_background, "NONE")
end
call <SID>X_HI("Todo", s:todo, s:chosen_background, "bold")

" Diffs
" Plugin GitGutter uses highlight link to some of the groups below
call <SID>X_HI("DiffAdded", s:diff_add, s:chosen_background, "")
call <SID>X_HI("DiffChange", s:diff_content, s:chosen_background, "")
call <SID>X_HI("DiffDelete", s:diff_del, s:chosen_background, "")
call <SID>X_HI("DiffLine", s:diff_change, s:chosen_background, italic)
call <SID>X_HI("DiffSubname", s:foreground, s:chosen_background, "")

""""    Aliases
""""""""""""""""""""""""""""""""""""""""""""""""""""""
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

""""    Post del function
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Don't do this, beczuse we use au for fasten open speed
" Delete Functions
delf <SID>X_HI
delf <SID>rgb
delf <SID>colour
delf <SID>rgb_colour
delf <SID>rgb_level
delf <SID>rgb_number
delf <SID>grey_colour
delf <SID>grey_level
delf <SID>grey_number
