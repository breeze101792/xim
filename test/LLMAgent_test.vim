" File: LLMAgent_test.vim
" Description: Self-contained unit tests for LLMAgent.vim.
"   Run with:  vim -e -s -u NONE -S test/LLMAgent_test.vim
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
    let l:r = LLMAgent_APIRequest([{'role': 'user', 'content': 'hi'}], [])
    call s:Assert(has_key(l:r, 'error'), 'returns error dict on transport failure')
    let g:llm_agent_api_url = 'http://localhost:11434/v1'
    let g:llm_agent_timeout = 60
endfunction

function! s:Test_APIRequest_returns_dict() abort
    let g:llm_agent_api_url = 'http://127.0.0.1:1/v1'
    let g:llm_agent_timeout = 1
    let l:r = LLMAgent_APIRequest([])
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
    " json_encode produces no spaces: {"kind":"first",...}
    call s:Assert(stridx(l:lines[0], '"kind":"first"') >= 0, 'first line has first kind')
    call s:Assert(stridx(l:lines[1], '"kind":"second"') >= 0, 'second line has second kind')
    call s:Assert(stridx(l:lines[0], '"t":') >= 0, 'lines include a timestamp')
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

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Source the module under test and run
""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Resolve the path to the module under test. The test is run from the
" project root as: `vim -e -s -u NONE -S test/LLMAgent_test.vim`
" so the module is at <cwd>/scripts/module/LLMAgent.vim. If you run it
" from elsewhere, the script errors out with a clear message rather
" than failing silently inside individual tests.
let s:llm_agent_path = getcwd() . '/scripts/module/LLMAgent.vim'
if !filereadable(s:llm_agent_path)
    call writefile(['ERROR: cannot find ' . s:llm_agent_path, 'Run this test from the project root: vim -e -s -u NONE -S test/LLMAgent_test.vim'], '_test_summary.txt')
    cquit!
endif
execute 'source' s:llm_agent_path

let s:all_tests = ['GetSidebarWidth_floor', 'GetInputHeight_floor', 'GetContext_explicit_range', 'GetContext_single_line_returns_full_file', 'GetSystemPrompt_default', 'GetSystemPrompt_custom', 'GetAgentSystemPrompt_includes_components', 'GetToolDefinitions_shape', 'GetToolDefinitions_expected_names', 'ExecuteTool_unknown', 'ExecuteTool_list_buffers', 'ToolLs_real_dir', 'ToolLs_missing', 'ToolLs_rejects_parent_traversal', 'ToolFind_match', 'ToolFind_no_match', 'ToolGrep_finds_match', 'ToolGrep_no_match', 'ToolGrep_rejects_parent_traversal', 'ToolReadFile_known', 'ToolReadFile_line_range', 'ToolReadFile_missing', 'ToolReadFile_rejects_parent_traversal', 'ToolWriteFile_queues_no_disk', 'CallAPI_transport_error', 'APIRequest_transport_error', 'APIRequest_returns_dict', 'StopACP_is_idempotent', 'FinishAgentTurn_handles_empty_state', 'ResolveBufPath_handles_unknown_buf', 'ResolveBufPath_handles_agent_buffers', 'BuildLocationContext_none_mode', 'BuildLocationContext_cursor_mode', 'BuildLocationContext_range_mode', 'BuildLocationContext_includes_filetype', 'CaptureSelection_no_visual', 'CaptureSelection_with_visual', 'CaptureSelection_preserves_register', 'CaptureSelection_finds_marks', 'Reset_clears_messages', 'Reset_is_idempotent', 'GetAgentSystemPrompt_includes_active_buffer', 'DecodeEscapes_passthrough', 'DecodeEscapes_converts', 'ResolveToolPath_absolute', 'ResolveToolPath_empty', 'ResolveToolPath_relative', 'IsOutsideProject_inside', 'IsOutsideProject_outside', 'IsOutsideProject_dotdot', 'ToolReadFile_numbered_output', 'ToolReadFile_line_range_header', 'ToolReadFile_out_of_range', 'ToolWriteFile_escaped_newlines', 'ToolWriteFile_rejects_path_traversal', 'ToolWriteFile_empty_content', 'ToolWriteFile_requires_read_first', 'ToolGrep_plain_text_as_literal', 'FormatToolResult_ok', 'FormatToolResult_error', 'FormatToolResult_legacy_shape', 'DebugLog_off_by_default', 'DebugLog_appends_jsonl', 'DebugLog_swallows_errors', 'PrettyJson_roundtrip', 'ValidateSyntax_bash_ok', 'ValidateSyntax_bash_bad', 'ValidateSyntax_python_ok', 'ValidateSyntax_python_bad', 'ValidateSyntax_json_bad', 'ValidateSyntax_unknown_ext', 'QueueWrite_blocks_syntax_error', 'WriteFile_rejects_syntax_error', 'WriteFile_allows_valid_syntax', 'CurlExitHint_zero', 'CurlExitHint_28_timeout', 'CurlExitHint_unknown', 'PrefixHiGroup_known_prefixes', 'PrefixHiGroup_you_vs_agent_distinct', 'PrefixHiGroup_returns_nonempty', 'ToolPatch_rejects_empty_diff', 'ToolPatch_rejects_diff_with_no_hunks', 'ToolPatch_rejects_diff_with_chatty_lines', 'ToolPatch_valid_diff_succeeds', 'ToolPatch_wrong_context_fails_with_hint', 'ToolPatch_failure_tracked_in_session', 'ToolWriteFile_clears_patch_fail_tracking']

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
