" If g:save_all_highlights is 1, save all highlight colors known by vim,
" otherwise save the one listed in s:names below.
" echom "save_colorscheme"
if exists('g:save_all_highlights')
    let s:save_all_highlights = g:save_all_highlights
else
    let s:save_all_highlights = 1
endif
let s:scheme_name=get(g:, 'IDE_ENV_CACHED_COLORSCHEME', 'cached_color')
" let s:scheme_name='cached_color'
let s:file_path='~/.vim/colors/'.s:scheme_name.'.vim'

if !empty(glob(s:file_path))
    echoerr s:file_path.' file exists, stop generating file.'
    throw l:output
endif

" List of hightlights from
" https://github.com/ggalindezb/vim_colorscheme_template/blob/master/template.vim
" plus highlights for diff files
" https://github.com/ggalindezb/vim_colorscheme_template/issues/1.
let s:names = [
            \ 'Normal',
            \ 'Cursor',
            \ 'CursorLine',
            \ 'LineNr',
            \ 'CursorLineNR',
            \ 'CursorColumn',
            \ 'FoldColumn',
            \ 'SignColumn',
            \ 'Folded',
            \ 'VertSplit',
            \ 'ColorColumn',
            \ 'TabLine',
            \ 'TabLineFill',
            \ 'TabLineSel',
            \ 'Directory',
            \ 'Search',
            \ 'IncSearch',
            \ 'StatusLine',
            \ 'StatusLineNC',
            \ 'WildMenu',
            \ 'Question',
            \ 'Title',
            \ 'ModeMsg',
            \ 'MoreMsg',
            \ 'MatchParen',
            \ 'Visual',
            \ 'VisualNOS',
            \ 'NonText',
            \ 'Todo',
            \ 'Underlined',
            \ 'Error',
            \ 'ErrorMsg',
            \ 'WarningMsg',
            \ 'Ignore',
            \ 'SpecialKey',
            \ 'Constant',
            \ 'String',
            \ 'StringDelimiter',
            \ 'Character',
            \ 'Number',
            \ 'Boolean',
            \ 'Float',
            \ 'Identifier',
            \ 'Function',
            \ 'Statement',
            \ 'Conditional',
            \ 'Repeat',
            \ 'Label',
            \ 'Operator',
            \ 'Keyword',
            \ 'Exception',
            \ 'Comment',
            \ 'Special',
            \ 'SpecialChar',
            \ 'Tag',
            \ 'Delimiter',
            \ 'SpecialComment',
            \ 'Debug',
            \ 'PreProc',
            \ 'Include',
            \ 'Define',
            \ 'Macro',
            \ 'PreCondit',
            \ 'Type',
            \ 'StorageClass',
            \ 'Structure',
            \ 'Typedef',
            \ 'DiffAdd',
            \ 'DiffChange',
            \ 'DiffDelete',
            \ 'DiffText',
            \ 'diffAdded',
            \ 'diffChanged',
            \ 'diffRemoved',
            \ 'diffLine',
            \ 'Pmenu',
            \ 'PmenuSel',
            \ 'PmenuSbar',
            \ 'PmenuThumb',
            \ 'SpellBad',
            \ 'SpellCap',
            \ 'SpellLocal',
            \ 'SpellRare',
            \]
" Preparation.
let s:filelist = [
            \'c',
            \'cpp',
            \'python',
            \'php',
            \'vim',
            \]
for s:each_type in s:filelist
    execute 'set filetype=' . s:each_type
endfor

" Preamble.
exec "tabnew" . s:file_path
call append('$', ('" Set ''background'' back to the default.  The value can''t always be estimated'))
call append('$', ('" and is then guessed.'))
" call append('$', ('hi clear Normal'))
" call append('$', ('set background&'))
call append('$', ('set background='.&background))
call append('$', (''))
call append('$', ('" Remove all existing highlighting and set the defaults.'))
call append('$', ('hi clear'))
call append('$', (''))
" this alrady done by hi clear
" call append('$', ('" Load the syntax highlighting defaults, if it''s enabled.'))
" call append('$', ('if exists("syntax_on")'))
" call append('$', ('  syntax reset'))
" call append('$', ('endif'))
call append('$', (''))

if (s:save_all_highlights == 1)
    let s:names = getcompletion('', 'highlight')
