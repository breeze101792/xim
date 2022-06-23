" Set 'background' back to the default.  The value can't always be estimated
" and is then guessed.
hi clear Normal
set background&

" Remove all existing highlighting and set the defaults.
hi clear

" Load the syntax highlighting defaults, if it's enabled.
if exists("syntax_on")
  syntax reset
endif

hi Normal cterm=none ctermfg=252 ctermbg=none
hi Cursor cterm=none ctermfg=none ctermbg=none
hi CursorLine cterm=none ctermfg=none ctermbg=236
hi LineNr cterm=none ctermfg=242 ctermbg=none
hi CursorLineNR cterm=none ctermfg=172 ctermbg=none
hi CursorColumn cterm=none ctermfg=none ctermbg=236
hi FoldColumn cterm=none ctermfg=14 ctermbg=233
hi SignColumn cterm=none ctermfg=14 ctermbg=none
hi Folded cterm=none ctermfg=242 ctermbg=233
hi VertSplit cterm=none ctermfg=59 ctermbg=59
hi ColorColumn cterm=none ctermfg=none ctermbg=236
hi TabLine cterm=reverse ctermfg=59 ctermbg=252
hi TabLineFill cterm=reverse ctermfg=59 ctermbg=252
hi TabLineSel cterm=bold ctermfg=none ctermbg=none
hi Directory cterm=none ctermfg=67 ctermbg=none
hi Search cterm=none ctermfg=233 ctermbg=179
hi IncSearch cterm=reverse ctermfg=none ctermbg=none
hi StatusLine cterm=reverse ctermfg=59 ctermbg=179
hi StatusLineNC cterm=reverse ctermfg=59 ctermbg=252
hi WildMenu cterm=none ctermfg=0 ctermbg=11
hi Question cterm=none ctermfg=150 ctermbg=none
hi Title cterm=bold ctermfg=242 ctermbg=none
hi ModeMsg cterm=bold ctermfg=150 ctermbg=none
hi MoreMsg cterm=none ctermfg=150 ctermbg=none
hi MatchParen cterm=none ctermfg=none ctermbg=60
hi Visual cterm=none ctermfg=none ctermbg=60
hi VisualNOS cterm=none ctermfg=none ctermbg=none
hi NonText cterm=none ctermfg=60 ctermbg=none
hi Todo cterm=bold ctermfg=124 ctermbg=none
hi Underlined cterm=underline ctermfg=172 ctermbg=none
hi Error cterm=none ctermfg=15 ctermbg=9
hi ErrorMsg cterm=none ctermfg=15 ctermbg=1
hi WarningMsg cterm=bold ctermfg=172 ctermbg=none
hi Ignore cterm=none ctermfg=0 ctermbg=none
hi SpecialKey cterm=none ctermfg=60 ctermbg=none
hi Constant cterm=none ctermfg=140 ctermbg=none
hi String cterm=none ctermfg=179 ctermbg=none
hi StringDelimiter cterm=none ctermfg=none ctermbg=none
hi link Character Constant
hi link Number Constant
hi link Boolean Constant
hi link Float Constant
hi Identifier cterm=bold ctermfg=172 ctermbg=none
hi Function cterm=none ctermfg=172 ctermbg=none
hi Statement cterm=none ctermfg=132 ctermbg=none
hi Conditional cterm=none ctermfg=132 ctermbg=none
hi Repeat cterm=none ctermfg=132 ctermbg=none
hi link Label Statement
hi Operator cterm=none ctermfg=140 ctermbg=none
hi Keyword cterm=none ctermfg=172 ctermbg=none
hi link Exception Statement
hi Comment cterm=none ctermfg=242 ctermbg=none
hi Special cterm=none ctermfg=67 ctermbg=none
hi link SpecialChar Special
hi Tag cterm=bold ctermfg=172 ctermbg=none
hi link Delimiter Special
hi link SpecialComment Special
hi link Debug Special
hi PreProc cterm=none ctermfg=150 ctermbg=none
hi Include cterm=none ctermfg=132 ctermbg=none
hi Define cterm=none ctermfg=132 ctermbg=none
hi link Macro PreProc
hi link PreCondit PreProc
hi Type cterm=none ctermfg=67 ctermbg=none
hi link StorageClass Type
hi Structure cterm=none ctermfg=132 ctermbg=none
hi link Typedef Type
hi link DiffAdd DiffAdded
hi DiffChange cterm=none ctermfg=179 ctermbg=none
hi DiffDelete cterm=none ctermfg=124 ctermbg=none
hi DiffText cterm=bold ctermfg=236 ctermbg=67
hi diffAdded cterm=none ctermfg=150 ctermbg=none
hi diffChanged cterm=none ctermfg=none ctermbg=none
hi link diffRemoved DiffDelete
hi diffLine cterm=italic ctermfg=67 ctermbg=none
hi Pmenu cterm=none ctermfg=252 ctermbg=60
hi PmenuSel cterm=reverse ctermfg=252 ctermbg=60
hi PmenuSbar cterm=none ctermfg=none ctermbg=248
hi PmenuThumb cterm=none ctermfg=none ctermbg=15
hi SpellBad cterm=none ctermfg=none ctermbg=9
hi SpellCap cterm=none ctermfg=none ctermbg=12
hi SpellLocal cterm=none ctermfg=none ctermbg=14
hi SpellRare cterm=none ctermfg=none ctermbg=13

let g:colors_name = 'vimdefault'
