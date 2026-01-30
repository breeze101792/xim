
""""    Function map
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Session copy/pates
map <silent> <Leader>y :call SessionYank()<CR>
vmap <silent> <Leader>y y:call SessionYank()<CR>
vmap <silent> <Leader>Y Y:call SessionYank()<CR>
nmap <silent> <Leader>p :call SessionPaste("p")<CR>
nmap <silent> <Leader>P :call SessionPaste("P")<CR>
nmap <silent> <Leader>o :call ClipOpen()<CR>

" Mouse Toggle
nnoremap <silent> <C-m> :MouseToggle<CR>

" Toggle Hex Mode
nmap <Leader>h :HexToggle<CR>

" Match & complete patterns
" TODO, think another way to detect paried one, so disable it for now.
" inoremap <expr> ( ConditionalPairMap('(', ')')
" inoremap <expr> { ConditionalPairMap('{', '}')
" inoremap <expr> [ ConditionalPairMap('[', ']')

" Beautify, currently only support shell
vnoremap <leader>b :Beautify<CR>

" only apply if autochdir is disabled.
if !(exists('&autochdir') && &autochdir) && exists('*OpenFileFromCurrentDir')
    map <C-o> <Esc>:silent call OpenFileFromCurrentDir()<CR>
endif

""""    Function Key
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" F2,F3,F4 are reserved.
" Refresh all
nmap <F5> :redraw!<CR>

" Tag bar
nmap <F6> :TagbarToggle<CR>

" file bar
nmap <F7> :NERDTreeToggle<CR>

" cctree
" will be needed first CCTreeTraceForward
nmap <F8> :CCTreeWindowToggle<CR>

" LLM
map <F9> <ESC>:LLMToggle<CR>
imap <F9> <ESC>:LLMToggle<CR>

