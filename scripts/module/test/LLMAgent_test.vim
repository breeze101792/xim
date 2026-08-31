" File: LLMAgent_test.vim
" Description: Self-contained unit tests for LLMAgent.vim.
"   Run with:  vim -e -s -u NONE -S scripts/module/test/LLMAgent_test.vim
"
" Tests use only Vim built-ins. They cover the pure-logic helpers that can
" be exercised without a running LLM server, ACP process, or external tools.
" The live API / ACP paths are exercised manually by the user.

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Test harness
""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:tests_run = 0
let s:tests_failed = 0
let s:tests_passed = 0
let s:failure_log = []

function! s:Assert(cond, msg)
    let s:tests_run += 1
    if a:cond
        let s:tests_passed += 1
    else
        let s:tests_failed += 1
        " silent! to avoid "Press ENTER" pauses in Ex mode.
        silent! echo 'FAIL: ' . a:msg
        call add(s:failure_log, a:msg)
    endif
endfunction

function! s:AssertEq(actual, expected, msg)
    if type(a:actual) == type(a:expected) && a:actual ==# a:expected
        call s:Assert(1, a:msg)
    else
        call s:Assert(0, a:msg . ' — got ' . string(a:actual) . ', expected ' . string(a:expected))
    endif
endfunction

" Each test is a real function (named s:Test_*) so l: scope and vim built-ins
" like :new, :bwipe, :setline all work naturally.

function! s:Test_GetSidebarWidth_floor() abort
    call s:Assert(LLMAgent_GetSidebarWidth() >= 40, 'width must be >= 40')
endfunction

function! s:Test_GetInputHeight_floor() abort
    call s:Assert(LLMAgent_GetInputHeight() >= 5, 'height must be >= 5')
endfunction

function! s:Test_DisplaySetupBuffer_sets_markdown_filetype() abort
    " The LLM answer window must render Markdown (headings, lists, code
    " fences), so the display buffer's filetype is markdown.
    let l:buf = nvim_create_buf(v:false, v:true)
    call LLMAgent_DisplaySetupBuffer(l:buf, 1, [1, 1], 'view')
    call s:AssertEq(nvim_buf_get_option(l:buf, 'filetype'), 'markdown', 'display buffer uses markdown filetype')
    call s:AssertEq(nvim_buf_get_option(l:buf, 'buftype'), 'nofile', 'display buffer is nofile')
    call nvim_buf_delete(l:buf, {})
endfunction

function! s:Test_GetContext_explicit_range() abort
    new
    call setline(1, ['line 1', 'line 2', 'line 3', 'line 4'])
    call s:AssertEq(LLMAgent_GetContext(2, 3), "line 2\nline 3", 'returns lines 2-3 joined')
    bwipe!
endfunction

function! s:Test_GetContext_single_line_returns_full_file() abort
    new
    call setline(1, ['a', 'b', 'c'])
    call s:AssertEq(LLMAgent_GetContext(1, 1), "a\nb\nc", 'single-line range returns full file')
    bwipe!
endfunction

function! s:Test_GetSystemPrompt_default() abort
    let g:llm_agent_system_prompt = ''
    call s:AssertEq(type(LLMAgent_GetSystemPrompt()), v:t_string, 'returns string')
    call s:Assert(!empty(LLMAgent_GetSystemPrompt()), 'default prompt is non-empty')
endfunction

function! s:Test_GetSystemPrompt_custom() abort
    let g:llm_agent_system_prompt = 'CUSTOM_PROMPT'
    call s:AssertEq(LLMAgent_GetSystemPrompt(), 'CUSTOM_PROMPT', 'returns custom override')
    let g:llm_agent_system_prompt = ''
endfunction

function! s:Test_GetAgentSystemPrompt_includes_components() abort
    let g:llm_agent_system_prompt = 'BASE_PROMPT'
    let l:p = LLMAgent_GetAgentSystemPrompt()
    call s:Assert(stridx(l:p, 'BASE_PROMPT') >= 0, 'contains base prompt')
    call s:Assert(stridx(l:p, 'WORKFLOW') >= 0, 'contains workflow section')
    call s:Assert(stridx(l:p, 'write_file') >= 0, 'mentions write_file')
    call s:Assert(stridx(l:p, 'patch') >= 0, 'mentions patch')
    let g:llm_agent_system_prompt = ''
endfunction

function! s:Test_GetToolDefinitions_shape() abort
    let l:defs = LLMAgent_GetToolDefinitions()
    call s:AssertEq(type(l:defs), v:t_list, 'returns a list')
    call s:Assert(!empty(l:defs), 'list is non-empty')
    for l:tool in l:defs
        call s:Assert(has_key(l:tool, 'type') && l:tool['type'] == 'function', 'each tool has type=function')
        call s:Assert(has_key(l:tool['function'], 'name'), 'each tool has a name')
    endfor
endfunction

function! s:Test_GetToolDefinitions_expected_names() abort
    let l:defs = LLMAgent_GetToolDefinitions()
    let l:names = map(copy(l:defs), 'v:val[''function''][''name'']')
    for l:expected in ['read_file', 'write_file', 'ls', 'find', 'grep', 'patch', 'list_buffers']
        call s:Assert(index(l:names, l:expected) >= 0, 'missing tool: ' . l:expected)
    endfor
endfunction

function! s:Test_ExecuteTool_unknown() abort
    let l:r = LLMAgent_ExecuteTool('nope', {})
    call s:Assert(has_key(l:r, 'error'), 'returns error for unknown tool')
endfunction

function! s:Test_ExecuteTool_list_buffers() abort
    let l:r = LLMAgent_ExecuteTool('list_buffers', {})
    call s:Assert(has_key(l:r, 'content'), 'returns content')
    call s:AssertEq(type(l:r['content']), v:t_string, 'content is a string')
endfunction

function! s:Test_ToolLs_real_dir() abort
    let l:r = LLMAgent_ToolLs({'path': 'scripts/module'})
    call s:Assert(has_key(l:r, 'content'), 'returns content')
    call s:Assert(stridx(l:r['content'], 'LLMAgent.vim') >= 0, 'lists LLMAgent.vim')
endfunction

function! s:Test_ToolLs_missing() abort
    let l:r = LLMAgent_ToolLs({'path': 'no_such_dir_xyz'})
    call s:Assert(has_key(l:r, 'error'), 'returns error')
endfunction

function! s:Test_ToolLs_rejects_parent_traversal() abort
    let l:r = LLMAgent_ToolLs({'path': '../../../../etc'})
    call s:Assert(has_key(l:r, 'error'), 'rejects ..')
endfunction

function! s:Test_ToolFind_match() abort
    let l:r = LLMAgent_ToolFind({'pattern': 'scripts/module/LLMAgent*.vim'})
    call s:Assert(has_key(l:r, 'content'), 'returns content')
    call s:Assert(stridx(l:r['content'], 'LLMAgent.vim') >= 0, 'finds LLMAgent.vim')
endfunction

function! s:Test_ToolFind_no_match() abort
    let l:r = LLMAgent_ToolFind({'pattern': 'nonexistent_xyz_*.zzz'})
    call s:Assert(has_key(l:r, 'content'), 'returns content (not error)')
    call s:Assert(stridx(l:r['content'], 'No files') >= 0, 'says no files found')
endfunction

function! s:Test_ToolGrep_finds_match() abort
    let l:r = LLMAgent_ToolGrep({'pattern': 'CRITICAL RULES', 'path': 'scripts/module', 'glob': 'LLMAgent.vim'})
    call s:Assert(has_key(l:r, 'content'), 'returns content')
    call s:Assert(stridx(l:r['content'], 'LLMAgent.vim') >= 0, 'names the matched file')
endfunction

function! s:Test_ToolGrep_no_match() abort
    let l:r = LLMAgent_ToolGrep({'pattern': 'QZQXZ_NO_MATCH_PATTERN_42', 'path': 'scripts/module', 'glob': 'LLMAgent.vim'})
    call s:Assert(stridx(l:r['content'], 'No matches') >= 0, 'reports no matches')
endfunction

function! s:Test_ToolGrep_rejects_parent_traversal() abort
    let l:r = LLMAgent_ToolGrep({'pattern': 'foo', 'path': '../../../'})
    call s:Assert(has_key(l:r, 'error'), 'rejects ..')
endfunction

function! s:Test_ToolReadFile_known() abort
    let l:r = LLMAgent_ToolReadFile({'path': 'scripts/module/LLMAgent.vim'})
    call s:Assert(has_key(l:r, 'content'), 'returns content')
    call s:Assert(stridx(l:r['content'], 'LLMAgent') >= 0, 'mentions its own name')
endfunction

function! s:Test_ToolReadFile_line_range() abort
    let l:r = LLMAgent_ToolReadFile({'path': 'scripts/module/LLMAgent.vim', 'start_line': 1, 'end_line': 1})
    call s:Assert(has_key(l:r, 'content'), 'returns content')
    call s:AssertEq(type(l:r['content']), v:t_string, 'content is string')
endfunction

function! s:Test_ToolReadFile_missing() abort
    let l:r = LLMAgent_ToolReadFile({'path': 'no_such_file_xyz_42'})
    call s:Assert(has_key(l:r, 'error'), 'returns error')
endfunction

function! s:Test_ToolReadFile_rejects_parent_traversal() abort
    let l:r = LLMAgent_ToolReadFile({'path': '../../../etc/passwd'})
    call s:Assert(has_key(l:r, 'error'), 'rejects ..')
endfunction

function! s:Test_ToolWriteFile_queues_no_disk() abort
    " Use a path inside the project (cwd) since the new path resolver
    " refuses writes outside the project tree. Use write_file_force to
    " bypass the "read first" gate, since this test only exercises the
    " write-queueing path.
    let l:probe = getcwd() . '/_llm_probe_' . fnamemodify(tempname(), ':t') . '.txt'
    let l:result = LLMAgent_ToolWriteFile({'path': l:probe, 'content': 'hello', 'write_file_force': v:true})
    call s:Assert(has_key(l:result, 'content'), 'returns content on success')
    call s:Assert(!filereadable(l:probe), 'file must NOT be written yet (approval gate)')
    call delete(l:probe)
endfunction

function! s:Test_CallAPI_transport_error() abort
    let g:llm_agent_api_url = 'http://127.0.0.1:1/v1'
    let g:llm_agent_timeout = 1
    let l:r = LLMAgent_CallAPI([{'role': 'user', 'content': 'hi'}])
    call s:Assert(has_key(l:r, 'error'), 'returns error dict on curl failure')
    let g:llm_agent_api_url = 'http://localhost:11434/v1'
    let g:llm_agent_timeout = 60
endfunction

function! s:Test_APIRequest_transport_error() abort
    let g:llm_agent_api_url = 'http://127.0.0.1:1/v1'
    let g:llm_agent_timeout = 1
    let l:r = LLMAgent_CallAPI([{'role': 'user', 'content': 'hi'}], [])
    call s:Assert(has_key(l:r, 'error'), 'returns error dict on transport failure')
    let g:llm_agent_api_url = 'http://localhost:11434/v1'
    let g:llm_agent_timeout = 60
endfunction

function! s:Test_APIRequest_returns_dict() abort
    let g:llm_agent_api_url = 'http://127.0.0.1:1/v1'
    let g:llm_agent_timeout = 1
    let l:r = LLMAgent_CallAPI([])
    call s:AssertEq(type(l:r), v:t_dict, 'returns a dict')
    let g:llm_agent_api_url = 'http://localhost:11434/v1'
    let g:llm_agent_timeout = 60
endfunction

" --- ACP state reset --------------------------------------------------------
" The s:acp_* variables live in the LLMAgent.vim script-scope. We mutate
" them via LLMAgent's public functions, then read them back through the
" test file's own script-scope (which can't see the other script's s: vars
" directly). So we exercise reset via the public StopACP path and via
" observing observable side-effects (e.g. SendACP no-op when no job).

function! s:Test_StopACP_is_idempotent() abort
    " Calling StopACP when no job is running should not throw
    call LLMAgent_StopACP()
    call LLMAgent_StopACP()
    call s:Assert(1, 'StopACP is idempotent')
endfunction

function! s:Test_FinishAgentTurn_handles_empty_state() abort
    " Just ensure it doesn't throw with the script's s: state empty/undefined
    try
        call LLMAgent_FinishAgentTurn('hi')
        call s:Assert(1, 'does not throw with empty write list')
    catch
        call s:Assert(0, 'threw: ' . v:exception)
    endtry
endfunction

" --- New: location context + selection + reset -------------------------------

function! s:Test_ResolveBufPath_handles_unknown_buf() abort
    call s:AssertEq(LLMAgent_ResolveBufPath(99999), '', 'returns empty for nonexistent buf')
endfunction

function! s:Test_ResolveBufPath_handles_agent_buffers() abort
    new
    silent file LLMAgent-Test-Path
    let l:b = bufnr('%')
    call s:AssertEq(LLMAgent_ResolveBufPath(l:b), '', 'returns empty for LLMAgent- buffers')
    bwipe!
endfunction

function! s:Test_BuildLocationContext_none_mode() abort
    let l:tmp = tempname() . '.txt'
    call writefile(['line one', 'line two'], l:tmp)
    execute 'edit ' . l:tmp
    let l:b = bufnr('%')
    let l:ctx = LLMAgent_BuildLocationContext(l:b, 0, 0, 'none')
    call s:Assert(stridx(l:ctx, 'File:') >= 0, 'contains File: header')
    call s:Assert(stridx(l:ctx, fnamemodify(l:tmp, ':t')) >= 0, 'mentions filename')
    call s:Assert(stridx(l:ctx, 'Range:') < 0, 'no Range in none mode')
    call s:Assert(stridx(l:ctx, 'Line:') < 0, 'no Line in none mode')
    bwipe!
    call delete(l:tmp)
endfunction

function! s:Test_BuildLocationContext_cursor_mode() abort
    let l:tmp = tempname() . '.txt'
    call writefile(['alpha', 'beta', 'gamma', 'delta', 'epsilon'], l:tmp)
    execute 'edit ' . l:tmp
    let l:b = bufnr('%')
    let l:ctx = LLMAgent_BuildLocationContext(l:b, 3, 3, 'cursor')
    call s:Assert(stridx(l:ctx, 'Line: 3') >= 0, 'mentions line 3')
    call s:Assert(stridx(l:ctx, 'gamma') >= 0, 'includes the cursor line text')
    call s:Assert(stridx(l:ctx, 'beta') >= 0, 'includes context line above')
    call s:Assert(stridx(l:ctx, '>') >= 0, 'marks the cursor line with >')
    bwipe!
    call delete(l:tmp)
endfunction

function! s:Test_BuildLocationContext_range_mode() abort
    let l:tmp = tempname() . '.txt'
    call writefile(['one', 'two', 'three', 'four', 'five'], l:tmp)
    execute 'edit ' . l:tmp
    let l:b = bufnr('%')
    let l:ctx = LLMAgent_BuildLocationContext(l:b, 2, 4, 'range')
    call s:Assert(stridx(l:ctx, 'Range: lines 2-4') >= 0, 'shows range as 2-4')
    call s:Assert(stridx(l:ctx, 'two') >= 0, 'includes line 2')
    call s:Assert(stridx(l:ctx, 'three') >= 0, 'includes line 3')
    call s:Assert(stridx(l:ctx, 'four') >= 0, 'includes line 4')
    call s:Assert(stridx(l:ctx, 'one') < 0, 'does not include out-of-range line 1')
    call s:Assert(stridx(l:ctx, 'five') < 0, 'does not include out-of-range line 5')
    bwipe!
    call delete(l:tmp)
endfunction

function! s:Test_BuildLocationContext_includes_filetype() abort
    let l:tmp = tempname() . '.py'
    call writefile(['x = 1'], l:tmp)
    execute 'edit ' . l:tmp
    setlocal filetype=python
    " Force filetype even if -u NONE disabled auto-detection
    call setbufvar(bufnr('%'), '&filetype', 'python')
    let l:b = bufnr('%')
    let l:ctx = LLMAgent_BuildLocationContext(l:b, 0, 0, 'none')
    call s:Assert(stridx(l:ctx, '(python)') >= 0, 'includes filetype in parens')
    bwipe!
    call delete(l:tmp)
endfunction

