" =============================================================================
" Filename: autoload/lightline/colorscheme/wombat.vim
" Author: itchyny
" License: MIT License
" Last Change: 2015/11/30 08:37:43.
" =============================================================================
" Predefine color table
" ['GUI Color', 'CUI Color IDX']
let s:gray03   = [ '#242424', 235 ]
let s:gray023  = [ '#353535', 236 ]
let s:gray02   = [ '#444444', 238 ]
let s:gray01   = [ '#585858', 240 ]
let s:gray00   = [ '#666666', 242 ]
let s:gray0    = [ '#808080', 244 ]
let s:gray1    = [ '#969696', 247 ]
let s:gray2    = [ '#a8a8a8', 248 ]
let s:gray3    = [ '#d0d0d0', 252 ]
let s:yellow   = [ '#cae682', 180 ]
let s:orange   = [ '#e5786d', 173 ]
let s:red      = [ '#e5786d', 203 ]
let s:magenta  = [ '#f2c68a', 216 ]
let s:blue     = [ '#8ac6f2', 117 ]
let s:cyan     = s:blue
let s:green    = [ '#95e454', 119 ]
let s:black    = [ '#000000', 16 ]
let s:black    = [ '#000000', 16 ]
let s:darkblue = [ '#0087af', 31 ]
let s:white    = [ '#ffffff', 231 ]

"" Status line
" Structure define
let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}

" Formate ["Foreground", "Barckground"]
let s:p.normal.right    = [ [ s:gray02, s:gray0 ], [ s:gray1, s:gray01 ] ]
let s:p.normal.left     = [ [ s:gray02, s:blue ], [ s:gray3, s:gray01 ] ]
let s:p.inactive.right  = [ [ s:gray023, s:gray01 ], [ s:gray00, s:gray02 ] ]
let s:p.inactive.left   = [ [ s:gray1, s:gray02 ], [ s:gray00, s:gray023 ] ]
let s:p.insert.left     = [ [ s:gray02, s:green ], [ s:gray3, s:gray01 ] ]
let s:p.replace.left    = [ [ s:gray023, s:red ], [ s:gray3, s:gray01 ] ]
let s:p.visual.left     = [ [ s:gray02, s:magenta ], [ s:gray3, s:gray01 ] ]
let s:p.normal.middle   = [ [ s:gray2, s:gray02 ] ]
let s:p.inactive.middle = [ [ s:gray1, s:gray023 ] ]
let s:p.normal.error    = [ [ s:gray03, s:red ] ]
let s:p.normal.warning  = [ [ s:gray023, s:yellow ] ]

"" Table line
let s:p.tabline.left    = [ [ s:gray3, s:gray00 ] ]
let s:p.tabline.tabsel  = [ [ s:gray02, s:blue ] ]
let s:p.tabline.middle  = [ [ s:gray2, s:gray02 ] ]
let s:p.tabline.right   = [ [ s:gray2, s:gray00 ] ]

let g:lightline#colorscheme#wombat_lab#palette = lightline#colorscheme#flatten(s:p)