""""    Plugins map
""""""""""""""""""""""""""""""""""""""""""""""""""""""
" IDE map

" cscope
" a: Find places where this symbol is assigned a value
" c: Find functions calling this function
" d: Find functions called by this function
" e: Find this egrep pattern
" f: Find this file
" g: Find this definition
" i: Find files #including this file
" s: Find this C symbol
" t: Find this text string
" TODO, find a way to map those key with more easy way to access.
if g:IDE_ENV_INS == "nvim"
    nnoremap <silent>ca :exec "Cscope find a ".expand('<cword>')<CR>
    nnoremap <silent>cc :exec "Cscope find c ".expand('<cword>')<CR>
    nnoremap <silent>cd :exec "Cscope find d ".expand('<cword>')<CR>
    nnoremap <silent>ce :exec "Cscope find e ".expand('<cword>')<CR>
    nnoremap <silent>cf :exec "Cscope find f ".expand('<cword>')<CR>
    nnoremap <silent>cg :exec "Cscope find g ".expand('<cword>')<CR>
    nnoremap <silent>ci :exec "Cscope find i ".expand('<cword>')<CR>
    " nnoremap <silent>cs :exec "Cscope find s ".expand('<cword>')<CR>
    nnoremap <silent>ct :exec "Cscope find t ".expand('<cword>')<CR>
else
    nnoremap <silent>ca :cscope find a <cword><CR>
    nnoremap <silent>cc :cscope find c <cword><CR>
    nnoremap <silent>cd :cscope find d <cword><CR>
    nnoremap <silent>ce :cscope find e <cword><CR>
    nnoremap <silent>cf :cscope find f <cword><CR>
    nnoremap <silent>cg :cscope find g <cword><CR>
    nnoremap <silent>ci :cscope find i <cword><CR>
    nnoremap <silent>cs :cscope find s <cword><CR>
    nnoremap <silent>ct :cscope find t <cword><CR>
endif

" LSP
" NOTE. vim version check on coc impl.
if g:IDE_ENV_INS == "nvim"
    nnoremap <silent>gD :lua vim.lsp.buf.declaration()<CR>
    nnoremap <silent>gd :lua vim.lsp.buf.definition()<CR>
    nnoremap <silent>gh :lua vim.lsp.buf.hover()<CR>
    nnoremap <silent>gi :lua vim.lsp.buf.implementation()<CR>
    nnoremap <silent>gR :lua vim.lsp.buf.references()<CR>
    nnoremap <silent>gr :lua vim.lsp.buf.incoming_calls()<CR>
    nnoremap <silent>go :lua vim.lsp.buf.outgoing_calls()<CR>
    nnoremap <silent>gN :lua vim.lsp.diagnostic.goto_prev()<CR>
    nnoremap <silent>gn :lua vim.lsp.diagnostic.goto_next()<CR>
    " fix code
    nnoremap <silent>gf :lua vim.lsp.buf.code_action()<CR>
    " rename Variable
    nnoremap <silent>rn :lua vim.lsp.buf.rename()<CR>

    nnoremap <leader>i <cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>

    " --- LSP Advanced Features ---
    " 1. Show current diagnostics (Floating window for Error/Warning)
    nnoremap <silent>ge :lua vim.diagnostic.open_float()<CR>
    " 2. Show document symbols (Find current function/variable definitions)
    nnoremap <silent>gs :lua vim.lsp.buf.document_symbol()<CR>
    " 3. Search workspace symbols (Find structures or global variables in the project)
    nnoremap <silent>gw :lua vim.lsp.buf.workspace_symbol()<CR>
    " 4. Code formatting (Auto-align using clang-format)
    nnoremap <silent><leader>f :lua vim.lsp.buf.format({ async = true })<CR>
    " 5. Signature help (Manual trigger)
    nnoremap <silent>gk :lua vim.lsp.buf.signature_help()<CR>
    " 6. Go to type definition (Jump to the original typedef location)
    nnoremap <silent>gt :lua vim.lsp.buf.type_definition()<CR>

    " Jump to Prev/Next Diagnostic
    nnoremap <silent> [g <cmd>lua vim.diagnostic.goto_prev()<CR>
    nnoremap <silent> ]g <cmd>lua vim.diagnostic.goto_next()<CR>
    " Jump to Prev/Next Error
    nnoremap <silent> [E <cmd>lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })<CR>
    nnoremap <silent> ]E <cmd>lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })<CR>
endif

if g:IDE_CFG_IMPL_COMPLETION == "coc"
    " coc
    " ctrl-j, next Snippet
    " Tab key to select completion (replaces SuperTab)
    inoremap <silent><expr> <TAB>
                \ coc#pum#visible() ? coc#pum#next(1) :
                \ CheckBackspace() ? "\<Tab>" :
                \ coc#refresh()
    inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

    " Enter to confirm completion
    inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

    " Manually trigger parameter hints (press Ctrl+f)
    " inoremap <silent> <C-f> <C-r>=CocActionAsync('showSignatureHelp')<CR>

    " Diagnostic navigation (if there are red errors, press [g and ]g to jump)
    nnoremap <silent> [g <Plug>(coc-diagnostic-prev)
    nnoremap <silent> ]g <Plug>(coc-diagnostic-next)

    " Jump to Prev/Next Error
    nnoremap <silent> [E :call CocAction('diagnosticPrevious', 'error')<CR>
    nnoremap <silent> ]E :call CocAction('diagnosticNext', 'error')<CR>

    " Code navigation (Go to definition)
    " nmap <silent> gd <Plug>(coc-definition)
    " nmap <silent> gy <Plug>(coc-type-definition)

    " conflit with move line
    " nnoremap <silent> K :call ShowDocumentation()<CR>

    " Format - Keep code clean
    " nmap <leader>f  <Plug>(coc-format)

    " Quick Fix - e.g. automatically add missing #include
    " nmap <leader>qf  <Plug>(coc-fix-current)

    " Vim lsp
    if g:IDE_ENV_INS == "vim"
        " Go to Declaration
        nnoremap <silent> gD <Plug>(coc-declaration)
        " Go to Definition
        nnoremap <silent> gd <Plug>(coc-definition)
        " Show Hover / Documentation
        nnoremap <silent> gh :call CocActionAsync('doHover')<CR>
        " Go to Implementation
        nnoremap <silent> gi <Plug>(coc-implementation)
        " Find References
        nnoremap <silent> gR <Plug>(coc-references)
        " Find Incoming Calls
        nnoremap <silent> gr :CocList callHierarchy<CR>
        " Find Outgoing Calls
        nnoremap <silent> go :CocList --tab callHierarchy --outgoing<CR>
        " Previous Diagnostic
        nnoremap <silent> gN <Plug>(coc-diagnostic-prev)
        " Next Diagnostic
        nnoremap <silent> gn <Plug>(coc-diagnostic-next)

        " Fix code (Code Action)
        nnoremap <silent> gf <Plug>(coc-codeaction-cursor)
        " Rename Variable
        nnoremap <silent> rn <Plug>(coc-rename)

        " Toggle Inlay Hints (Parameter type hints)
        nnoremap <leader>i :CocCommand document.toggleInlayHint<CR>

        " --- COC Advanced Features (Consistent with nvim version) ---
        " 1. Show current diagnostics (Floating window)
        nnoremap <silent>ge :call CocActionAsync('showSignatureHelp')<CR>
        " 2. Show document symbols
        nnoremap <silent>gs :CocList outline<CR>
        " 3. Search workspace symbols
        nnoremap <silent>gw :CocList -I symbols<CR>
        " 4. Code formatting
        nnoremap <silent><leader>f <Plug>(coc-format)
        " 5. Signature help
        nnoremap <silent>gk :call CocActionAsync('showSignatureHelp')<CR>
        " 6. Go to type definition
        nnoremap <silent>gt <Plug>(coc-type-definition)
    endif
" elseif g:IDE_CFG_IMPL_COMPLETION == "ncmp"
"     NOTE. define it on lua file.
"     pass
elseif g:IDE_CFG_IMPL_COMPLETION == "supertab"
    " supertab
    imap <script> <Plug>SuperTabForward <c-r>=SuperTab('n')<cr>
    imap <script> <Plug>SuperTabBackward <c-r>=SuperTab('p')<cr>
    imap <silent> <tab> <Plug>SuperTabForward
endif


" " srcexpl
" nnoremap <silent><Leader>t :SrcExplRefresh<CR>

" Commentary settings
noremap <C-_> :CommentCode<CR>
noremap cm :CommentCode<CR>
" noremap! <Leader>/ :CommentCodeBlock<CR>
" noremap <C-?> :CommentCode<CR>

" GitGutter settings
" map <C-g> :GitGutterToggle<CR>
nmap ]c :GitGutterNextHunk<CR>
nmap [c :GitGutterPrevHunk<CR>

" tabular
vnoremap <leader>t :Tabularize /

" bookmark
noremap mm :BookmarkToggle<CR>

" CtrlP
noremap <C-p> :CtrlP<CR>

" bufferexpl
nnoremap <leader>b :ToggleBufExplorer<CR>

" mark
" nmap <unique> <Leader>m <Plug>MarkSet
nnoremap <Leader>m :HighlighterToggle<CR>
" hlsearch work only when /[search] noh
nnoremap <silent>* *:nohlsearch<CR>
nnoremap <silent># #:nohlsearch<CR>

"  cctree trace
noremap <leader>] :CCTreeTraceForward<CR>
noremap <leader>[ :CCTreeTraceReverse<CR>
nnoremap <silent>tf :CCTreeTraceForward<CR>
nnoremap <silent>tr :CCTreeTraceReverse<CR>
" Load db from cscope
nnoremap <silent>ts :CCTreeSetup<CR>

" vim easy-grep
" map <silent> <Leader>vo <plug>EgMapGrepOptions
map <silent> <Leader>vv <plug>EgMapGrepCurrentWord_v
vmap <silent> <Leader>vv <plug>EgMapGrepSelection_v
map <silent> <Leader>vV <plug>EgMapGrepCurrentWord_V
vmap <silent> <Leader>vV <plug>EgMapGrepSelection_V
map <silent> <Leader>va <plug>EgMapGrepCurrentWord_a
vmap <silent> <Leader>va <plug>EgMapGrepSelection_a
map <silent> <Leader>vA <plug>EgMapGrepCurrentWord_A
vmap <silent> <Leader>vA <plug>EgMapGrepSelection_A
map <silent> <Leader>vr <plug>EgMapReplaceCurrentWord_r
vmap <silent> <Leader>vr <plug>EgMapReplaceSelection_r
map <silent> <Leader>vR <plug>EgMapReplaceCurrentWord_R
vmap <silent> <Leader>vR <plug>EgMapReplaceSelection_R

" QuickFix can open the current line with :.cc

" Ale
nmap <silent> <Leader>ek <Plug>(ale_previous_wrap)
nmap <silent> <Leader>ej <Plug>(ale_next_wrap)

" Avante
" " other customize shortcut
nmap <silent> <Leader>aC :AvanteClear<CR>
nmap <silent> <Leader>ab :AvanteBuild<CR>
nmap <silent> <Leader>am :AvanteModels<CR>
nmap <silent> <Leader>an :AvanteChatNew<CR>

" Patch
"""""""""""""""""""""""""""""""""""""""""""""""""""""

" Enable Alt Keys
" for i in range(97,122)
"     let c = nr2char(i)
"     exec "map \e".c." <M-".c.">"
"     exec "map! \e".c." <M-".c.">"
" endfor
" No Ctrl Key Patch
" nmap <A-t> <Esc>:pop<CR>