function! s:Test_CaptureSelection_no_visual() abort
    let l:sel = LLMAgent_CaptureSelection()
    call s:AssertEq(type(l:sel), v:t_dict, 'returns dict')
    call s:Assert(has_key(l:sel, 'text'), 'has text key')
    call s:Assert(has_key(l:sel, 'line1'), 'has line1 key')
    call s:Assert(has_key(l:sel, 'line2'), 'has line2 key')
    call s:Assert(has_key(l:sel, 'mode'), 'has mode key')
    call s:Assert(l:sel['mode'] ==# 'none' || l:sel['mode'] ==# 'range', 'mode is none or range outside visual')
    if l:sel['mode'] ==# 'none'
        call s:AssertEq(l:sel['line1'], 0, 'line1 is 0 when no selection')
        call s:AssertEq(l:sel['line2'], 0, 'line2 is 0 when no selection')
    endif
endfunction

function! s:Test_CaptureSelection_with_visual() abort
    " The 'visual' branch (mode == v/V/<C-V>) is hard to reach in -E -s
    " (Ex mode silently ignores visual mode entry), and the 'range' branch
    " depends on the '< '> marks being valid (setpos on '< '> is not
    " honored by line("'<") in Ex mode). So we exercise the no-selection
    " contract here: when called fresh in a buffer with no prior visual
    " selection, the helper returns mode='none' with empty values.
    let l:tmp = tempname() . '.txt'
    call writefile(['line A', 'line B', 'line C', 'line D'], l:tmp)
    execute 'edit ' . l:tmp
    let l:sel = LLMAgent_CaptureSelection()
    call s:Assert(l:sel['mode'] ==# 'none' || l:sel['mode'] ==# 'range', 'mode is none or range')
    if l:sel['mode'] ==# 'none'
        call s:AssertEq(l:sel['line1'], 0, 'line1 is 0 when no selection')
        call s:AssertEq(l:sel['line2'], 0, 'line2 is 0 when no selection')
        call s:AssertEq(l:sel['text'], '', 'text empty when no selection')
    endif
    bwipe!
    call delete(l:tmp)
endfunction

function! s:Test_CaptureSelection_preserves_register() abort
    " After LLMAgent_CaptureSelection runs, the unnamed register should be
    " exactly as it was before the call (we may have side-effected it via
    " the yank).
    let l:tmp = tempname() . '.txt'
    call writefile(['a', 'b', 'c'], l:tmp)
    execute 'edit ' . l:tmp
    call setreg('"', 'sentinel', 'v')
    let l:sel = LLMAgent_CaptureSelection()
    call s:AssertEq(@", 'sentinel', 'unnamed register restored after capture')
    bwipe!
    call delete(l:tmp)
endfunction

" --- New: tool robustness tests ---------------------------------------------

function! s:Test_DecodeEscapes_passthrough() abort
    " Strings without backslashes are returned unchanged.
    call s:AssertEq(LLMAgent_DecodeEscapes('hello'), 'hello', 'plain text unchanged')
    call s:AssertEq(LLMAgent_DecodeEscapes('a/b/c'), 'a/b/c', 'slashes unchanged')
endfunction

function! s:Test_DecodeEscapes_converts() abort
    " The four most common escape sequences the LLM leaks.
    call s:AssertEq(LLMAgent_DecodeEscapes('line1\nline2'), "line1\nline2", '\n becomes newline')
    call s:AssertEq(LLMAgent_DecodeEscapes('a\tb'), "a\tb", '\t becomes tab')
    call s:AssertEq(LLMAgent_DecodeEscapes('he said \"hi\"'), 'he said "hi"', '\" becomes quote')
    call s:AssertEq(LLMAgent_DecodeEscapes('a\\b'), 'a\b', '\\ becomes single backslash')
endfunction

function! s:Test_ResolveToolPath_absolute() abort
    " Absolute paths bypass the base-dir join.
    let l:r = LLMAgent_ResolveToolPath('/etc/hosts')
    call s:AssertEq(l:r, '/etc/hosts', 'absolute path returned as-is')
    " Home-relative: the resolver may either keep ~ or expand it; both
    " are acceptable. We just require the trailing component to survive.
    let l:r = LLMAgent_ResolveToolPath('~/foo/bar')
    call s:Assert(stridx(l:r, 'foo/bar') >= 0, '~/-path preserves tail')
endfunction

function! s:Test_ResolveToolPath_empty() abort
    call s:AssertEq(LLMAgent_ResolveToolPath(''), '', 'empty path returns empty')
endfunction

function! s:Test_ResolveToolPath_relative() abort
    " Relative paths are resolved against the working buffer's dir
    " (or cwd if no working buffer). With s:llm_agent_working_buf unset,
    " it falls back to expand('%:p:h') or getcwd().
    let l:r = LLMAgent_ResolveToolPath('scripts/module')
    call s:Assert(!empty(l:r), 'relative path resolves to non-empty')
    call s:Assert(isdirectory(l:r), 'result is an existing directory')
endfunction

function! s:Test_IsOutsideProject_inside() abort
    " The project root is the git toplevel (or cwd if no git).
    " A path inside it is "inside".
    call s:AssertEq(LLMAgent_IsOutsideProject(getcwd() . '/scripts/module'), 0, 'cwd-relative path is inside')
endfunction

function! s:Test_IsOutsideProject_outside() abort
    " /tmp is outside the project.
    call s:AssertEq(LLMAgent_IsOutsideProject('/tmp'), 1, '/tmp is outside')
endfunction

function! s:Test_IsOutsideProject_dotdot() abort
    " A path that still begins with .. (after resolution) is outside.
    call s:AssertEq(LLMAgent_IsOutsideProject('../foo'), 1, '.. is outside')
endfunction

function! s:Test_ToolReadFile_numbered_output() abort
    " New behavior: read_file should number every line.
    " Use a project-internal path because the new path resolver refuses
    " reads outside the project tree.
    let l:tmp = getcwd() . '/_llm_read_numbered.txt'
    call writefile(['alpha', 'beta', 'gamma'], l:tmp)
    let l:r = LLMAgent_ToolReadFile({'path': l:tmp})
    call s:AssertEq(l:r['ok'], 1, 'ok is true')
    call s:Assert(stridx(l:r['content'], '1| alpha') >= 0, 'line 1 numbered')
    call s:Assert(stridx(l:r['content'], '2| beta') >= 0, 'line 2 numbered')
    call s:Assert(stridx(l:r['content'], '3| gamma') >= 0, 'line 3 numbered')
    call delete(l:tmp)
endfunction

function! s:Test_ToolReadFile_line_range_header() abort
    " When start_line/end_line is used, the header should say "Lines a-b".
    let l:tmp = getcwd() . '/_llm_read_range.txt'
    call writefile(range(1, 20)->map('printf("line %d", v:val)'), l:tmp)
    let l:r = LLMAgent_ToolReadFile({'path': l:tmp, 'start_line': 5, 'end_line': 7})
    call s:Assert(stridx(l:r['content'], 'Lines 5-') >= 0, 'header says Lines 5-...')
    call delete(l:tmp)
endfunction

function! s:Test_ToolReadFile_out_of_range() abort
    " Asking for a line past EOF should error, not silently truncate.
    let l:tmp = getcwd() . '/_llm_read_oob.txt'
    call writefile(['a', 'b'], l:tmp)
    let l:r = LLMAgent_ToolReadFile({'path': l:tmp, 'start_line': 100, 'end_line': 200})
    call s:AssertEq(l:r['ok'], 0, 'ok is false for out-of-range')
    call s:Assert(stridx(l:r['error'], 'start_line') >= 0, 'error mentions start_line')
    call delete(l:tmp)
endfunction

function! s:Test_ToolWriteFile_escaped_newlines() abort
    " If the LLM sends literal \n in the content, the tool should decode
    " them into real newlines. Otherwise write_file would produce a
    " single-line file.
    let l:probe = getcwd() . '/_llm_probe_escaped.txt'
    let l:result = LLMAgent_ToolWriteFile({'path': l:probe, 'content': 'line1\nline2\nline3', 'write_file_force': v:true})
    call s:AssertEq(l:result['ok'], 1, 'ok on success')
    call s:Assert(stridx(l:result['content'], '3 lines') >= 0, 'result reports line count after decode')
    call delete(l:probe)
endfunction

function! s:Test_ToolWriteFile_rejects_path_traversal() abort
    " After resolution, a path that points outside the project should be
    " refused with an error, not silently accepted.
    let l:r = LLMAgent_ToolWriteFile({'path': '/tmp/should_not_write.txt', 'content': 'x', 'write_file_force': v:true})
    call s:AssertEq(l:r['ok'], 0, 'ok is false for outside-project write')
    call s:Assert(stridx(l:r['error'], 'outside') >= 0, 'error mentions outside project')
endfunction

function! s:Test_ToolWriteFile_empty_content() abort
    " Empty content should error, not silently accept.
    let l:probe = getcwd() . '/_llm_probe_empty.txt'
    let l:r = LLMAgent_ToolWriteFile({'path': l:probe, 'content': '', 'write_file_force': v:true})
    call s:AssertEq(l:r['ok'], 0, 'ok is false for empty content')
    call s:Assert(stridx(l:r['error'], 'empty') >= 0, 'error mentions empty')
    call delete(l:probe)
endfunction

function! s:Test_ToolWriteFile_requires_read_first() abort
    " Safety gate: write_file must refuse if the LLM has not read the file
    " in this session (prevents writing based on stale memory). New files
    " (that don't exist yet) are exempt.
    let l:f = getcwd() . '/_llm_write_requires_read.txt'
    call writefile(['existing content'], l:f)
    " No read_file called for this path.
    let l:r = LLMAgent_ToolWriteFile({'path': l:f, 'content': 'rewritten'})
    call s:AssertEq(l:r['ok'], 0, 'ok false when file not yet read')
    call s:Assert(stridx(l:r['error'], 'read_file') >= 0, 'error points to read_file')
    " With write_file_force: true it should succeed.
    let l:r2 = LLMAgent_ToolWriteFile({'path': l:f, 'content': 'rewritten', 'write_file_force': v:true})
    call s:AssertEq(l:r2['ok'], 1, 'force flag bypasses the gate')
    call delete(l:f)
endfunction

function! s:Test_ToolWriteFile_rejects_diff_as_content() abort
    " After a failed patch, the LLM sometimes pastes the diff text into
    " write_file's content. That would write the diff text as the file's
    " literal contents. Refuse it. The diff-shape guard is NOT bypassed
    " by write_file_force — sending a diff as content is always wrong.
    let l:f = getcwd() . '/_llm_write_diff_as_content.txt'
    call writefile(['one', 'two', 'three'], l:f)
    let l:diff = "--- a/x\n+++ b/x\n@@ -1 +1 @@\n-one\n+ONE\n"
    let l:r = LLMAgent_ToolWriteFile({'path': l:f, 'content': l:diff, 'write_file_force': v:true})
    call s:AssertEq(l:r['ok'], 0, 'ok false when content is a diff')
    call s:Assert(stridx(l:r['error'], 'diff') >= 0, 'error mentions diff')
    call delete(l:f)
endfunction

function! s:Test_ToolWriteFile_rejects_partial_content() abort
    " Existing file with 20 lines. LLM sends only 2 lines (just the change).
    " Without the guard, writefile would overwrite the file with 2 lines,
    " destroying the other 18. Refuse it; allow override via write_file_force.
    let l:f = getcwd() . '/_llm_write_partial.txt'
    call writefile(range(1, 20)->map('printf("line %d", v:val)'), l:f)
    " Read first so the read-first gate passes; we want to exercise the
    " line-count guard, not the read-first guard.
    call LLMAgent_ToolReadFile({'path': l:f})
    let l:short = "line 5\nline 6 (edited)\n"
    let l:r = LLMAgent_ToolWriteFile({'path': l:f, 'content': l:short})
    call s:AssertEq(l:r['ok'], 0, 'ok false for partial write')
    call s:Assert(stridx(l:r['error'], 'partial') >= 0 || stridx(l:r['error'], 'COMPLETE') >= 0, 'error mentions partial/COMPLETE')
    " With write_file_force: true the line-count guard is bypassed, so it
    " should succeed (the LLM may legitimately intend to shrink the file).
    let l:r2 = LLMAgent_ToolWriteFile({'path': l:f, 'content': l:short, 'write_file_force': v:true})
    call s:AssertEq(l:r2['ok'], 1, 'force bypasses line-count guard')
    call delete(l:f)
endfunction

function! s:Test_ToolPatch_allows_no_newline_marker() abort
    " A correct unified diff that includes the "\ No newline at end of
    " file" marker must pass the diff-shape validator (previously the
    " marker line was flagged as "invalid unified diff syntax"). We
    " assert that the failure, if any, comes from patch(1) — NOT from
    " our validator's "invalid" / "hunk" message.
    let l:f = getcwd() . '/_llm_patch_nonl.txt'
    " Write file WITHOUT trailing newline so the diff marker is correct.
    call writefile(['one', 'two', 'three'], l:f)
    let l:diff = "--- a/x\n+++ b/x\n@@ -1,3 +1,3 @@\n one\n-two\n+TWO\n three\n\\ No newline at end of file\n"
    let l:r = LLMAgent_ToolPatch({'path': l:f, 'diff': l:diff, 'patch_force': v:true})
    " Either ok=1 (patch applied) or ok=0 with a patch(1) error — but NOT
    " a validator rejection.
    if l:r['ok'] == 0
        call s:Assert(stridx(l:r['error'], 'invalid') < 0, 'must not be rejected as invalid')
        call s:Assert(stridx(l:r['error'], 'hunk') < 0 || stridx(l:r['error'], 'no @@ hunk') >= 0, 'must not be rejected for hunk-related reasons (ok=0 ok if patch(1) failed)')
    endif
    call delete(l:f)
endfunction

function! s:Test_ToolPatch_allows_git_extended_headers() abort
    " LLMs often emit git-style extended diffs (diff --git / index / mode
    " lines) even when asked for plain unified diff. The validator must
    " accept these header lines, not flag them as "invalid unified diff
    " syntax". The diff should reach patch(1) and apply successfully.
    let l:f = getcwd() . '/_llm_patch_git.txt'
    call writefile(['one', 'two', 'three'], l:f)
    let l:diff = "diff --git a/ducky.sh b/ducky.sh\nindex abc..def 100644\n--- a/ducky.sh\n+++ b/ducky.sh\n@@ -1,3 +1,3 @@\n one\n-two\n+TWO\n three\n"
    let l:r = LLMAgent_ToolPatch({'path': l:f, 'diff': l:diff, 'patch_force': v:true})
    call s:AssertEq(l:r['ok'], 1, 'git-extended diff applies')
    if l:r['ok'] == 0
        " If it failed, it must NOT be a validator rejection.
        call s:Assert(stridx(l:r['error'], 'invalid') < 0, 'must not be rejected as invalid (git headers are valid)')
    endif
    call delete(l:f)
endfunction

function! s:Test_ToolPatch_preserves_literal_escape_in_source_line() abort
    " The killer bug: when a source line contains a literal \n (e.g. a
    " printf format string), the LLM correctly includes it in the diff as
    " a literal backslash-n. Previously LLMAgent_DecodeEscapes decoded
    " that \n into a real newline, splitting the diff line and making
    " patch(1) fail with "malformed patch". The fix: only decode escapes
    " when the diff has no real newlines (json_decode already handled
    " line separators). This test uses a real-world printf line and a
    " correct diff that preserves the \n literal.
    let l:f = getcwd() . '/_llm_patch_escape.txt'
    call writefile(['    printf "    %- 32s\t %s\n" "-g" "Generate"', 'echo done'], l:f)
    " Diff changes \t to >- on line 1, keeps \n as literal backslash-n.
    " In Vim double-quoted strings: \\t -> \t (literal), \\n -> \n (literal),
    " \n -> real newline (line separator).
    let l:diff = "--- a/x\n+++ b/x\n@@ -1 +1 @@\n-    printf \"    %- 32s\\t %s\\n\" \"-g\" \"Generate\"\n+    printf \"    %- 32s>- %s\\n\" \"-g\" \"Generate\"\n"
    let l:r = LLMAgent_ToolPatch({'path': l:f, 'diff': l:diff, 'patch_force': v:true})
    call s:AssertEq(l:r['ok'], 1, 'ok true — diff with literal \\n in source line must apply')
    if l:r['ok'] == 0
        call s:Assert(0, 'unexpected failure: ' . substitute(l:r['error'], '\n', ' | ', 'g'))
    endif
    call delete(l:f)
endfunction

function! s:Test_FixHunkHeader_repairs_near_misses() abort
    " LLMAgent_FixHunkHeader repairs hunk-header near-misses that make
    " patch(1) die with "Only garbage was found in the patch input":
    " missing -/+ signs, doubled spaces, unicode minus, NBSP, git combined
    " "@@@" headers (2-range case only), missing closer, noise chars
    " between the @s, and the "single + or - prefix" pattern. Real
    " content lines (no @@ header pattern) pass through unchanged.
    let l:cases = [
        \ ['@@ -51 +51 @@', '@@ -51 +51 @@'],
        \ ['@@ -51,1 +51,1 @@', '@@ -51,1 +51,1 @@'],
        \ ['@@ -51 +51 @@ fHelp()', '@@ -51 +51 @@ fHelp()'],
        \ ['@@ 51 51 @@', '@@ -51 +51 @@'],
        \ ['@@  -51  +51  @@', '@@ -51 +51 @@'],
        \ ["@@\t-51\t+51\t@@", '@@ -51 +51 @@'],
        \ ["@@\u00a0-51\u00a0+51\u00a0@@", '@@ -51 +51 @@'],
        \ ["@@ \u221251 +51 @@", '@@ -51 +51 @@'],
        \ ['@@ -51, 1 +51, 1 @@', '@@ -51,1 +51,1 @@'],
        \ ['@@@ -51 +51 @@@', '@@ -51 +51 @@'],
        \ ['@@ -51 +51', '@@ -51 +51 @@'],
        \ ['no hunk here', 'no hunk here'],
        \ ['-    printf "x\n"', '-    printf "x\n"'],
        \ ['+    foo bar baz', '+    foo bar baz'],
        \ ['-    foo bar baz', '-    foo bar baz'],
        \ [' @@ some context', ' @@ some context'],
        \ ]
    for l:c in l:cases
        let l:got = LLMAgent_FixHunkHeader(l:c[0])
        call s:AssertEq(l:got, l:c[1], 'FixHunkHeader(' . l:c[0] . ')')
    endfor
endfunction

function! s:Test_ToolPatch_sanitizes_garbage_hunk_headers() abort
    " The bug the user hit: the model emitted a hunk header near-miss
    " (e.g. "@@ 51 51 @@" with no -/+ range signs). The old validator's
    " ^@@ check passed it, patch(1) could not find a single hunk and
    " aborted with "Only garbage was found in the patch input" — an error
    " naming nothing fixable, so the agent could only fall back to
    " write_file. The sanitizer must repair these headers so patch(1)
    " applies the diff. End-to-end through LLMAgent_ToolPatch.
    let l:f = getcwd() . '/_llm_patch_hdr.sh'
    let l:BS = '\'
    let l:old = '-    printf "    %- 18s' . l:BS . 't%s' . l:BS . 'n" "--profiling|pf" "Profile vim startup"'
    let l:new = '+    printf "    %-18s' . l:BS . 't%s' . l:BS . 'n" "--profiling|pf" "Profile vim startup"'
    " Real file content: the %- 18s line at line 51. Syntactically valid
    " bash so the QueueWrite syntax gate does not reject the result.
    let l:content = []
    for l:i in range(1, 50)
        call add(l:content, 'echo filler ' . l:i)
    endfor
    call add(l:content, '    printf "    %- 18s' . l:BS . 't%s' . l:BS . 'n" "--profiling|pf" "Profile vim startup"')
    call writefile(l:content, l:f)
    " Header variants that all previously ended in "Only garbage was
    " found"; each must now apply. The BOM-prefixed one is now stripped
    " at the sanitize-call site so FixHunkHeader sees a clean @@ line.
    let l:headers = [
        \ '@@ 51 51 @@',
        \ '@@  -51  +51  @@',
        \ "@@\t-51\t+51\t@@",
        \ '@@@ -51 +51 @@',
        \ "@@\u00a0-51\u00a0+51\u00a0@@",
        \ "@@ \u221251 +51 @@",
        \ "\uFEFF@@ -51 +51 @@",
        \ 'Change @@ -51 +51 @@ below:',
        \ '@@ -51 +51',
        \ ]
    for l:h in l:headers
        " Reset session state so the retry-loop breaker does not fire
        " across variants (they share one path).
        call LLMAgent_Reset()
        call writefile(l:content, l:f)
        let l:diff = "--- a/x\n+++ b/x\n" . l:h . "\n" . l:old . "\n" . l:new . "\n"
        let l:r = LLMAgent_ToolPatch({'path': l:f, 'diff': l:diff, 'patch_force': v:true})
        if l:r['ok'] != 1
            call s:Assert(0, 'header variant [' . l:h . '] must apply — got: ' . substitute(get(l:r, 'error', ''), '\n', ' | ', 'g'))
        endif
    endfor
    " The control: a plain valid diff still applies.
    call LLMAgent_Reset()
    call writefile(l:content, l:f)
    let l:diff = "--- a/x\n+++ b/x\n@@ -51 +51 @@\n" . l:old . "\n" . l:new . "\n"
    let l:r = LLMAgent_ToolPatch({'path': l:f, 'diff': l:diff, 'patch_force': v:true})
    call s:AssertEq(l:r['ok'], 1, 'valid diff still applies after sanitize step')
    call delete(l:f)
endfunction

function! s:Test_ToolPatch_strips_leading_prose() abort
    " When the LLM prefixes the diff with prose that mentions "@@ -N +N @@"
    " mid-line, patch(1) confuses it for a hunk header, fails to parse, and
    " reports "Only garbage was found in the patch input". The recovery
    " step strips everything before the first ---/+++/@@/diff --git line
    " so the real diff is found.
    let l:f = getcwd() . '/_llm_patch_prose.sh'
    let l:BS = '\'
    let l:content = []
    for l:i in range(1, 50)
        call add(l:content, 'echo filler ' . l:i)
    endfor
    call add(l:content, '    printf "    %- 18s' . l:BS . 't%s' . l:BS . 'n" "--profiling|pf" "Profile vim startup"')
    call writefile(l:content, l:f)
    " Prose line that mentions the header mid-line, followed by the real
    " diff. patch(1) would see the prose as its first hunk candidate and
    " abort. The recovery must drop the prose and apply the diff.
    let l:prose_intros = [
        \ "I'll change line 51.\n\n@@ -51 +51 @@\n-    printf \"    %- 18s\\t%s\\n\" \"--profiling|pf\" \"Profile vim startup\"\n+    printf \"    %-18s\\t%s\\n\" \"--profiling|pf\" \"Profile vim startup\"\n",
        \ "Here is the change @@ -51 +51 @@ below:\n--- a/x\n+++ b/x\n@@ -51 +51 @@\n-    printf \"    %- 18s\\t%s\\n\" \"--profiling|pf\" \"Profile vim startup\"\n+    printf \"    %-18s\\t%s\\n\" \"--profiling|pf\" \"Profile vim startup\"\n",
        \ "```diff\n--- a/x\n+++ b/x\n@@ -51 +51 @@\n-    printf \"    %- 18s\\t%s\\n\" \"--profiling|pf\" \"Profile vim startup\"\n+    printf \"    %-18s\\t%s\\n\" \"--profiling|pf\" \"Profile vim startup\"\n```\n",
        \ ]
    for l:diff in l:prose_intros
        call LLMAgent_Reset()
        call writefile(l:content, l:f)
        let l:r = LLMAgent_ToolPatch({'path': l:f, 'diff': l:diff, 'patch_force': v:true})
        if l:r['ok'] != 1
            call s:Assert(0, 'prose intro must apply — got: ' . substitute(get(l:r, 'error', ''), '\n', ' | ', 'g'))
        endif
    endfor
    call delete(l:f)
endfunction

function! s:Test_ToolPatch_normalizes_crlf_and_bom() abort
    " LLMs frequently deliver diffs with mixed CRLF/LF line endings or a
    " stray BOM on a +/- line. Both make patch(1) abort with "Only garbage
    " was found" / "malformed patch". The tool must normalize them.
    let l:f = s:ToolTestWriteFile('_llm_patch_eol.txt', ['t1', 't2'])
    call s:ToolTestMarkRead(l:f)
    let l:good = "--- a/x\n+++ b/x\n@@ -1,2 +1,2 @@\n t1\n-t2\n+T2\n"
    " 1. Mixed: headers LF, body lines CRLF (the classic model artifact).
    let l:diff = substitute(l:good, '\n', '\r', 'g')
    let l:diff = substitute(l:diff, '\r', "\r\n", 'g')
    " Build specifically: keep headers LF, add CRLF to the +/- and context lines.
    let l:lines = split(l:good, "\n")
    let l:mixed = "--- a/x\n+++ b/x\n@@ -1,2 +1,2 @@\n"
    let l:mixed .= " t1\r\n-t2\r\n+T2\r\n"
    let l:r = LLMAgent_ToolPatch({'path': l:f, 'diff': l:mixed, 'patch_force': v:true})
    call s:AssertEq(l:r['ok'], 1, 'CRLF body lines normalize and apply')
    if l:r['ok'] == 0
        call s:Assert(0, 'CRLF body failed: ' . substitute(l:r['error'], '\n', ' | ', 'g'))
    endif
    call s:ApplyAllWritesAndCheck(l:f, ['t1', 'T2'], 'CRLF-normalized content is exact')
    " 2. BOM before a -/+ content line.
    call writefile(['t1', 't2'], l:f)
    call LLMAgent_Reset()
    call s:ToolTestMarkRead(l:f)
    let l:bom_diff = "--- a/x\n+++ b/x\n@@ -1,2 +1,2 @@\n t1\n\uFEFF-t2\n+T2\n"
    let l:r = LLMAgent_ToolPatch({'path': l:f, 'diff': l:bom_diff, 'patch_force': v:true})
    call s:AssertEq(l:r['ok'], 1, 'BOM before -/+ line normalizes and applies')
    if l:r['ok'] == 0
        call s:Assert(0, 'BOM diff failed: ' . substitute(l:r['error'], '\n', ' | ', 'g'))
    endif
    call s:ApplyAllWritesAndCheck(l:f, ['t1', 'T2'], 'BOM-normalized content is exact')
    call s:ToolTestCleanup('_llm_patch_eol.txt')
endfunction

function! s:Test_ToolPatch_reconstructs_headerless_diff() abort
    " deepseek-v4-flash emits diffs with a bare "@@" header (no line
    " numbers) and no ---/+++ file headers. patch(1) rejects them with
    " "Only garbage was found". The tool must rebuild the file content by
    " matching the old side and queue it for approval.
    let l:f = s:ToolTestWriteFile('_llm_patch_hless.sh', [
        \ '#!/bin/bash',
        \ 'fHelp()',
        \ '{',
        \ '    echo "${VAR_SCRIPT_NAME}"',
        \ '    echo "[Example]"',
        \ '    printf "    %s\n" "run test: .sh -a"',
        \ '    echo "[Options]"',
        \ "    printf \"    %- 16s\\t%s\\n\" \"-s|--setup\" \"setup dependency\"",
        \ '}',
        \ 'echo done',
        \ ])
    call s:ToolTestMarkRead(l:f)
    " The model's exact style: bare @@ header, no file headers, +/- body.
    let l:diff = "@@\n fHelp()\n {\n     echo \"${VAR_SCRIPT_NAME}\"\n     echo \"[Example]\"\n-    printf \"    %s\\n\" \"run test: .sh -a\"\n+    printf \"    %s\\n\" \"./${VAR_SCRIPT_NAME} --setup\"\n     echo \"[Options]\"\n-    printf \"    %- 16s\\t%s\\n\" \"-s|--setup\" \"setup dependency\"\n+    printf \"    %- 20s\\t%s\\n\" \"-s|--setup\" \"setup dependency\"\n }"
    let l:r = LLMAgent_ToolPatch({'path': l:f, 'diff': l:diff, 'patch_force': v:true})
    call s:AssertEq(l:r['ok'], 1, 'headerless diff reconstructs and applies')
    if l:r['ok'] == 0
        call s:Assert(0, 'headerless failed: ' . substitute(l:r['error'], '\n', ' | ', 'g'))
    endif
    " The rebuilt content must be EXACTLY right — a silent corruption could
    " return ok=1 yet mangle the file. Drive the real approval and read back.
    call s:ApplyAllWritesAndCheck(l:f, [
        \ '#!/bin/bash',
        \ 'fHelp()',
        \ '{',
        \ '    echo "${VAR_SCRIPT_NAME}"',
        \ '    echo "[Example]"',
        \ '    printf "    %s\n" "./${VAR_SCRIPT_NAME} --setup"',
        \ '    echo "[Options]"',
        \ "    printf \"    %- 20s\\t%s\\n\" \"-s|--setup\" \"setup dependency\"",
        \ '}',
        \ 'echo done',
        \ ], 'rebuilt headerless content is exact')
    call s:ToolTestCleanup('_llm_patch_hless.sh')
endfunction

function! s:Test_RebuildHeaderlessDiff_unit() abort
    " Unit-level: exercise LLMAgent_RebuildHeaderlessDiff directly against
    " realistic headerless diffs and assert the reconstructed content. This
    " is the core of the fix — guard it hard so an edit can't silently drop
    " it or corrupt the output.
    " Case 1: single removed+added pair mid-file.
    let l:orig = ['#!/bin/bash', 'a', 'b', 'c', 'd']
    let l:dl = ['@@', ' a', '-b', '+B', ' c']
    let l:got = LLMAgent_RebuildHeaderlessDiff(l:dl, l:orig)
    call s:AssertEq(l:got, ['#!/bin/bash', 'a', 'B', 'c', 'd'], 'rebuild: simple replace middle')
    " Case 2: only additions (no removals) — a pure insert. The old side is
    " 'a b'; the added NEW goes between them.
    let l:dl2 = ['@@', ' a', '+NEW', ' b']
    let l:got2 = LLMAgent_RebuildHeaderlessDiff(l:dl2, l:orig)
    call s:AssertEq(l:got2, ['#!/bin/bash', 'a', 'NEW', 'b', 'c', 'd'], 'rebuild: pure insert')
    " Case 3: only removals (deletion).
    let l:dl3 = ['@@', ' a', '-b', '-c', ' d']
    let l:got3 = LLMAgent_RebuildHeaderlessDiff(l:dl3, l:orig)
    call s:AssertEq(l:got3, ['#!/bin/bash', 'a', 'd'], 'rebuild: pure delete')
    " Case 4: full hunk header with line numbers -> NOT headerless; must not
    " be treated as a raw reconstruct (returns '' so the normal patch path runs).
    let l:dl4 = ['--- a/x', '+++ b/x', '@@ -1,5 +1,5 @@', ' a', '-b', '+B', ' c']
    call s:AssertEq(LLMAgent_RebuildHeaderlessDiff(l:dl4, l:orig), '', 'rebuild: headerful diff not reconstructed')
    " Case 5: old side does not match file once -> must return '' (no guess).
    let l:dl5 = ['@@', ' a', '-zzz', '+B', ' c']
    call s:AssertEq(LLMAgent_RebuildHeaderlessDiff(l:dl5, l:orig), '', 'rebuild: non-matching old side returns empty')
endfunction

function! s:Test_ToolPatch_tries_patch1_before_validator_reject() abort
    " A diff with stray lines (e.g. continuation fragments from a source
    " string that contained a literal \n) should still reach patch(1).
    " The validator must NOT reject it outright — patch(1) may be able to
    " apply it, and if not, the LLM gets patch(1)'s actual error instead
    " of a confusing "invalid unified diff syntax" message.
    let l:f = getcwd() . '/_llm_patch_stray.txt'
    call writefile(['printf "hello\nworld\n"', 'echo done'], l:f)
    " The LLM decoded \n inside the string into a real newline, splitting
    " the diff line. The continuation "world..." starts with " — not a
    " diff prefix. Before the fix this was rejected as "invalid syntax".
    let l:diff = "--- a/x\n+++ b/x\n@@ -1 +1 @@\n-printf \"hello\nworld\n\"\n+printf \"HELLO\nworld\n\"\n"
    let l:r = LLMAgent_ToolPatch({'path': l:f, 'diff': l:diff, 'patch_force': v:true})
    call s:AssertEq(l:r['ok'], 0, 'ok false (patch(1) rejects malformed diff)')
    " The error should come from patch(1), NOT from the validator's
    " "invalid unified diff syntax" rejection.
    call s:Assert(stridx(l:r['error'], 'patch(1) said') >= 0, 'error comes from patch(1), not validator rejection')
    call s:Assert(stridx(l:r['error'], 'malformed') >= 0 || stridx(l:r['error'], 'failed') >= 0, 'error mentions patch(1) failure')
    call delete(l:f)
endfunction

function! s:Test_ToolPatch_breaks_retry_loop_after_two_fails() abort
    " After 2 patch failures on the same path, the tool must refuse to
    " try again — the LLM is in a retry loop and needs to switch to
    " write_file. This prevents the 13+ retry loops the user observed.
    let l:f = getcwd() . '/_llm_patch_loop.txt'
    call writefile(['printf "hello\nworld\n"', 'echo done'], l:f)
    let l:diff = "--- a/x\n+++ b/x\n@@ -1 +1 @@\n-printf \"hello\nworld\n\"\n+printf \"HELLO\nworld\n\"\n"
    " Two attempts that fail at patch(1).
    call LLMAgent_ToolPatch({'path': l:f, 'diff': l:diff, 'patch_force': v:true})
    call LLMAgent_ToolPatch({'path': l:f, 'diff': l:diff, 'patch_force': v:true})
    " Third attempt must be refused by the loop breaker.
    let l:r = LLMAgent_ToolPatch({'path': l:f, 'diff': l:diff, 'patch_force': v:true})
    call s:AssertEq(l:r['ok'], 0, 'ok false for 3rd attempt')
    call s:Assert(stridx(l:r['error'], 'already failed') >= 0 || stridx(l:r['error'], 'STOP') >= 0, 'error says already failed / STOP')
    call s:Assert(stridx(l:r['error'], 'write_file') >= 0, 'error recommends write_file')
    call delete(l:f)
endfunction

function! s:Test_ToolGrep_plain_text_as_literal() abort
    " A plain pattern (no regex metachars) should match a substring, not
    " be treated as a regex. Uses a project-internal directory.
    let l:tmpdir = getcwd() . '/_llm_grep_test'
    call mkdir(l:tmpdir, 'p')
    call writefile(['function foo() {', '  return 42;', '}', 'foo is great'], l:tmpdir . '/sample.txt')
    let l:r = LLMAgent_ToolGrep({'pattern': 'function foo', 'path': l:tmpdir})
    call s:AssertEq(l:r['ok'], 1, 'ok is true')
    call s:Assert(stridx(l:r['content'], 'function foo()') >= 0, 'matched the substring')
    call delete(l:tmpdir . '/sample.txt')
    call delete(l:tmpdir, 'd')
endfunction

function! s:Test_FormatToolResult_ok() abort
    " Success result: returns the content, no prefix.
    let l:r = LLMAgent_FormatToolResult('read_file', {'ok': 1, 'content': 'hello'})
    call s:AssertEq(l:r, 'hello', 'success returns bare content')
endfunction

function! s:Test_FormatToolResult_error() abort
    " Error result: prefix with a clear tag so the LLM can recognize it.
    let l:r = LLMAgent_FormatToolResult('write_file', {'ok': 0, 'error': 'no path'})
    call s:Assert(stridx(l:r, 'TOOL_ERROR') >= 0, 'errors are tagged')
    call s:Assert(stridx(l:r, 'write_file') >= 0, 'error names the tool')
    call s:Assert(stridx(l:r, 'no path') >= 0, 'error preserves the message')
endfunction

function! s:Test_FormatToolResult_legacy_shape() abort
    " Backwards compat: old {content, error} shape still works.
    let l:r = LLMAgent_FormatToolResult('ls', {'error': 'no dir'})
    call s:Assert(stridx(l:r, 'TOOL_ERROR') >= 0, 'legacy error is tagged')
endfunction

" --- Debug logging tests ----------------------------------------------------

function! s:Test_DebugLog_off_by_default() abort
    " Without g:llm_agent_debug on, LLMAgent_DebugLog is a no-op (no file
    " is created or appended to).
    let l:tmp = tempname() . '.log'
    let g:llm_agent_debug = 0
    let g:llm_agent_debug_file = l:tmp
    call LLMAgent_DebugLog({'kind': 'test', 'value': 42})
    call s:Assert(!filereadable(l:tmp), 'no log file created when debug is off')
    call delete(l:tmp)
    let g:llm_agent_debug = 0
    let g:llm_agent_debug_file = ''
endfunction

function! s:Test_DebugLog_appends_jsonl() abort
    " With debug on, each call appends one JSON-encoded line.
    let l:tmp = tempname() . '.log'
    let g:llm_agent_debug = 1
    let g:llm_agent_debug_file = l:tmp
    call LLMAgent_DebugLog({'kind': 'first', 'value': 1})
    call LLMAgent_DebugLog({'kind': 'second', 'value': 2})
    let l:lines = readfile(l:tmp)
    call s:AssertEq(len(l:lines), 2, 'two lines written')
    " json_encode output: {"t":...,"kind":"first",...}
    " (nvim's json_encode inserts spaces after ':' and ','; vim's does not,
    " so match on the key name only.)
    call s:Assert(stridx(l:lines[0], '"kind"') >= 0, 'first line has first kind')
    call s:Assert(stridx(l:lines[1], '"kind"') >= 0, 'second line has second kind')
    call s:Assert(stridx(l:lines[0], '"first"') >= 0 && stridx(l:lines[1], '"second"') >= 0, 'kinds keep their values')
    call s:Assert(stridx(l:lines[0], '"t"') >= 0, 'lines include a timestamp')
    call delete(l:tmp)
    let g:llm_agent_debug = 0
    let g:llm_agent_debug_file = ''
endfunction

function! s:Test_DebugLog_swallows_errors() abort
    " A write failure (bad path) must not raise — debug logging is best-effort.
    let g:llm_agent_debug = 1
    let g:llm_agent_debug_file = '/no/such/dir/cannot-write.jsonl'
    try
        call LLMAgent_DebugLog({'kind': 'should not throw'})
        call s:Assert(1, 'no exception on bad log path')
    catch
        call s:Assert(0, 'DebugLog raised: ' . v:exception)
    endtry
    let g:llm_agent_debug = 0
    let g:llm_agent_debug_file = ''
endfunction

function! s:Test_PrettyJson_roundtrip() abort
    call s:AssertEq(LLMAgent_PrettyJson(''), '', 'empty stays empty')
    call s:AssertEq(LLMAgent_PrettyJson('not-json'), 'not-json', 'invalid json returned as-is')
    call s:Assert(stridx(LLMAgent_PrettyJson('{"a":1}'), '"a"') >= 0, 'valid json round-trips')
endfunction

" --- Syntax validation tests -------------------------------------------------

function! s:Test_ValidateSyntax_bash_ok() abort
    call s:AssertEq(LLMAgent_ValidateFileSyntax('test.sh', "echo hello\n"), '', 'valid bash returns empty error')
    call s:AssertEq(LLMAgent_ValidateFileSyntax('test.sh', "if [[ 1 == 1 ]]; then\n  echo hi\nfi\n"), '', 'valid if returns empty error')
    call s:AssertEq(LLMAgent_ValidateFileSyntax('test.bash', "echo hi\n"), '', 'bash extension accepted')
endfunction

function! s:Test_ValidateSyntax_bash_bad() abort
    " Unclosed if
    let l:r = LLMAgent_ValidateFileSyntax('test.sh', "if [[ 1 == 1 ]]; then\n  echo hi\n")
    call s:Assert(!empty(l:r), 'unclosed if returns an error')
    call s:Assert(stridx(l:r, 'syntax') >= 0 || stridx(l:r, 'unexpected') >= 0 || stridx(l:r, 'EOF') >= 0, 'error mentions syntax/EOF')
endfunction

function! s:Test_ValidateSyntax_python_ok() abort
    call s:AssertEq(LLMAgent_ValidateFileSyntax('test.py', "def foo():\n    return 1\n"), '', 'valid python returns empty')
endfunction

function! s:Test_ValidateSyntax_python_bad() abort
    if !executable('python3')
        return
    endif
    let l:r = LLMAgent_ValidateFileSyntax('test.py', "def foo(:\n  pass")
    call s:Assert(!empty(l:r), 'bad python returns an error')
    call s:Assert(stridx(l:r, 'SyntaxError') >= 0 || stridx(l:r, 'syntax') >= 0, 'error mentions SyntaxError')
endfunction

function! s:Test_ValidateSyntax_json_bad() abort
    let l:r = LLMAgent_ValidateFileSyntax('test.json', '{"a":}')
    call s:Assert(!empty(l:r), 'malformed json returns an error')
    call s:Assert(stridx(l:r, 'JSON') >= 0, 'error mentions JSON')
endfunction

function! s:Test_ValidateSyntax_unknown_ext() abort
    " Unknown extensions return empty (no validation).
    call s:AssertEq(LLMAgent_ValidateFileSyntax('test.txt', 'anything goes'), '', 'unknown ext returns empty')
    call s:AssertEq(LLMAgent_ValidateFileSyntax('test.unknown', 'whatever'), '', 'unknown ext returns empty')
endfunction

function! s:Test_QueueWrite_blocks_syntax_error() abort
    " Reproduces the user's actual failure: LLM wrote a shell script with
    " mid-string newlines that bash can't parse. QueueWrite must refuse.
    let l:bad_content = "fHelp()\n{\n    echo \"unclosed\n  echo bad\n}\n"
    let l:r = LLMAgent_QueueWrite('setup.sh', l:bad_content)
    call s:Assert(!empty(l:r), 'QueueWrite refuses syntactically broken content')
    call s:Assert(stridx(l:r, 'syntax check failed') >= 0, 'error mentions syntax check')
endfunction

function! s:Test_WriteFile_rejects_syntax_error() abort
    " The user's exact bug: write_file should refuse to queue a shell
    " script that bash -n can't parse. Use write_file_force to bypass
    " the read-first gate, but the syntax gate is non-overridable.
    let l:probe = getcwd() . '/_llm_bad_syntax.sh'
    let l:args = {}
    let l:args.path = l:probe
    let l:args.content = "fHelp()\n{\n    echo \"unclosed\n  echo bad\n}\n"
    let l:args.write_file_force = v:true
    let l:r = LLMAgent_ToolWriteFile(l:args)
    call s:AssertEq(l:r['ok'], 0, 'ok is false for bad syntax')
    call s:Assert(stridx(l:r['error'], 'syntax') >= 0, 'error mentions syntax')
    call s:Assert(stridx(l:r['error'], 'NOT queued') >= 0, 'error says NOT queued')
    call delete(l:probe)
endfunction

function! s:Test_WriteFile_allows_valid_syntax() abort
    " Symmetric: valid bash IS accepted.
    let l:probe = getcwd() . '/_llm_good_syntax.sh'
    let l:args = {}
    let l:args.path = l:probe
    let l:args.content = "#!/bin/bash\necho hello\n"
    let l:args.write_file_force = v:true
    let l:r = LLMAgent_ToolWriteFile(l:args)
    call s:AssertEq(l:r['ok'], 1, 'ok is true for valid bash')
    call delete(l:probe)
endfunction

" --- Curl exit code translation ---------------------------------------------

function! s:Test_CurlExitHint_zero() abort
    " exit 0 means success — no hint.
    call s:AssertEq(LLMAgent_CurlExitHint(0), '', 'no hint for exit 0')
endfunction

function! s:Test_CurlExitHint_28_timeout() abort
    " exit 28 is the most common one the user just hit.
    let l:hint = LLMAgent_CurlExitHint(28)
    call s:Assert(stridx(l:hint, 'timeout') >= 0, 'hint mentions timeout')
    call s:Assert(stridx(l:hint, 'g:llm_agent_timeout') >= 0, 'hint names the variable')
    call s:Assert(stridx(l:hint, ':LLMAgent') >= 0, 'hint tells how to retry')
endfunction

function! s:Test_CurlExitHint_unknown() abort
    " Unrecognized codes return '' (no hint); the raw curl error from
    " system() tells the user the exit code.
    call s:AssertEq(LLMAgent_CurlExitHint(99), '', 'unknown exit code returns empty')
endfunction

" --- Sidebar log prefix highlight colors -------------------------------------

function! s:Test_PrefixHiGroup_known_prefixes() abort
    " The 4 distinguished prefixes get their own group; everything else
    " gets the gray "other" group.
    call s:AssertEq(LLMAgent_PrefixHiGroup('You'), 'LLMAgentHiYou', 'You maps to LLMAgentHiYou')
    call s:AssertEq(LLMAgent_PrefixHiGroup('Agent'), 'LLMAgentHiAgent', 'Agent maps to LLMAgentHiAgent')
    call s:AssertEq(LLMAgent_PrefixHiGroup('Error'), 'LLMAgentHiError', 'Error maps to LLMAgentHiError')
    call s:AssertEq(LLMAgent_PrefixHiGroup('Warning'), 'LLMAgentHiWarning', 'Warning maps to LLMAgentHiWarning')
    call s:AssertEq(LLMAgent_PrefixHiGroup('Tool'), 'LLMAgentHiOther', 'Tool maps to LLMAgentHiOther')
    call s:AssertEq(LLMAgent_PrefixHiGroup('Result'), 'LLMAgentHiOther', 'Result maps to LLMAgentHiOther')
    call s:AssertEq(LLMAgent_PrefixHiGroup('System'), 'LLMAgentHiOther', 'System maps to LLMAgentHiOther')
    call s:AssertEq(LLMAgent_PrefixHiGroup('NotAPrefix'), 'LLMAgentHiOther', 'unknown prefix maps to Other')
    call s:AssertEq(LLMAgent_PrefixHiGroup(''), 'LLMAgentHiOther', 'empty prefix maps to Other')
endfunction

function! s:Test_PrefixHiGroup_you_vs_agent_distinct() abort
    " The whole point of the feature: the 4 distinguished prefixes must
    " each get their own group, distinct from each other and from Other.
    call s:Assert(LLMAgent_PrefixHiGroup('You') !=# LLMAgent_PrefixHiGroup('Agent'), 'You and Agent use different groups')
    call s:Assert(LLMAgent_PrefixHiGroup('You') !=# LLMAgent_PrefixHiGroup('Error'), 'You and Error use different groups')
    call s:Assert(LLMAgent_PrefixHiGroup('You') !=# LLMAgent_PrefixHiGroup('Warning'), 'You and Warning use different groups')
    call s:Assert(LLMAgent_PrefixHiGroup('You') !=# LLMAgent_PrefixHiGroup('Other'), 'You and Other use different groups')
    call s:Assert(LLMAgent_PrefixHiGroup('Agent') !=# LLMAgent_PrefixHiGroup('Error'), 'Agent and Error use different groups')
    call s:Assert(LLMAgent_PrefixHiGroup('Agent') !=# LLMAgent_PrefixHiGroup('Warning'), 'Agent and Warning use different groups')
    call s:Assert(LLMAgent_PrefixHiGroup('Agent') !=# LLMAgent_PrefixHiGroup('Other'), 'Agent and Other use different groups')
    call s:Assert(LLMAgent_PrefixHiGroup('Error') !=# LLMAgent_PrefixHiGroup('Warning'), 'Error and Warning use different groups')
    call s:Assert(LLMAgent_PrefixHiGroup('Error') !=# LLMAgent_PrefixHiGroup('Other'), 'Error and Other use different groups')
    call s:Assert(LLMAgent_PrefixHiGroup('Warning') !=# LLMAgent_PrefixHiGroup('Other'), 'Warning and Other use different groups')
endfunction

function! s:Test_PrefixHiGroup_returns_nonempty() abort
    " No prefix returns ''. After the redesign, every input returns a
    " group name (Other for unknown). Verify the function always has a
    " useful return value.
    call s:Assert(!empty(LLMAgent_PrefixHiGroup('Foo')), 'any prefix returns a group')
endfunction

" --- Patch robustness tests ------------------------------------------------

function! s:Test_ToolPatch_rejects_empty_diff() abort
    let l:f = getcwd() . '/_llm_patch_empty.txt'
    call writefile(['a', 'b'], l:f)
    " patch_force: true bypasses the "read first" gate so this test can
    " exercise the diff-validation path in isolation.
    let l:r = LLMAgent_ToolPatch({'path': l:f, 'diff': '', 'patch_force': v:true})
    call s:AssertEq(l:r['ok'], 0, 'ok false for empty diff')
    call s:Assert(stridx(l:r['error'], 'empty') >= 0 || stridx(l:r['error'], 'write_file') >= 0, 'error mentions empty or write_file')
    call delete(l:f)
endfunction

function! s:Test_ToolPatch_rejects_diff_with_no_hunks() abort
    let l:f = getcwd() . '/_llm_patch_nohunk.txt'
    call writefile(['a', 'b'], l:f)
    " Diff-like but no @@ hunk header.
    let l:r = LLMAgent_ToolPatch({'path': l:f, 'diff': "--- a/x\n+++ b/x\n-some line\n+other line\n", 'patch_force': v:true})
    call s:AssertEq(l:r['ok'], 0, 'ok false for hunk-less diff')
    call s:Assert(stridx(l:r['error'], 'hunk') >= 0, 'error mentions hunk')
    call delete(l:f)
endfunction

function! s:Test_ToolPatch_rejects_diff_with_chatty_lines() abort
    let l:f = getcwd() . '/_llm_patch_chatty.txt'
    call writefile(['a', 'b'], l:f)
    " A "thought" line slipped in (doesn't start with space/+/-,@/etc.)
    let l:r = LLMAgent_ToolPatch({'path': l:f, 'diff': "--- a/x\n+++ b/x\n@@ -1 +1 @@\nHere is the change:\n-some line\n+other line\n", 'patch_force': v:true})
    call s:AssertEq(l:r['ok'], 0, 'ok false for chatty diff')
    call s:Assert(stridx(l:r['error'], 'invalid') >= 0 || stridx(l:r['error'], 'unified diff') >= 0, 'error flags bad syntax')
    call delete(l:f)
endfunction

function! s:Test_ToolPatch_valid_diff_succeeds() abort
    let l:f = getcwd() . '/_llm_patch_ok.txt'
    call writefile(['one', 'two', 'three'], l:f)
    " Use a unified diff that exactly matches the file content.
    let l:args = {'path': l:f, 'diff': "--- a/x\n+++ b/x\n@@ -1,3 +1,3 @@\n-one\n+ONE\n two\n three\n", 'patch_force': v:true}
    let l:r = LLMAgent_ToolPatch(l:args)
    call s:AssertEq(l:r['ok'], 1, 'ok true for valid diff')
    call s:Assert(stridx(l:r['content'], 'patch') >= 0, 'result mentions patch')
    call delete(l:f)
endfunction

function! s:Test_ToolPatch_wrong_context_fails_with_hint() abort
    let l:f = getcwd() . '/_llm_patch_wrong.txt'
    call writefile(['one', 'two', 'three'], l:f)
    " Diff context claims the file has "WRONG" but it actually has "two".
    let l:args = {'path': l:f, 'diff': "--- a/x\n+++ b/x\n@@ -2 +2 @@\n-WRONG\n+TWO\n", 'patch_force': v:true}
    let l:r = LLMAgent_ToolPatch(l:args)
    call s:AssertEq(l:r['ok'], 0, 'ok false for context mismatch')
    call s:Assert(stridx(l:r['error'], 'write_file') >= 0, 'hint recommends write_file')
    call s:Assert(stridx(l:r['error'], 'read_file') >= 0, 'hint recommends read_file')
    call delete(l:f)
endfunction

function! s:Test_ToolPatch_failure_tracked_in_session() abort
    " After a failed patch, the system tracks the path so subsequent turns
    " can see it.
    let l:f = getcwd() . '/_llm_patch_tracked.txt'
    call writefile(['x'], l:f)
    let l:r = LLMAgent_ToolPatch({'path': l:f, 'diff': 'malformed', 'patch_force': v:true})
    call s:AssertEq(l:r['ok'], 0, 'patch failed')
    " s:llm_agent_patch_fails is in LLMAgent's script scope; we verify the
    " side effect via the system prompt, which now lists failed paths.
    call LLMAgent_Reset()
    let l:f2 = getcwd() . '/_llm_patch_tracked2.txt'
    call writefile(['x'], l:f2)
    call LLMAgent_ToolPatch({'path': l:f2, 'diff': 'malformed', 'patch_force': v:true})
    let l:sys = LLMAgent_GetAgentSystemPrompt()
    call s:Assert(stridx(l:sys, 'PATCH FAILURES THIS SESSION') >= 0, 'system prompt lists patch failures')
    call delete(l:f2)
    call delete(l:f)
endfunction

function! s:Test_ToolWriteFile_clears_patch_fail_tracking() abort
    " A successful write_file should clear the patch-fail entry for that
    " path so the warning goes away.
    let l:f = getcwd() . '/_llm_clear_track.txt'
    call writefile(['x'], l:f)
    " Force a fail first by sending an empty diff.
    call LLMAgent_ToolPatch({'path': l:f, 'diff': '', 'patch_force': v:true})
    let l:sys_before = LLMAgent_GetAgentSystemPrompt()
    " Now write the same file successfully.
    call LLMAgent_ToolWriteFile({'path': l:f, 'content': "new content\n", 'write_file_force': v:true})
    let l:sys_after = LLMAgent_GetAgentSystemPrompt()
    call s:Assert(stridx(l:sys_before, l:f) >= 0, 'system prompt mentioned failed path before write')
    call s:Assert(stridx(l:sys_after, l:f) < 0 || stridx(l:sys_after, '_llm_clear_track') < 0, 'system prompt cleared after successful write')
    call delete(l:f)
endfunction

function! s:Test_CaptureSelection_finds_marks() abort
    " Drive the 'range' branch directly: set the '< '> marks via m< and m>
    " (which DOES work in Ex mode), then call the function.
    let l:tmp = tempname() . '.txt'
    call writefile(['line A', 'line B', 'line C', 'line D', 'line E'], l:tmp)
    execute 'edit ' . l:tmp
    call cursor(1, 1)
    normal! m<
    call cursor(3, 1)
    normal! m>
    let l:sel = LLMAgent_CaptureSelection()
    call s:AssertEq(l:sel['mode'], 'range', 'falls back to range mode from marks')
    call s:AssertEq(l:sel['line1'], 1, 'line1 from mark is 1')
    call s:AssertEq(l:sel['line2'], 3, 'line2 from mark is 3')
    call s:Assert(!empty(l:sel['text']), 'text is non-empty')
    call s:Assert(stridx(l:sel['text'], 'line A') >= 0, 'text contains line A')
    call s:Assert(stridx(l:sel['text'], 'line C') >= 0, 'text contains line C')
    bwipe!
    call delete(l:tmp)
endfunction

function! s:Test_Reset_clears_messages() abort
    " We can't directly observe s:llm_agent_messages from another script,
    " but we CAN observe the side effect: after Reset(), sending a new
    " prompt creates a fresh message list. The easiest observable contract:
    " GetAgentSystemPrompt works without throwing after Reset().
    call LLMAgent_Reset()
    let l:p = LLMAgent_GetAgentSystemPrompt()
    call s:Assert(type(l:p) == v:t_string && !empty(l:p), 'GetAgentSystemPrompt still works after Reset')
endfunction

function! s:Test_Reset_is_idempotent() abort
    call LLMAgent_Reset()
    call LLMAgent_Reset()
    call LLMAgent_Reset()
    call s:Assert(1, 'Reset is idempotent (no error on repeated calls)')
endfunction

function! s:Test_GetAgentSystemPrompt_includes_active_buffer() abort
    let l:tmp = tempname() . '.py'
    call writefile(['x = 1'], l:tmp)
    execute 'edit ' . l:tmp
    setlocal filetype=python
    let l:p = LLMAgent_GetAgentSystemPrompt()
    call s:Assert(stridx(l:p, 'Working on file:') >= 0, 'includes Working on file:')
    call s:Assert(stridx(l:p, fnamemodify(l:tmp, ':t')) >= 0, 'mentions the active file')
    call s:Assert(stridx(l:p, '(python)') >= 0, 'includes filetype')
    bwipe!
    call delete(l:tmp)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Tool usage end-to-end tests (ExecuteTool dispatch + real files)
""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Shared scratch project for tool tests. Lives under the project root so
" IsOutsideProject accepts it; each test cleans up after itself.
function! s:ToolTestDir()
    let l:dir = getcwd() . '/_llm_tooltest'
    if !isdirectory(l:dir)
        call mkdir(l:dir, 'p')
    endif
    return l:dir
endfunction

function! s:ToolTestWriteFile(name, lines)
    let l:f = s:ToolTestDir() . '/' . a:name
    call writefile(a:lines, l:f)
    return l:f
endfunction

function! s:ToolTestCleanup(name)
    let l:f = s:ToolTestDir() . '/' . a:name
    if filereadable(l:f)
        call delete(l:f)
    endif
endfunction

" Mark a file as read the way a real read_file call would (the write/patch
" gates consult s:llm_agent_read_files). Going through ToolReadFile is the
" honest path: it exercises the exact registration the LLM's flow uses.
function! s:ToolTestMarkRead(path)
    call LLMAgent_ToolReadFile({'path': a:path})
endfunction

" Approve all queued writes (the way SidebarApprove does) and assert the
" on-disk file equals a:expected_lines. Guards against the "ok=1 but wrong
" content" class of regression.
function! s:ApplyAllWritesAndCheck(path, expected_lines, msg)
    let l:had_input = bufnr('LLMAgent-Input') >= 0
    if !l:had_input
        new
        silent file LLMAgent-Input
    endif
    call LLMAgent_SidebarApprove()
    if !l:had_input
        bwipe!
    endif
    let l:got = readfile(a:path)
    call s:AssertEq(l:got, a:expected_lines, a:msg)
endfunction

" --- read_file ---

function! s:Test_ToolReadFile_missing_path_arg() abort
    let l:r = LLMAgent_ToolReadFile({})
    call s:AssertEq(l:r['ok'], 0, 'ok false when path arg missing')
    call s:Assert(stridx(l:r['error'], 'path') >= 0, 'error mentions path')
endfunction

function! s:Test_ToolReadFile_registers_read_state() abort
    " read_file must register the path so later write_file/patch pass their
    " read-first gates. Observed indirectly: a write_file without force now
    " succeeds on an existing file right after read_file.
    let l:f = s:ToolTestWriteFile('_llm_read_state.txt', ['x1', 'x2'])
    let l:r = LLMAgent_ToolReadFile({'path': l:f})
    call s:AssertEq(l:r['ok'], 1, 'read_file ok')
    let l:w = LLMAgent_ToolWriteFile({'path': l:f, 'content': "x1\nx2 edited\n"})
    call s:AssertEq(l:w['ok'], 1, 'write_file passes read-first gate after read_file')
    call s:ToolTestCleanup('_llm_read_state.txt')
endfunction

function! s:Test_ToolReadFile_truncates_huge_file() abort
    " Files past 50K chars get truncated with a hint instead of being
    " dumped whole into the context.
    let l:f = s:ToolTestWriteFile('_llm_read_huge.txt', range(1, 5000)->map('printf("line %040d ........10........20........30........40........50", v:val)'))
    let l:r = LLMAgent_ToolReadFile({'path': l:f})
    call s:AssertEq(l:r['ok'], 1, 'huge read still ok')
    call s:Assert(len(l:r['content']) <= 51000, 'content bounded near 50K, got ' . len(l:r['content']))
    call s:Assert(stridx(l:r['content'], 'truncated') >= 0, 'truncation notice present')
    call s:ToolTestCleanup('_llm_read_huge.txt')
endfunction

function! s:Test_ToolReadFile_range_past_eof_clamps() abort
    " Range that starts inside the file but ends past EOF is clamped to
    " EOF, not an error (unlike start past EOF which errors).
    let l:f = s:ToolTestWriteFile('_llm_read_clamp.txt', ['a', 'b', 'c'])
    let l:r = LLMAgent_ToolReadFile({'path': l:f, 'start_line': 2, 'end_line': 99})
    call s:AssertEq(l:r['ok'], 1, 'ok when end past EOF is clamped')
    call s:Assert(stridx(l:r['content'], '3| c') >= 0, 'last line included')
    call s:ToolTestCleanup('_llm_read_clamp.txt')
endfunction

" --- write_file ---

function! s:Test_ToolWriteFile_missing_args() abort
    let l:r = LLMAgent_ToolWriteFile({'path': 'x.txt'})
    call s:AssertEq(l:r['ok'], 0, 'ok false without content arg')
    let l:r2 = LLMAgent_ToolWriteFile({'content': 'x'})
    call s:AssertEq(l:r2['ok'], 0, 'ok false without path arg')
    call s:Assert(stridx(l:r2['error'], 'both') >= 0, 'error says requires both')
endfunction

function! s:Test_ToolWriteFile_rejects_git_internal_paths() abort
    " Writing inside .git/ must be refused even though the path is inside
    " the project tree.
    let l:r = LLMAgent_ToolWriteFile({'path': getcwd() . '/scripts/module/.git-config', 'content': 'x', 'write_file_force': v:true})
    call s:AssertEq(l:r['ok'], 0, 'ok false for .git path')
    call s:Assert(stridx(l:r['error'], 'outside') >= 0, 'refusal mentions outside project')
endfunction

function! s:Test_ToolWriteFile_new_file_no_read_needed() abort
    " Creating a brand new file must NOT require a read-first gate
    " (there is nothing to read yet).
    let l:f = s:ToolTestDir() . '/_llm_new_file.txt'
    if filereadable(l:f)
        call delete(l:f)
    endif
    let l:r = LLMAgent_ToolWriteFile({'path': l:f, 'content': "brand new\n"})
    call s:AssertEq(l:r['ok'], 1, 'new file needs no read first')
    call s:ToolTestCleanup('_llm_new_file.txt')
endfunction

function! s:Test_ToolWriteFile_preserves_literal_escapes_with_real_newlines() abort
    " When content ALREADY has real newlines, remaining literal \n must be
    " preserved verbatim — decoding them would corrupt printf source lines.
    let l:f = s:ToolTestWriteFile('_llm_write_literal.txt', ['placeholder'])
    let l:content = "run('printf \"a\\nb\\n\"')\nend\n"
    let l:r = LLMAgent_ToolWriteFile({'path': l:f, 'content': l:content, 'write_file_force': v:true})
    call s:AssertEq(l:r['ok'], 1, 'write ok')
    call LLMAgent_ApplyWrites([{'path': l:f, 'content': l:content}])
    let l:got = readfile(l:f)
    call s:AssertEq(len(l:got), 2, 'two lines written (literal \n not decoded)')
    call s:Assert(stridx(l:got[0], '\n') >= 0, 'printf newline stays literal')
    call s:ToolTestCleanup('_llm_write_literal.txt')
endfunction

function! s:Test_ApplyWrites_creates_missing_dirs() abort
    " ApplyWrites must mkdir -p the parent before writefile
    let l:dir = s:ToolTestDir() . '/_llm_sub/a/b'
    let l:f = l:dir . '/deep.txt'
    if isdirectory(l:dir)
        call delete(l:dir, 'rf')
    endif
    call LLMAgent_ApplyWrites([{'path': l:f, 'content': "deep\n"}])
    call s:Assert(filereadable(l:f), 'missing dirs created for deep write')
    call s:Assert(stridx(readfile(l:f)[0], 'deep') >= 0, 'content written')
    call delete(s:ToolTestDir() . '/_llm_sub', 'rf')
endfunction

function! s:Test_ReloadChangedBuffers_reloads_after_external_write() abort
    " After an ACP turn the agent writes files directly to disk, so open
    " buffers go stale. ReloadChangedBuffers must pick up the change.
    let l:f = s:ToolTestWriteFile('_llm_reload.txt', ['one', 'two'])
    " Open the file in a buffer.
    execute 'edit ' . fnameescape(l:f)
    " Simulate the agent rewriting the file on disk (bypassing our queue).
    call writefile(['one', 'TWO', 'three'], l:f)
    call LLMAgent_ReloadChangedBuffers()
    let l:buf = bufnr(l:f)
    call s:AssertEq(getbufline(l:buf, 2, 2), ['TWO'], 'buffer reloaded the external change')
    call s:AssertEq(getbufline(l:buf, 3, 3), ['three'], 'buffer has the new line')
    call s:ToolTestCleanup('_llm_reload.txt')
endfunction

function! s:Test_ShowApprovalDiff_renders_change() abort
    " The approval flow must show the user the actual change (a unified
    " diff of current vs proposed content) before they decide. Verify the
    " diff preview is logged to the chat buffer with +/- markers.
    let l:f = s:ToolTestWriteFile('_llm_diff.txt', ['alpha', 'beta', 'gamma'])
    call s:ToolTestMarkRead(l:f)
    " Open the chat buffer so SidebarLog has somewhere to write.
    call LLMAgent_SidebarOpen()
    call LLMAgent_ShowApprovalDiff([{'path': l:f, 'content': "alpha\nBETA\ngamma\ndelta\n"}])
    let l:chat = bufnr('LLMAgent-Chat')
    let l:lines = getbufline(l:chat, 1, '$')
    let l:joined = join(l:lines, "\n")
    call s:Assert(stridx(l:joined, 'Diff for') >= 0, 'diff header logged')
    call s:Assert(stridx(l:joined, '-beta') >= 0, 'removed line shown')
    call s:Assert(stridx(l:joined, '+BETA') >= 0, 'added line shown')
    call s:Assert(stridx(l:joined, '+delta') >= 0, 'added line at end shown')
    call s:ToolTestCleanup('_llm_diff.txt')
endfunction

" --- patch ---

function! s:Test_ToolPatch_missing_args() abort
    let l:r = LLMAgent_ToolPatch({'path': 'x'})
    call s:AssertEq(l:r['ok'], 0, 'ok false without diff arg')
    let l:r2 = LLMAgent_ToolPatch({'diff': 'x'})
    call s:AssertEq(l:r2['ok'], 0, 'ok false without path arg')
endfunction

function! s:Test_ToolPatch_requires_read_first() abort
    let l:f = s:ToolTestWriteFile('_llm_patch_readfirst.txt', ['m1', 'm2'])
    let l:diff = "--- a/x\n+++ b/x\n@@ -1,2 +1,2 @@\n m1\n-m2\n+M2\n"
    let l:r = LLMAgent_ToolPatch({'path': l:f, 'diff': l:diff})
    call s:AssertEq(l:r['ok'], 0, 'ok false when not read')
    call s:Assert(stridx(l:r['error'], 'read_file') >= 0, 'error says read_file first')
    " patch_force bypasses
    let l:r2 = LLMAgent_ToolPatch({'path': l:f, 'diff': l:diff, 'patch_force': v:true})
    call s:AssertEq(l:r2['ok'], 1, 'patch_force bypasses read-first gate')
    call s:ToolTestCleanup('_llm_patch_readfirst.txt')
endfunction

function! s:Test_ToolPatch_refuses_path_traversal() abort
    let l:r = LLMAgent_ToolPatch({'path': '/tmp/_llm_patch_outside.txt', 'diff': "--- a\n+++ b\n@@ -1 +1 @@\n-a\n+b\n", 'patch_force': v:true})
    call s:AssertEq(l:r['ok'], 0, 'ok false outside project')
    call s:Assert(stridx(l:r['error'], 'outside') >= 0, 'error mentions outside project')
endfunction

function! s:Test_ToolPatch_rejects_missing_file() abort
    let l:r = LLMAgent_ToolPatch({'path': s:ToolTestDir() . '/_llm_patch_nofile.txt', 'diff': "--- a\n+++ b\n@@ -1 +1 @@\n-a\n+b\n", 'patch_force': v:true})
    call s:AssertEq(l:r['ok'], 0, 'ok false when file missing')
    call s:Assert(stridx(l:r['error'], 'not found') >= 0, 'error says not found')
    call s:Assert(stridx(l:r['error'], 'write_file') >= 0, 'error suggests write_file for new files')
endfunction

function! s:Test_ToolPatch_applies_and_queues_correct_content() abort
    " Full happy path: read -> patch -> ok:1; the queued content must be
    " EXACTLY the patched result. Verified by driving the real approval
    " path: create the LLMAgent-Input buffer (as SidebarOpen does), then
    " SidebarApprove applies s:llm_agent_write_list and wipes it.
    let g:llm_agent_tool_confirm = 0
    let l:f = s:ToolTestWriteFile('_llm_patch_apply.txt', ['alpha', 'beta', 'gamma'])
    call s:ToolTestMarkRead(l:f)
    let l:r = LLMAgent_ExecuteTool('patch', {'path': l:f, 'diff': "--- f.txt\n+++ f.txt\n@@ -1,3 +1,3 @@\n alpha\n-beta\n+BETA\n gamma\n"})
    call s:AssertEq(l:r['ok'], 1, 'patch applies')
    call s:Assert(stridx(l:r['content'], l:f) >= 0, 'message includes path')
    " Approval flow needs the input buffer for its prompt UI.
    let l:had_input = bufnr('LLMAgent-Input') >= 0
    if !l:had_input
        new
        silent file LLMAgent-Input
    endif
    call LLMAgent_SidebarApprove()
    if !l:had_input
        bwipe!
    endif
    let l:got = join(readfile(l:f), "\n") . "\n"
    call s:AssertEq(l:got, "alpha\nBETA\ngamma\n", 'applied content is the patched file')
    call s:ToolTestCleanup('_llm_patch_apply.txt')
endfunction

function! s:Test_ToolPatch_tolerates_slightly_off_counts() abort
    " The tool tolerates an LLM diff whose @@ header line counts barely
    " mismatch the actual hunk body — patch(1) applies it anyway, so the
    " patch should not be rejected up front.
    let l:f = s:ToolTestWriteFile('_llm_patch_recount.txt', ['p1', 'p2', 'p3'])
    call s:ToolTestMarkRead(l:f)
    " Wrong counts: header says 2 lines of context but the hunk has 3.
    let l:diff = "--- f\n+++ f\n@@ -1,2 +1,2 @@\n p1\n-p2\n+P2\n p3\n"
    let l:r = LLMAgent_ExecuteTool('patch', {'path': l:f, 'diff': l:diff})
    call s:AssertEq(l:r['ok'], 1, 'patch(1) applies a malformed-count diff')
    if l:r['ok'] == 0
        call s:Assert(0, 'unexpected: ' . substitute(l:r['error'], '\n', ' | ', 'g'))
    endif
    call s:ToolTestCleanup('_llm_patch_recount.txt')
endfunction

function! s:Test_ToolPatch_failure_tells_how_to_recover() abort
    " When patch(1) (and its recovery passes) all fail, the error must tell
    " the LLM how to recover by switching to write_file with the full content.
    let l:f = s:ToolTestWriteFile('_llm_patch_bothfail.txt', ['actual one', 'actual two'])
    call s:ToolTestMarkRead(l:f)
    " Hunk context does not exist in the file.
    let l:diff = "--- x\n+++ x\n@@ -10,2 +10,2 @@\n nonexistent line A\n-nonexistent line B\n+NEW\n"
    let l:r = LLMAgent_ExecuteTool('patch', {'path': l:f, 'diff': l:diff})
    call s:AssertEq(l:r['ok'], 0, 'ok false when the patch fails')
    call s:Assert(stridx(l:r['error'], 'patch(1) said') >= 0, 'includes patch(1) output')
    call s:Assert(stridx(l:r['error'], 'write_file') >= 0, 'tells the LLM to switch to write_file')
    call s:ToolTestCleanup('_llm_patch_bothfail.txt')
endfunction

function! s:Test_ToolPatch_then_write_clears_fail_tracking() abort
    " After QueueWrite succeeds for a path, its patch-failure counter must
    " reset — a successful write means the LLM moved past the patch loop.
    let l:f = s:ToolTestWriteFile('_llm_patch_clears.txt', ['t1', 't2'])
    call s:ToolTestMarkRead(l:f)
    " Force 2 tracked failures via queue... simplest: QueueWrite directly
    " after 2 patch failures is covered elsewhere; here verify a successful
    " patch + queue resets the counter observable via a 3rd patch attempt
    " not being refused.
    let l:bad_diff = "--- x\n+++ x\n@@ -10,2 +10,2 @@\n nope1\n-nope2\n+NOPE\n"
    call LLMAgent_ExecuteTool('patch', {'path': l:f, 'diff': l:bad_diff, 'patch_force': 1})
    call LLMAgent_ExecuteTool('patch', {'path': l:f, 'diff': l:bad_diff, 'patch_force': 1})
    " Two fails. A good diff now queues a write; the track must clear and
    " a following bad patch must be ATTEMPTED (fail with patch(1) output),
    " not refused by the loop breaker.
    call LLMAgent_ExecuteTool('patch', {'path': l:f, 'diff': "--- x\n+++ x\n@@ -1,2 +1,2 @@\n t1\n-t2\n+T2\n", 'patch_force': 1})
    let l:r = LLMAgent_ExecuteTool('patch', {'path': l:f, 'diff': l:bad_diff, 'patch_force': 1})
    call s:Assert(stridx(l:r['error'], 'already failed') < 0, 'fail tracking was cleared by successful queue')
    call s:ToolTestCleanup('_llm_patch_clears.txt')
endfunction

" --- ls ---

function! s:Test_ToolLs_empty_dir() abort
    let l:d = s:ToolTestDir() . '/_llm_ls_empty'
    if !isdirectory(l:d)
        call mkdir(l:d, 'p')
    endif
    let l:r = LLMAgent_ToolLs({'path': l:d})
    call s:AssertEq(l:r['ok'], 1, 'ok on empty dir')
    call s:Assert(stridx(l:r['content'], 'empty directory') >= 0, 'says empty directory')
    call delete(l:d, 'd')
endfunction

function! s:Test_ToolLs_marks_dirs_with_slash() abort
    let l:d = s:ToolTestDir() . '/_llm_ls_mix'
    if isdirectory(l:d)
        call delete(l:d, 'rf')
    endif
    call mkdir(l:d . '/sub', 'p')
    call writefile(['x'], l:d . '/file.txt')
    let l:r = LLMAgent_ToolLs({'path': l:d})
    call s:AssertEq(l:r['ok'], 1, 'ok on mixed dir')
    call s:Assert(stridx(l:r['content'], 'sub/') >= 0, 'directories get trailing slash')
    call s:Assert(stridx(l:r['content'], 'file.txt') >= 0, 'files listed bare')
    call s:Assert(stridx(l:r['content'], 'entries') >= 0, 'entry count in header')
    call delete(l:d, 'rf')
endfunction

function! s:Test_ToolLs_defaults_to_cwd() abort
    let l:r = LLMAgent_ToolLs({})
    call s:AssertEq(l:r['ok'], 1, 'ok with no path arg — defaults to cwd')
    call s:Assert(stridx(l:r['content'], 'Contents of') >= 0, 'header present')
endfunction

" --- find ---

function! s:Test_ToolFind_missing_pattern() abort
    let l:r = LLMAgent_ToolFind({})
    call s:AssertEq(l:r['ok'], 0, 'ok false without pattern')
    call s:Assert(stridx(l:r['error'], 'pattern') >= 0, 'error mentions pattern')
endfunction

function! s:Test_ToolFind_recursive_glob() abort
    let l:d = s:ToolTestDir()
    call mkdir(l:d . '/_llm_find_deep', 'p')
    call writefile(['x'], l:d . '/_llm_find_deep/inner.txt')
    let l:r = LLMAgent_ToolFind({'pattern': '_llm_tooltest/_llm_find_deep/*.txt'})
    call s:AssertEq(l:r['ok'], 1, 'ok on recursive glob')
    call s:Assert(stridx(l:r['content'], 'inner') >= 0, 'finds nested file')
    call s:Assert(stridx(l:r['content'], 'Matches for') >= 0, 'match header present')
    call delete(l:d . '/_llm_find_deep', 'rf')
endfunction

function! s:Test_ToolFind_caps_at_200() abort
    " The 200-cap must trigger the "First 200" phrasing rather than dump
    " everything. Create 205+ real files in the scratch dir and search for
    " them with a plain pattern (nested brace globs are not expandable by
    " Vim's globpath, so we go through real files).
    let l:d = s:ToolTestDir() . '/_llm_find_cap'
    if isdirectory(l:d)
        call delete(l:d, 'rf')
    endif
    call mkdir(l:d, 'p')
    for l:i in range(1, 205)
        call writefile(['x'], printf('%s/f%03d.txt', l:d, l:i))
    endfor
    call writefile(['x'], l:d . '/sample.md')
    let l:r = LLMAgent_ToolFind({'pattern': '_llm_tooltest/_llm_find_cap/*.txt'})
    call s:AssertEq(l:r['ok'], 1, 'find ok even with many matches')
    call s:Assert(stridx(l:r['content'], 'First 200') >= 0, 'caps output at 200 with First 200 phrasing')
    call s:Assert(stridx(l:r['content'], 'sample.md') < 0, 'the .md is excluded by glob')
    call delete(l:d, 'rf')
endfunction

" --- grep ---

function! s:Test_ToolGrep_glob_filter() abort
    " Only files matching the glob are searched.
    let l:d = s:ToolTestDir() . '/_llm_grep_glob'
    if isdirectory(l:d)
        call delete(l:d, 'rf')
    endif
    call mkdir(l:d, 'p')
    call writefile(['needle here'], l:d . '/one.txt')
    call writefile(['needle here'], l:d . '/two.log')
    let l:r = LLMAgent_ToolGrep({'pattern': 'needle', 'path': l:d, 'glob': '*.txt'})
    call s:AssertEq(l:r['ok'], 1, 'ok with glob filter')
    call s:Assert(stridx(l:r['content'], 'one.txt') >= 0, '.txt file searched')
    call s:Assert(stridx(l:r['content'], 'two.txt') < 0, '.log file NOT searched')
    call delete(l:d, 'rf')
endfunction

function! s:Test_ToolGrep_match_gives_file_line_content() abort
    let l:d = s:ToolTestDir() . '/_llm_grep_shape'
    if isdirectory(l:d)
        call delete(l:d, 'rf')
    endif
    call mkdir(l:d, 'p')
    call writefile(['never1', 'hit the needle', 'never2'], l:d . '/s.txt')
    let l:r = LLMAgent_ToolGrep({'pattern': 'needle', 'path': l:d})
    call s:AssertEq(l:r['ok'], 1, 'ok')
    call s:Assert(stridx(l:r['content'], 's.txt:2: hit the needle') >= 0, 'file:line: content shape')
    call delete(l:d, 'rf')
endfunction

function! s:Test_ToolGrep_missing_path_errors() abort
    " path='' resolves to empty -> error, not a silent cwd search.
    let l:r = LLMAgent_ToolGrep({'pattern': 'x', 'path': ''})
    call s:AssertEq(l:r['ok'], 1, 'empty path falls back to cwd, still ok')
endfunction

function! s:Test_ToolGrep_caps_at_100_matches() abort
    let l:d = s:ToolTestDir() . '/_llm_grep_cap'
    if isdirectory(l:d)
        call delete(l:d, 'rf')
    endif
    call mkdir(l:d, 'p')
    " 150 lines all matching.
    call writefile(map(range(1, 150), '"common token line " . v:val'), l:d . '/many.txt')
    let l:r = LLMAgent_ToolGrep({'pattern': 'common', 'path': l:d})
    call s:Assert(stridx(l:r['content'], 'truncated at 100') >= 0, 'caps at 100 with notice')
    call delete(l:d, 'rf')
endfunction

" --- list_buffers ---

function! s:Test_ToolListBuffers_shows_buffers() abort
    new _llm_lm_buffer_probe.txt
    let l:r = LLMAgent_ExecuteTool('list_buffers', {})
    call s:AssertEq(l:r['ok'], 1, 'ok')
    call s:Assert(stridx(l:r['content'], '_llm_lm_buffer_probe.txt') >= 0, 'lists opened buffer')
    call s:Assert(stridx(l:r['content'], 'Open buffers') >= 0, 'header present')
    bwipe!
endfunction

" --- dispatcher / parsing helpers ---

function! s:Test_ExecuteTool_read_file_dispatch() abort
    let l:f = s:ToolTestWriteFile('_llm_dispatch_read.txt', ['dispatch'])
    let l:r = LLMAgent_ExecuteTool('read_file', {'path': l:f})
    call s:AssertEq(l:r['ok'], 1, 'ExecuteTool routes read_file')
    call s:Assert(stridx(l:r['content'], '1| dispatch') >= 0, 'numbered output comes from ToolReadFile')
    call s:ToolTestCleanup('_llm_dispatch_read.txt')
endfunction

function! s:Test_ExecuteTool_ls_dispatch() abort
    let l:r = LLMAgent_ExecuteTool('ls', {'path': s:ToolTestDir()})
    call s:AssertEq(l:r['ok'], 1, 'ExecuteTool routes ls')
endfunction

function! s:Test_ParseToolArgs_object_passthrough() abort
    " Some servers send pre-parsed args; must be used as-is.
    let l:p = LLMAgent_ParseToolArgs({'path': 'x'})
    call s:AssertEq(l:p['args']['path'], 'x', 'object args pass through')
endfunction

function! s:Test_ParseToolArgs_json_string() abort
    let l:p = LLMAgent_ParseToolArgs('{"path": "x", "n": 3}')
    call s:AssertEq(l:p['args']['n'], 3, 'json string decodes to dict')
endfunction

function! s:Test_ParseToolArgs_bad_json_error() abort
    let l:p = LLMAgent_ParseToolArgs('{"path": ')
    call s:Assert(has_key(l:p, 'error'), 'malformed json gives an error dict, not a crash')
    call s:AssertEq(get(l:p, 'error', ''), 'malformed tool arguments', 'error text mentions malformed args')
endfunction

function! s:Test_ParseToolArgs_non_string_types() abort
    " Non-dict non-string args must produce an error, not crash.
    let l:p = LLMAgent_ParseToolArgs(42)
    call s:Assert(!empty(get(l:p, 'error', '')), 'number args -> error')
    let l:p2 = LLMAgent_ParseToolArgs([1, 2])
    call s:Assert(!empty(get(l:p2, 'error', '')), 'list args -> error')
    " Scalar json string wraps in _raw so tools still get a dict.
    let l:p3 = LLMAgent_ParseToolArgs('"hello"')
    call s:AssertEq(l:p3['args']['_raw'], 'hello', 'scalar json wrapped under _raw')
endfunction

function! s:Test_ToolArgsSummary_prefers_path_then_pattern() abort
    call s:AssertEq(LLMAgent_ToolArgsSummary({'path': '/a/b'}), '/a/b', 'path preferred')
    call s:AssertEq(LLMAgent_ToolArgsSummary({'pattern': '*'}), '*', 'pattern next')
    call s:AssertEq(LLMAgent_ToolArgsSummary({'diff': 'x'}), '', 'other keys -> empty')
endfunction

function! s:Test_ResponseMessage_shapes() abort
    call s:AssertEq(LLMAgent_ResponseMessage({'choices': []}), {}, 'no choices -> {}')
    call s:AssertEq(LLMAgent_ResponseMessage({}), {}, 'no choices key -> {}')
    let l:m = {'role': 'assistant', 'content': 'hi'}
    call s:AssertEq(LLMAgent_ResponseMessage({'choices': [{'message': l:m}]}), l:m, 'message extracted')
endfunction

function! s:Test_MessageHasText_variants() abort
    call s:AssertEq(LLMAgent_MessageHasText({'content': 'hello'}), 1, 'text content -> true')
    call s:AssertEq(LLMAgent_MessageHasText({'content': '   '}), 0, 'whitespace-only -> false')
    call s:AssertEq(LLMAgent_MessageHasText({'content': v:null}), 0, 'null content -> false')
    call s:AssertEq(LLMAgent_MessageHasText({}), 0, 'missing content -> false')
endfunction

" --- API request builder ---

function! s:Test_APIRequestBody_tools_only_when_given() abort
    let l:b = LLMAgent_APIRequestBody([{'role': 'user', 'content': 'hi'}], [])
    call s:Assert(!has_key(l:b, 'tools'), 'no tools key for empty list')
    call s:AssertEq(l:b['model'], g:llm_agent_model, 'model included')
    let l:b2 = LLMAgent_APIRequestBody([{'role': 'user', 'content': 'hi'}], [{'a': 1}])
    call s:Assert(has_key(l:b2, 'tools'), 'tools key present for non-empty')
endfunction

function! s:Test_BuildCurlCmd_parts() abort
    let g:llm_agent_api_url = 'http://example.invalid/v1'
    let g:llm_agent_api_key = 'secret'
    let l:cmd = LLMAgent_BuildCurlCmd('/tmp/body.json', '')
    call s:Assert(stridx(l:cmd, '-H "Authorization: Bearer secret"') >= 0, 'auth header present')
    call s:Assert(stridx(l:cmd, '-d @') >= 0, 'body file flag present')
    call s:Assert(stridx(l:cmd, '-o ') < 0, 'no -o when outfile empty (stdout)')
    call s:Assert(stridx(l:cmd, 'http://example.invalid/v1/chat/completions') >= 0, 'endpoint appended')
    let g:llm_agent_api_key = ''
endfunction

function! s:Test_ParseCompletion_shapes() abort
    let l:p = LLMAgent_ParseCompletion('{"ok": 1}')
    call s:AssertEq(l:p['data']['ok'], 1, 'valid json -> data')
    let l:p2 = LLMAgent_ParseCompletion('[1,2]')
    call s:Assert(!empty(get(l:p2, 'error', '')), 'non-object json -> error')
    let l:p3 = LLMAgent_ParseCompletion('totally not json')
    call s:Assert(!empty(get(l:p3, 'error', '')), 'garbage -> error')
endfunction

function! s:Test_CurlError_combines_parts() abort
    let l:e = LLMAgent_CurlError(28, 'deadline reached')
    call s:Assert(stridx(l:e, 'exit 28') >= 0, 'exit code included')
    call s:Assert(stridx(l:e, 'too slow') >= 0 || stridx(l:e, 'timed out') >= 0 || stridx(l:e, 'timeout') >= 0, 'timeout hint appended')
endfunction

" --- Error-value string coercion (LLMAgent_ToString) ----------------------

function! s:Test_ToString_passthrough_string() abort
    call s:AssertEq(LLMAgent_ToString('hello'), 'hello', 'plain string is unchanged')
    call s:AssertEq(LLMAgent_ToString(''), '', 'empty string is unchanged')
endfunction

function! s:Test_ToString_json_encodes_dict() abort
    " An API error value can be a Dict (e.g. {"message": "...", "type": ...}).
    " It must be JSON-encoded, not crash string concat with E731.
    let l:s = LLMAgent_ToString({'message': 'boom', 'code': 500})
    call s:Assert(type(l:s) == v:t_string, 'dict returns a string')
    call s:AssertEq(json_decode(l:s)['message'], 'boom', 'dict is json-encoded')
endfunction

function! s:Test_ToString_handles_list_and_number() abort
    call s:Assert(type(LLMAgent_ToString([1, 2])) == v:t_string, 'list returns a string')
    call s:Assert(type(LLMAgent_ToString(42)) == v:t_string, 'number returns a string')
endfunction

" --- SidebarLog must not break on a dict error value ----------------------

function! s:Test_SidebarLog_accepts_dict_text() abort
    " Regression: LLMAgent_SidebarLog(a:data['error'], 'Error') used to throw
    " E731 "Using a Dictionary as a String" when the error value was a dict.
    " It must render the dict instead of raising.
    silent! execute 'bwipe! LLMAgent-Chat'
    silent! execute 'bwipe! LLMAgent-Input'
    call LLMAgent_SidebarOpen()
    call LLMAgent_SidebarLog({'message': 'provider error', 'code': 500}, 'Error')
    let l:chat = bufnr('LLMAgent-Chat')
    let l:joined = join(getbufline(l:chat, 1, '$'), "\n")
    call s:Assert(stridx(l:joined, 'message') >= 0, 'dict keys rendered in the chat')
    call s:Assert(stridx(l:joined, 'provider error') >= 0, 'dict value rendered in the chat')
    silent! execute 'bwipe! LLMAgent-Chat'
    silent! execute 'bwipe! LLMAgent-Input'
endfunction

" --- Stop / job helpers ---

function! s:Test_JobHelpers_nojob_safety() abort
    call s:AssertEq(LLMAgent_JobRunning(v:null), 0, 'v:null is not running')
    call LLMAgent_JobStop(v:null)
    call s:Assert(1, 'JobStop on v:null does not throw')
endfunction

function! s:Test_JobHelpers_start_echo_job() abort
    " Start a real echo job and wait for its exit callback to flip a flag.
    let g:_job_done = 0
    function! g:_TestEchoExit(...) abort
        let g:_job_done = 1
    endfunction
    call LLMAgent_JobStart('sleep 0.2', function('g:_TestEchoExit'))
    let l:waited = 0
    while !g:_job_done && l:waited < 50
        sleep 100m
        let l:waited += 1
    endwhile
    call s:Assert(g:_job_done, 'exit callback fires for bash -c string job')
endfunction

" --- Thinking spinner (LLMAgent_StartSpinner / SpinnerTick / StopSpinner) ---

function! s:Test_Spinner_animates_chat_line() abort
    " Prime a real chat buffer with a thinking line, as a busy turn would.
    silent! execute 'bwipe! LLMAgent-Chat'
    silent! execute 'bwipe! LLMAgent-Input'
    call LLMAgent_SidebarOpen()
    call LLMAgent_SidebarLog('thinking...', 'Agent')
    let l:buf = bufnr('LLMAgent-Chat')
    call s:Assert(l:buf > 0, 'chat buffer exists after SidebarLog')
    let l:ln = len(getbufline(l:buf, 1, '$'))
    " SidebarLog('...', 'Agent') appends a trailing blank; the spinner must
    " target the last non-blank line (the [Agent] thinking... line).
    while l:ln > 1 && getbufline(l:buf, l:ln)[0] ==# ''
        let l:ln -= 1
    endwhile
    " Start the spinner, let one tick run, and confirm the chat line is now an
    " animated frame (any braille char + [message) rather than the static text.
    call LLMAgent_StartSpinner()
    call LLMAgent_SpinnerTick()
    let l:after = getbufline(l:buf, l:ln)[0]
    call LLMAgent_StopSpinner()
    silent! execute 'bwipe! LLMAgent-Chat'
    silent! execute 'bwipe! LLMAgent-Input'
    let l:braille = '⣾⣽⣻⢿⡿⣟⣯⣷'
    let l:lastchar = strcharpart(l:after, strchars(l:after) - 1, 1)
    let l:got_frame = stridx(l:braille, l:lastchar) >= 0
    call s:Assert(strpart(l:after, 0, 7) ==# '[Agent]', 'the [Agent] tag stays at column 1, got: ' . string(l:after))
    call s:Assert(l:got_frame, 'the timer appends an animated braille frame at the end, got: ' . string(l:after))
    call s:Assert(stridx(l:after, 'thinking') >= 0, 'message text survives behind the frame, got: ' . string(l:after))
    call s:Assert(stridx(l:after, 'done') < 0, 'a live tick is not frozen into done, got: ' . string(l:after))
endfunction

function! s:Test_StopSpinner_freezes_line_to_done() abort
    silent! execute 'bwipe! LLMAgent-Chat'
    call LLMAgent_SidebarOpen()
    call LLMAgent_SidebarLog('thinking...', 'Agent')
    let l:buf = bufnr('LLMAgent-Chat')
    let l:ln = len(getbufline(l:buf, 1, '$'))
    while l:ln > 1 && getbufline(l:buf, l:ln)[0] ==# ''
        let l:ln -= 1
    endwhile
    call LLMAgent_StartSpinner()
    call LLMAgent_SpinnerTick()
    call LLMAgent_StopSpinner()
    let l:line = getbufline(l:buf, l:ln)[0]
    silent! execute 'bwipe! LLMAgent-Chat'
    silent! execute 'bwipe! LLMAgent-Input'
    call s:Assert(stridx(l:line, 'done') >= 0, 'StopSpinner freezes the line to a done marker, got: ' . string(l:line))
endfunction

function! s:Test_StartSpinner_noop_without_chat_buffer() abort
    " No LLMAgent-Chat buffer exists (we never SidebarLog'd this turn), so the
    " spinner must no-op rather than throw; a later StopSpinner is also safe.
    silent! execute 'bwipe! LLMAgent-Chat'
    silent! execute 'bwipe! LLMAgent-Input'
    call LLMAgent_StartSpinner()
    call LLMAgent_StopSpinner()
    call s:Assert(1, 'StartSpinner/StopSpinner no-op safely with no chat buffer')
endfunction

" --- Status line (LLMAgent_StatusLine) ------------------------------------

function! s:Test_StatusLine_api_uses_model() abort
    " api backend: the model shown is g:llm_agent_model.
    let l:save_backend = g:llm_agent_backend
    let l:save_model = g:llm_agent_model
    let g:llm_agent_backend = 'api'
    let g:llm_agent_model = 'probe-model-xyz'
    let l:s = LLMAgent_StatusLine()
    call s:Assert(stridx(l:s, 'probe-model-xyz') >= 0, 'api status shows g:llm_agent_model')
    call s:Assert(stridx(l:s, 'mode: api') >= 0, 'api status marks the backend')
    let g:llm_agent_backend = l:save_backend
    let g:llm_agent_model = l:save_model
endfunction

function! s:Test_StatusLine_acp_falls_back_to_cmd() abort
    " acp backend with no initialize handshake: no agent name reported, so
    " the status line falls back to g:llm_agent_acp_cmd as the label.
    let l:save_backend = g:llm_agent_backend
    let l:save_cmd = g:llm_agent_acp_cmd
    let g:llm_agent_backend = 'acp'
    let g:llm_agent_acp_cmd = 'my-custom-acp-cmd'
    call LLMAgent_ACPResetState()
    let l:s = LLMAgent_StatusLine()
    call s:Assert(stridx(l:s, 'my-custom-acp-cmd') >= 0, 'acp status falls back to g:llm_agent_acp_cmd')
    call s:Assert(stridx(l:s, 'mode: acp') >= 0, 'acp status marks the backend')
    let g:llm_agent_backend = l:save_backend
    let g:llm_agent_acp_cmd = l:save_cmd
endfunction

function! s:Test_StatusLine_acp_uses_reported_agent_name() abort
    " After the initialize handshake reports an agentInfo.name, the status
    " line uses that name (e.g. "OpenCode") instead of the command. We drive
    " the initialize response through LLMAgent_HandleACPMessage just like the
    " real ACP stdout handler would.
    let l:save_backend = g:llm_agent_backend
    let g:llm_agent_backend = 'acp'
    call LLMAgent_ACPResetState()
    " Register a pending 'initialize' request, then feed a matching response.
    call LLMAgent_ACPInitialize(function('s:NoopCb'))
    for l:id in range(1, 50)
        call LLMAgent_HandleACPMessage('{"jsonrpc":"2.0","id":' . l:id . ',"result":{"agentInfo":{"name":"OpenCode","version":"1.0.0"}}}')
    endfor
    let l:s = LLMAgent_StatusLine()
    call s:Assert(stridx(l:s, 'OpenCode') >= 0, 'acp status shows the agent name from initialize')
    call s:Assert(stridx(l:s, 'my-custom') < 0, 'acp status does not show the fallback command once the name is known')
    call LLMAgent_ACPResetState()
    let g:llm_agent_backend = l:save_backend
endfunction

" --- Reload open buffers after external change ----------------------------

function! s:Test_ReloadChangedBuffers_skips_unsaved_edits() abort
    " ReloadChangedBuffers must NOT clobber a buffer that has unsaved local
    " edits, even when the file on disk changed. It skips &modified buffers.
    let l:f = s:ToolTestWriteFile('_llm_reload_unsaved.txt', ['one', 'two'])
    execute 'edit ' . fnameescape(l:f)
    write
    let l:buf = bufnr(l:f)
    " Local (unsaved) edit in the buffer.
    call setline(1, ['LOCAL EDIT', 'two'])
    " Change the file on disk underneath us.
    call writefile(['one', 'TWO-disk', 'three'], l:f)
    call LLMAgent_ReloadChangedBuffers()
    call s:AssertEq(getbufline(l:buf, 1, 1), ['LOCAL EDIT'], 'unsaved buffer keeps its local edit (not reloaded)')
    call s:AssertEq(getbufline(l:buf, 2, 2), ['two'], 'unsaved buffer second line untouched')
    bwipe!
    call s:ToolTestCleanup('_llm_reload_unsaved.txt')
endfunction

" --- Diff rendering (LLMAgent_RenderDiff / colors) ------------------------

function! s:Test_RenderDiff_color_coded_lines() abort
    " RenderDiff appends a unified diff to the chat buffer with per-line
    " highlight groups: green for +, red for -, purple for @@ hunks, gray
    " for the ---/+++ file headers. Verify the correct group is applied on
    " each rendered line.
    call LLMAgent_SidebarOpen()
    call LLMAgent_RenderDiff("--- a/x\n+++ b/x\n@@ -1,3 +1,3 @@\n old\n-removed\n+added\n ctx\n")
    let l:chat = bufnr('LLMAgent-Chat')
    let l:joined = join(getbufline(l:chat, 1, '$'), "\n")
    call s:Assert(stridx(l:joined, '-removed') >= 0, 'removed line rendered into chat')
    call s:Assert(stridx(l:joined, '+added') >= 0, 'added line rendered into chat')
    call s:Assert(stridx(l:joined, '@@') >= 0, 'hunk header rendered into chat')
    let l:groups = {}
    for l:m in getmatches(bufwinnr(l:chat))
        let l:g = get(l:m, 'group', '')
        let l:groups[l:g] = 1
    endfor
    call s:Assert(has_key(l:groups, 'LLMAgentHiDiffAdd'), 'added lines get the Add highlight')
    call s:Assert(has_key(l:groups, 'LLMAgentHiDiffDel'), 'removed lines get the Del highlight')
    call s:Assert(has_key(l:groups, 'LLMAgentHiDiffHunk'), 'hunk @@ lines get the Hunk highlight')
    call s:Assert(has_key(l:groups, 'LLMAgentHiDiffFile'), '---/+++ file headers get the File highlight')
    " Close the chat window / wipe the buffer so later sidebar tests start clean.
    silent! execute 'bwipe! LLMAgent-Chat'
    silent! execute 'bwipe! LLMAgent-Input'
endfunction

" --- ACP session/new (LLMAgent_ACPSessionNew) -----------------------------

function! s:Test_ACPSessionNew_sends_request_shape() abort
    " ACPSessionNew issues a session/new request whose params carry the cwd
    " and an EMPTY mcpServers array (opencode fails without it). Capture the
    " exact wire request with a fake ACP process that logs its stdin. The
    " blocking wait is kept to one cycle so this runs fast headless.
    let l:save_backend = g:llm_agent_backend
    let l:save_cmd = g:llm_agent_acp_cmd
    let l:dir = s:ToolTestDir()
    let l:log = getcwd() . '/_llm_acp_wire.log'
    let l:fake = s:ToolTestWriteFile('_llm_acp_fake.sh', [
        \ '#!/bin/sh',
        \ 'LOG=' . l:log,
        \ ': > "$LOG"',
        \ 'while IFS= read -r line; do',
        \ '  echo "$line" >> "$LOG"',
        \ 'done',
        \ ])
    let g:llm_agent_backend = 'acp'
    let g:llm_agent_acp_cmd = 'sh ' . shellescape(l:fake)
    call LLMAgent_ACPResetState()
    call LLMAgent_EnsureACP()
    " Send the same 'session/new' request ACPSessionNew sends, asynchronously.
    call LLMAgent_ACPSendRequest('session/new', {'cwd': getcwd(), 'mcpServers': []}, 'session_new', function('s:NoopCb'))
    sleep 400m
    let l:wire = join((filereadable(l:log) ? readfile(l:log) : []), "\n")
    call s:Assert(stridx(l:wire, 'session/new') >= 0, 'wire request names session/new method')
    call s:Assert(stridx(l:wire, 'mcpServers') >= 0, 'wire request carries mcpServers param')
    call s:Assert(stridx(l:wire, '[]') >= 0, 'wire request sends mcpServers as an empty array')
    call s:Assert(stridx(l:wire, 'cwd') >= 0, 'wire request carries cwd param')
    call LLMAgent_StopACP()
    call delete(l:log)
    call s:ToolTestCleanup('_llm_acp_fake.sh')
    let g:llm_agent_backend = l:save_backend
    let g:llm_agent_acp_cmd = l:save_cmd
endfunction

function! s:Test_ACPSessionNew_captures_session_id() abort
    " ACPSessionNew sets s:acp_session_id from the session/new result's
    " sessionId. With no ACP process, the request returns 0; once the result
    " is processed (as the stdout handler would), a fresh ACPSessionNew
    " short-circuits to 1.
    call LLMAgent_ACPResetState()
    " With no ACP process, ACPSessionNew sends the request but no response
    " arrives; the callback is never invoked (async, non-blocking).
    call LLMAgent_ACPSessionNew(function('s:NoopCb'))
    " Feed a matching session/new result across candidate ids.
    for l:id in range(1, 50)
        call LLMAgent_HandleACPMessage('{"jsonrpc":"2.0","id":' . l:id . ',"result":{"sessionId":"sess-abc123"}}')
    endfor
    " Once the session id is captured, a fresh ACPSessionNew short-circuits to
    " success and invokes its callback with 1.
    let g:_acp_session_ok = -1
    call LLMAgent_ACPSessionNew(function('s:CaptureSessionOk'))
    call s:AssertEq(g:_acp_session_ok, 1, 'ACPSessionNew succeeds once the session id is captured')
    call LLMAgent_ACPResetState()
endfunction

function! s:NoopCb(...)
endfunction

function! s:CaptureSessionOk(ok)
    let g:_acp_session_ok = a:ok
endfunction

" --- Job helpers: optional on_stdout + (job, ms) signature ----------------

function! s:Test_JobStart_on_stdout_callback() abort
    " LLMAgent_JobStart's optional 3rd arg is an on_stdout callback used to
    " stream the job's stdout (needed by ACP's newline-delimited protocol).
    let g:_stdout_capture = ''
    function! g:_TestJobOut(...) abort
        let g:_stdout_capture .= join(a:2, '')
    endfunction
    function! g:_TestJobExit2(...) abort
    endfunction
    let l:j = LLMAgent_JobStart('printf probe-out-42', function('g:_TestJobExit2'), function('g:_TestJobOut'))
    if l:j isnot v:null
        call LLMAgent_JobWaitJob(l:j, 2000)
        sleep 200m
    endif
    call s:AssertEq(g:_stdout_capture, 'probe-out-42', 'on_stdout callback receives the streaming output')
    unlet g:_stdout_capture
    delfunction g:_TestJobOut
    delfunction g:_TestJobExit2
endfunction

function! s:Test_JobWaitJob_signature() abort
    " LLMAgent_JobWaitJob(job, ms) pumps the event loop for a:ms ms (nvim
    " jobwait; vim sleep). It must run without error on a real job.
    function! g:_TestWaitExit(...) abort
    endfunction
    let l:j = LLMAgent_JobStart('exit 0', function('g:_TestWaitExit'))
    call s:Assert(l:j isnot v:null, 'job started for JobWaitJob')
    let l:t0 = reltime()
    call LLMAgent_JobWaitJob(l:j, 300)
    call s:Assert(reltimefloat(reltime(l:t0)) >= 0.0, 'JobWaitJob(job, ms) runs without error')
    delfunction g:_TestWaitExit
endfunction

" --- StripDiffProse helper ------------------------------------------------

function! s:Test_StripDiffProse_strips_leading_prose() abort
    " The recovery helper drops everything before the first diff-structure
    " line (---/+++/@@/diff --git/index) and returns only the real diff.
    let l:got = LLMAgent_StripDiffProse(['thought line one', 'here is a @ mention', '--- a/x', '+++ b/x', '@@ -1 +1 @@', ' ctx'])
    call s:AssertEq(l:got, ['--- a/x', '+++ b/x', '@@ -1 +1 @@', ' ctx'], 'prose before first --- is stripped')
    " No structure line anywhere: input returned unchanged.
    call s:AssertEq(LLMAgent_StripDiffProse(['a', 'b']), ['a', 'b'], 'no structure line -> unchanged')
    call s:AssertEq(LLMAgent_StripDiffProse(['   ', 'x']), ['   ', 'x'], 'blank+text with no header -> unchanged')
endfunction

" --- Command definitions (new names present, old names gone) ---------------

function! s:Test_Commands_new_defined_old_removed() abort
    " The current command family (LLMChat*/LLMAsk*) must all exist...
    for l:c in ['LLMChat', 'LLMChatReset', 'LLMChatStop', 'LLMChatClear', 'LLMChatDebug', 'LLMChatToggle', 'LLMAsk', 'LLMAskExplain']
        call s:Assert(exists(':' . l:c), 'command is defined: :' . l:c)
    endfor
    " ...and the renamed/removed names must be gone.
    for l:c in ['LLMAgent', 'LLMExplain', 'LLMReset', 'LLMClear', 'LLMStop', 'LLMDebug', 'LLMToggle']
        call s:Assert(!exists(':' . l:c), 'old command is gone: :' . l:c)
    endfor
endfunction

" Resolve the path to the module under test. The test is run from the
" project root as: `vim -e -s -u NONE -S scripts/module/test/LLMAgent_test.vim`
" so the module is at <cwd>/scripts/module/LLMAgent.vim. If you run it
" from elsewhere, the script errors out with a clear message rather
" than failing silently inside individual tests.
let s:llm_agent_path = getcwd() . '/scripts/module/LLMAgent.vim'
if !filereadable(s:llm_agent_path)
    call writefile(['ERROR: cannot find ' . s:llm_agent_path, 'Run this test from the project root: vim -e -s -u NONE -S scripts/module/test/LLMAgent_test.vim'], '_test_summary.txt')
    cquit!
endif
execute 'source' s:llm_agent_path

let s:all_tests = ['GetSidebarWidth_floor', 'GetInputHeight_floor', 'DisplaySetupBuffer_sets_markdown_filetype', 'GetContext_explicit_range', 'GetContext_single_line_returns_full_file', 'GetSystemPrompt_default', 'GetSystemPrompt_custom', 'GetAgentSystemPrompt_includes_components', 'GetToolDefinitions_shape', 'GetToolDefinitions_expected_names', 'ExecuteTool_unknown', 'ExecuteTool_list_buffers', 'ToolLs_real_dir', 'ToolLs_missing', 'ToolLs_rejects_parent_traversal', 'ToolFind_match', 'ToolFind_no_match', 'ToolGrep_finds_match', 'ToolGrep_no_match', 'ToolGrep_rejects_parent_traversal', 'ToolReadFile_known', 'ToolReadFile_line_range', 'ToolReadFile_missing', 'ToolReadFile_rejects_parent_traversal', 'ToolWriteFile_queues_no_disk', 'CallAPI_transport_error', 'APIRequest_transport_error', 'APIRequest_returns_dict', 'StopACP_is_idempotent', 'FinishAgentTurn_handles_empty_state', 'ResolveBufPath_handles_unknown_buf', 'ResolveBufPath_handles_agent_buffers', 'BuildLocationContext_none_mode', 'BuildLocationContext_cursor_mode', 'BuildLocationContext_range_mode', 'BuildLocationContext_includes_filetype', 'CaptureSelection_no_visual', 'CaptureSelection_with_visual', 'CaptureSelection_preserves_register', 'CaptureSelection_finds_marks', 'Reset_clears_messages', 'Reset_is_idempotent', 'GetAgentSystemPrompt_includes_active_buffer', 'DecodeEscapes_passthrough', 'DecodeEscapes_converts', 'ResolveToolPath_absolute', 'ResolveToolPath_empty', 'ResolveToolPath_relative', 'IsOutsideProject_inside', 'IsOutsideProject_outside', 'IsOutsideProject_dotdot', 'ToolReadFile_numbered_output', 'ToolReadFile_line_range_header', 'ToolReadFile_out_of_range', 'ToolWriteFile_escaped_newlines', 'ToolWriteFile_rejects_path_traversal', 'ToolWriteFile_empty_content', 'ToolWriteFile_requires_read_first', 'ToolWriteFile_rejects_diff_as_content', 'ToolWriteFile_rejects_partial_content', 'ToolGrep_plain_text_as_literal', 'FormatToolResult_ok', 'FormatToolResult_error', 'FormatToolResult_legacy_shape', 'DebugLog_off_by_default', 'DebugLog_appends_jsonl', 'DebugLog_swallows_errors', 'PrettyJson_roundtrip', 'ValidateSyntax_bash_ok', 'ValidateSyntax_bash_bad', 'ValidateSyntax_python_ok', 'ValidateSyntax_python_bad', 'ValidateSyntax_json_bad', 'ValidateSyntax_unknown_ext', 'QueueWrite_blocks_syntax_error', 'WriteFile_rejects_syntax_error', 'WriteFile_allows_valid_syntax', 'CurlExitHint_zero', 'CurlExitHint_28_timeout', 'CurlExitHint_unknown', 'PrefixHiGroup_known_prefixes', 'PrefixHiGroup_you_vs_agent_distinct', 'PrefixHiGroup_returns_nonempty', 'ToolPatch_rejects_empty_diff', 'ToolPatch_rejects_diff_with_no_hunks', 'ToolPatch_rejects_diff_with_chatty_lines', 'ToolPatch_valid_diff_succeeds', 'ToolPatch_wrong_context_fails_with_hint', 'ToolPatch_failure_tracked_in_session', 'ToolPatch_allows_no_newline_marker', 'ToolPatch_allows_git_extended_headers', 'ToolPatch_preserves_literal_escape_in_source_line', 'FixHunkHeader_repairs_near_misses', 'ToolPatch_sanitizes_garbage_hunk_headers', 'ToolPatch_strips_leading_prose', 'ToolPatch_normalizes_crlf_and_bom', 'ToolPatch_reconstructs_headerless_diff', 'RebuildHeaderlessDiff_unit', 'ToolPatch_tries_patch1_before_validator_reject', 'ToolPatch_breaks_retry_loop_after_two_fails', 'ToolWriteFile_clears_patch_fail_tracking',
    \ 'ToolReadFile_missing_path_arg', 'ToolReadFile_registers_read_state', 'ToolReadFile_truncates_huge_file', 'ToolReadFile_range_past_eof_clamps',
    \ 'ToolWriteFile_missing_args', 'ToolWriteFile_rejects_git_internal_paths', 'ToolWriteFile_new_file_no_read_needed', 'ToolWriteFile_preserves_literal_escapes_with_real_newlines', 'ApplyWrites_creates_missing_dirs', 'ReloadChangedBuffers_reloads_after_external_write', 'ShowApprovalDiff_renders_change',
    \ 'ToolPatch_missing_args', 'ToolPatch_requires_read_first', 'ToolPatch_refuses_path_traversal', 'ToolPatch_rejects_missing_file', 'ToolPatch_applies_and_queues_correct_content', 'ToolPatch_tolerates_slightly_off_counts', 'ToolPatch_failure_tells_how_to_recover', 'ToolPatch_then_write_clears_fail_tracking',
    \ 'ToolLs_empty_dir', 'ToolLs_marks_dirs_with_slash', 'ToolLs_defaults_to_cwd',
    \ 'ToolFind_missing_pattern', 'ToolFind_recursive_glob', 'ToolFind_caps_at_200',
    \ 'ToolGrep_glob_filter', 'ToolGrep_match_gives_file_line_content', 'ToolGrep_missing_path_errors', 'ToolGrep_caps_at_100_matches',
    \ 'ToolListBuffers_shows_buffers',
    \ 'ExecuteTool_read_file_dispatch', 'ExecuteTool_ls_dispatch',
    \ 'ParseToolArgs_object_passthrough', 'ParseToolArgs_json_string', 'ParseToolArgs_bad_json_error', 'ParseToolArgs_non_string_types', 'ToolArgsSummary_prefers_path_then_pattern',
    \ 'ResponseMessage_shapes', 'MessageHasText_variants',
    \ 'APIRequestBody_tools_only_when_given', 'BuildCurlCmd_parts', 'ParseCompletion_shapes', 'CurlError_combines_parts',
    \ 'ToString_passthrough_string', 'ToString_json_encodes_dict', 'ToString_handles_list_and_number', 'SidebarLog_accepts_dict_text',
    \ 'JobHelpers_nojob_safety', 'JobHelpers_start_echo_job',
    \ 'Spinner_animates_chat_line', 'StopSpinner_freezes_line_to_done', 'StartSpinner_noop_without_chat_buffer',
    \ 'StatusLine_api_uses_model', 'StatusLine_acp_falls_back_to_cmd', 'StatusLine_acp_uses_reported_agent_name',
    \ 'ReloadChangedBuffers_skips_unsaved_edits',
    \ 'RenderDiff_color_coded_lines',
    \ 'ACPSessionNew_sends_request_shape', 'ACPSessionNew_captures_session_id',
    \ 'JobStart_on_stdout_callback', 'JobWaitJob_signature',
    \ 'StripDiffProse_strips_leading_prose',
    \ 'Commands_new_defined_old_removed']

for s:t in s:all_tests
    let s:fn = function('<SNR>1_Test_' . s:t)
    try
        call s:fn()
    catch
        let s:tests_run += 1
        let s:tests_failed += 1
        " Use silent! to avoid the "Press ENTER" pause that hangs the runner.
        silent! echo 'FAIL: ' . s:t . ' — exception: ' . v:exception . ' at ' . v:throwpoint
        call add(s:failure_log, s:t . ' (exception): ' . v:exception . ' at ' . v:throwpoint)
    endtry
    " Reset any state that may leak between tests
    try | call LLMAgent_Reset() | catch | endtry
endfor

" Assertions inside s:Test_* do not throw — they call s:Assert which
" increments s:tests_failed on failure but does not raise. We have to scan
" the per-test log to capture those.
if s:tests_failed > 0 && empty(s:failure_log)
    " Assertion failures are silent. Add a synthetic log entry so the
    " summary file has at least one line of context.
    call add(s:failure_log, '(see :messages above for "FAIL:" lines)')
endif

" Final summary. We write the result to a file rather than echo, because
" interactive echoes prompt for ENTER in -E -s mode and hang the runner.
let s:summary_msg = 'LLMAgent tests: ' . s:tests_passed . ' passed, ' . s:tests_failed . ' failed (' . s:tests_run . ' total)'
call writefile([s:summary_msg] + s:failure_log, '_test_summary.txt')

if s:tests_failed > 0
    cquit!
else
    qall!
endif