endif

call append('$', ('if has("nvim")'))
" nvim patch
for s:name in s:names
    let s:id = hlID(s:name)
    let s:tid = synIDtrans(s:id)

    " echom stridx(s:name, "@")
    if stridx(s:name, "@") == -1
        continue
    endif

    if (s:id != s:tid)
        " call append('$', ('hi link %s %s', s:name, synIDattr(s:tid, 'name')))
        call append('$', ('hi! link '.s:name.' '.synIDattr(s:tid, 'name')))
    else
        let s:cterm = 'none'
        if (synIDattr(s:id, 'bold', 'cterm') == '1')
            let s:cterm = 'bold'
        elseif (synIDattr(s:id, 'italic', 'cterm') == '1')
            let s:cterm = 'italic'
        elseif (synIDattr(s:id, 'reverse', 'cterm') == '1')
            let s:cterm = 'reverse'
        elseif (synIDattr(s:id, 'inverse', 'cterm') == '1')
            let s:cterm = 'reverse'
        elseif (synIDattr(s:id, 'standout', 'cterm') == '1')
            let s:cterm = 'standout'
        elseif (synIDattr(s:id, 'underline', 'cterm') == '1')
            let s:cterm = 'underline'
        elseif (synIDattr(s:id, 'undercurl', 'cterm') == '1')
            let s:cterm = 'undercurl'
        elseif (synIDattr(s:id, 'strikethrough', 'cterm') == '1')
            let s:cterm = 'strikethrough'
        endif
        if (synIDattr(s:id, 'fg', 'cterm') != '')
            let s:ctermfg = synIDattr(s:id, 'fg', 'cterm')
        else
            let s:ctermfg = 'none'
        endif
        if (synIDattr(s:id, 'bg', 'cterm') != '')
            let s:ctermbg = synIDattr(s:id, 'bg', 'cterm')
        else
            let s:ctermbg = 'none'
        endif
        call append('$', ('hi '.s:name.' cterm='.s:cterm.' ctermfg='.s:ctermfg.' ctermbg='.s:ctermbg))
    endif
endfor
call append('$', ('endif'))

for s:name in s:names
    let s:id = hlID(s:name)
    let s:tid = synIDtrans(s:id)

    " echom stridx(s:name, "@")
    if stridx(s:name, "@") != -1
        continue
    endif

    if (s:id != s:tid)
        " call append('$', ('hi link %s %s', s:name, synIDattr(s:tid, 'name')))
        call append('$', ('hi! link '.s:name.' '.synIDattr(s:tid, 'name')))
    else
        let s:cterm = 'none'
        if (synIDattr(s:id, 'bold', 'cterm') == '1')
            let s:cterm = 'bold'
        elseif (synIDattr(s:id, 'italic', 'cterm') == '1')
            let s:cterm = 'italic'
        elseif (synIDattr(s:id, 'reverse', 'cterm') == '1')
            let s:cterm = 'reverse'
        elseif (synIDattr(s:id, 'inverse', 'cterm') == '1')
            let s:cterm = 'reverse'
        elseif (synIDattr(s:id, 'standout', 'cterm') == '1')
            let s:cterm = 'standout'
        elseif (synIDattr(s:id, 'underline', 'cterm') == '1')
            let s:cterm = 'underline'
        elseif (synIDattr(s:id, 'undercurl', 'cterm') == '1')
            let s:cterm = 'undercurl'
        elseif (synIDattr(s:id, 'strikethrough', 'cterm') == '1')
            let s:cterm = 'strikethrough'
        endif
        if (synIDattr(s:id, 'fg', 'cterm') != '')
            let s:ctermfg = synIDattr(s:id, 'fg', 'cterm')
        else
            let s:ctermfg = 'none'
        endif
        if (synIDattr(s:id, 'bg', 'cterm') != '')
            let s:ctermbg = synIDattr(s:id, 'bg', 'cterm')
        else
            let s:ctermbg = 'none'
        endif
        call append('$', ('hi '.s:name.' cterm='.s:cterm.' ctermfg='.s:ctermfg.' ctermbg='.s:ctermbg))
    endif
endfor

call append('$', (''))
call append('$', "let g:colors_name = '".s:scheme_name."'")

exec "write"
exec "bd"
