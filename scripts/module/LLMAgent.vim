" File: LLMAgent.vim
" Description: AI-powered code assistant with a chat sidebar and one-shot
" queries. Two command families:
"   LLMChat  - multi-turn chat in the sidebar with tool-use (read_file,
"              write_file, patch, ls, find, grep, list_buffers)
"   LLMAsk   - one-shot free-form question / request
"   LLMAskExplain - one-shot: explain the selected code / word under cursor
"
" Backends (g:llm_agent_backend):
"   'api' (default) - OpenAI-compatible API with function-calling tools.
"                     Model set with g:llm_agent_model.
"   'acp'           - ACP (Agent Client Protocol) JSON-RPC over stdio.
"                     Compatible ACP tools:
"                       - Claude: npx -y @agentclientprotocol/claude-agent-acp
"                       - Claude: npx -y claude-code-acp (Pro/Max subscription)
"                       - Gemini: gemini --experimental-acp -p ""  (built-in)
"                       - Copilot: copilot --acp --stdio          (built-in)
"                       - OpenCode: opencode acp
"
" Control commands:
"   :LLMChatReset   - wipe in-memory conversation state (keep the buffer)
"   :LLMChatStop    - cancel an in-flight turn
"   :LLMChatClear   - clear the chat buffer display
"   :LLMChatDebug   - toggle/set the request/response debug log
"   :LLMChatToggle  - open/close the sidebar
"
" Features:
"   - Both writes and patches are QUEUED and shown as a color-coded diff for
"     approval before anything touches disk.
"   - patch tolerates messy model output (headerless @@, CRLF, BOM, unicode,
"     prose noise) and defaults to patch for small edits, write_file for
"     large/structural changes.
"   - After an ACP turn the agent writes files directly, so open buffers are
"     automatically reloaded from disk.
"
" Dependencies: curl (for API mode), Node.js (for claude-agent-acp)
" Supported: Vim 8+, Neovim

" This file uses backslash line continuations; make sure they parse
" regardless of the user's 'cpoptions' (standard plugin pattern: drop 'C'
" while sourcing, restore at the bottom of the file).
let s:save_cpo = &cpoptions
set cpoptions-=C

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup LLMAgentGroup
    autocmd!
    autocmd VimResized * call LLMAgent_OnResize()
    autocmd VimLeavePre * call LLMAgent_Stop() | call LLMAgent_StopACP()
augroup END

" Sidebar log prefix colors. The mapping in LLMAgent_PrefixHiGroup returns
" these custom group names; the colors below are set explicitly so the
" look is the same regardless of the user's :colorscheme.
"   You   -> green  (user input)
"   Agent -> purple (LLM output)
"   Error -> red    (tool/API failures)
"   Warning -> yellow (non-fatal issues)
"   other -> gray   (Tool, Result, System, anything else)
hi default LLMAgentHiYou     ctermfg=82  guifg=#a6e3a1
hi default LLMAgentHiAgent   ctermfg=141 guifg=#cba6f7
hi default LLMAgentHiError   ctermfg=203 guifg=#f38ba8
hi default LLMAgentHiWarning ctermfg=228 guifg=#f9e2af
hi default LLMAgentHiOther   ctermfg=246 guifg=#a6adc8
" Diff preview colors: green for added lines, red for removed lines, and a
" muted header for the @@ hunk markers and file header.
hi default LLMAgentHiDiffAdd    ctermfg=114 guifg=#a6e3a1
hi default LLMAgentHiDiffDel    ctermfg=203 guifg=#f38ba8
hi default LLMAgentHiDiffHunk   ctermfg=141 guifg=#cba6f7
hi default LLMAgentHiDiffFile   ctermfg=246 guifg=#a6adc8

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Variables
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:llm_agent_backend          = get(g:, 'llm_agent_backend', 'api')
let g:llm_agent_api_url          = get(g:, 'llm_agent_api_url', 'http://localhost:11434/v1')
let g:llm_agent_api_key          = get(g:, 'llm_agent_api_key', '')
let g:llm_agent_model            = get(g:, 'llm_agent_model', 'deepseek-v4-flash:cloud')
" let g:llm_agent_model          = get(g:, 'llm_agent_model', 'gemma4:12b-it-qat')
let g:llm_agent_streaming        = get(g:, 'llm_agent_streaming', 0)
let g:llm_agent_enable_keymaps   = get(g:, 'llm_agent_enable_keymaps', 0)
let g:llm_agent_system_prompt    = get(g:, 'llm_agent_system_prompt', '')
let g:llm_agent_timeout          = get(g:, 'llm_agent_timeout', 180)
let g:llm_agent_prompt_write     = get(g:, 'llm_agent_prompt_write', 'Write code for the following request. Return ONLY the code, no markdown fences, no explanation:')
let g:llm_agent_prompt_explain   = get(g:, 'llm_agent_prompt_explain', 'Explain the following code concisely:')
let g:llm_agent_prompt_fix       = get(g:, 'llm_agent_prompt_fix', 'Fix any bugs or issues in the following code. Return ONLY the corrected code, no markdown fences, no explanation:')
let g:llm_agent_prompt_refactor  = get(g:, 'llm_agent_prompt_refactor', 'Refactor the following code to be cleaner and more efficient. Return ONLY the refactored code, no markdown fences, no explanation:')
let g:llm_agent_tool_max_rounds  = get(g:, 'llm_agent_tool_max_rounds', 30)
let g:llm_agent_tool_confirm     = get(g:, 'llm_agent_tool_confirm', 1)
let g:llm_agent_sidebar          = get(g:, 'llm_agent_sidebar', 'right')
let g:llm_agent_acp_cmd          = get(g:, 'llm_agent_acp_cmd', 'opencode acp')
let g:llm_agent_acp_auto_approve = get(g:, 'llm_agent_acp_auto_approve', 0)
" Example: use opencode as the ACP backend (comment out the default above and
" uncomment one of these):
"   let g:llm_agent_backend = 'acp'
"   let g:llm_agent_acp_cmd = 'opencode acp'
"   let g:llm_agent_acp_cmd = 'npx -y @agentclientprotocol/claude-agent-acp'
" Debug mode. When enabled, every API request and response is appended to
" g:llm_agent_debug_file as JSON, one event per line. You can then share
" the log to debug why the LLM is misbehaving. Default off (no log file).
let g:llm_agent_debug              = get(g:, 'llm_agent_debug', 0)
let g:llm_agent_debug_file        = get(g:, 'llm_agent_debug_file', '/tmp/LLMAgent_Debug.log')

function! LLMAgent_GetSidebarWidth()
    return max([40, float2nr(&columns * 0.3)])
endfunction

function! LLMAgent_GetInputHeight()
    return max([5, min([10, float2nr(&lines * 0.15)])])
endfunction

""""    Editor-compat job helpers (vim 8 job API vs nvim job API)

" Start a background command. a:cmd is a shell command string; it is always
" run through `bash -c` as ONE argument (a List argv, so no tokenization):
"   - Vim's job_start(string) word-splits and execs directly — no shell —
"     so redirects like `2>` would be passed to the program as literal argv.
"   - Nvim's jobstart(string) runs via the shell, but the List form works
"     there too and keeps both editors identical.
" a:on_stdout is optional; when given, the job's stdout is streamed to it
" (needed for ACP's newline-delimited JSON protocol). Returns a job handle
" or v:null if the job could not be started.
function! LLMAgent_JobStart(cmd, on_exit, ...)
    let l:OnStdout = get(a:, 1, '')
    let l:argv = ['bash', '-c', a:cmd]
    if has('nvim')
        let l:opts = {'on_exit': a:on_exit}
        if !empty(l:OnStdout)
            let l:opts['on_stdout'] = l:OnStdout
        endif
        let l:job = jobstart(l:argv, l:opts)
        return (type(l:job) == v:t_number && l:job > 0) ? l:job : v:null
    endif
    let l:opts = {'exit_cb': a:on_exit, 'mode': 'nl'}
    if !empty(l:OnStdout)
        let l:opts['out_cb'] = l:OnStdout
    endif
    let l:job = job_start(l:argv, l:opts)
    return (job_status(l:job) ==# 'fail') ? v:null : l:job
endfunction

" True if the job handle is a running process. Nvim stores a channel id
" (number); Vim stores a Job object, so guard the type before calling
" job_status (a direct call on a number throws E121/E1176 under Vim).
function! LLMAgent_JobRunning(job)
    if a:job is v:null
        return 0
    endif
    if has('nvim')
        return type(a:job) == v:t_number && a:job > 0
    endif
    return type(a:job) == v:t_job && job_status(a:job) ==# 'run'
endfunction

" Stop a job. Safe to call on stale/-1/v:null handles; failures are
" swallowed (the process may have exited between the check and the stop).
function! LLMAgent_JobStop(job)
    if has('nvim')
        if type(a:job) == v:t_number && a:job > 0
            try | call jobstop(a:job) | catch | endtry
        endif
    else
        if type(a:job) == v:t_job
            try | call job_stop(a:job) | catch | endtry
        endif
    endif
endfunction

" Pump the event loop while a callback-driven job works. Nvim needs
" jobwait(); Vim dispatches job callbacks on timers/input, so sleep.
function! LLMAgent_JobWaitJob(job, ms)
    if has('nvim')
        call jobwait([a:job], a:ms)
    else
        execute 'sleep ' . a:ms . 'm'
    endif
endfunction

" Script-local state for multi-turn conversation
let s:llm_agent_messages = []
let s:llm_agent_write_list = []
let s:llm_agent_response_text = ''
" Paths that the LLM has just tried (and failed) to patch in this
" conversation. Used to strongly nudge the next turn toward write_file.
let s:llm_agent_patch_fails = {}

" The diff text that last failed for each path. The retry-loop breaker
    " only refuses an identical re-submission of a diff that failed several
    " times — a fresh, different diff is always allowed through so a good
    " attempt can clear the tracker instead of being locked out.
let s:llm_agent_patch_fail_diffs = {}

" Bump the patch-failure counter for a path and remember the diff that
" failed, so the retry-loop breaker at LLMAgent_ToolPatch can refuse only
" an identical re-submission.
function! LLMAgent_RecordPatchFail(path, diff)
    let s:llm_agent_patch_fails[a:path] = get(s:llm_agent_patch_fails, a:path, 0) + 1
    let s:llm_agent_patch_fail_diffs[a:path] = a:diff
endfunction

" Paths that the LLM has read in this conversation. patch and write_file
" check this to enforce "read before modify".
let s:llm_agent_read_files = {}

" ACP (Agent Client Protocol) state
" s:acp_job_id is a job handle: nvim channel id (number) or Vim Job object;
" v:null when idle. Never compare it with numbers — use LLMAgent_ACPOpen().
let s:acp_job_id = v:null
let s:acp_session_id = ''
let s:acp_pending_reqs = {}
" Responses to requests we sent, keyed by request id. The blocking
" LLMAgent_ACPRequest loop consumes these.
let s:acp_completed = {}
let s:acp_prompt_resolved = 0
" Set to 1 once the ACP initialize/initialized handshake completes. The
" server refuses session/new until this is done.
let s:acp_initialized = 0
" Agent name reported by the ACP server in the initialize response
" (e.g. "OpenCode", "Claude Code"). Used in the status line.
let s:acp_agent_name = ''
let s:acp_write_list = []
let s:acp_response_text = ''
let s:acp_turn_error = ''
let s:acp_next_req_id = 1
let s:acp_terminal_output = ''

" Async API (curl) job state for the 'api' backend. While a request is in
" flight s:llm_agent_api_job is a live job handle (nvim: channel id number,
" vim: Job object) and the entry points refuse to start a new turn (use
" :LLMStop to cancel). v:null means idle. The callback is a Funcref invoked
" with the parsed response dict (same shape LLMAgent_CallAPI returns).
" NOTE: never compare the job handle with `> 0` — under Vim it is a Job
" object and any arithmetic comparison throws E910.
let s:llm_agent_api_job = v:null
let s:llm_agent_api_cb = ''
let s:llm_agent_api_outfile = ''
let s:llm_agent_api_errfile = ''
let s:llm_agent_api_bodyfile = ''
" Agent tool-loop state (was implicit in the old synchronous for-loop).
let s:llm_agent_turn = 0
let s:llm_agent_tools = []
" Consecutive empty/unproductive turns in the tool loop. Used to nudge the
" model to recover instead of silently ending the turn, capped so it can't
" loop forever. Reset on any productive turn (tool calls or non-empty text).
let s:llm_agent_empty_count = 0
" Stashed display params for the single-shot (ask/explain/write) path, used by
" LLMAgent_OnSingleResponse after the async response arrives.
let s:llm_agent_single_ctx = {}

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Tool Definitions (OpenAI function-calling format)
""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! LLMAgent_GetToolDefinitions()
    let l:read_params = {'type': 'object', 'properties': {'path': {'type': 'string', 'description': 'Path to the file. Absolute, ~/-relative, or relative to the working buffer.'}, 'start_line': {'type': 'integer', 'description': 'Optional: 1-based start line.'}, 'end_line': {'type': 'integer', 'description': 'Optional: 1-based inclusive end line. Omit for the whole file.'}}, 'required': ['path']}
    let l:read = {'type': 'function', 'function': {'name': 'read_file', 'description': 'Read file contents. By default returns the whole file with every line numbered (e.g. "  42| code"). For large files, pass start_line and end_line. Output is truncated past 50K characters.', 'parameters': l:read_params}}

    let l:write_params = {'type': 'object', 'properties': {'path': {'type': 'string', 'description': 'Path to the file. Same rules as read_file.'}, 'content': {'type': 'string', 'description': 'The COMPLETE new file content. Use real newlines in the JSON value; literal \n is also accepted and will be decoded.'}}, 'required': ['path', 'content']}
    let l:write = {'type': 'function', 'function': {'name': 'write_file', 'description': 'Create or fully rewrite a file. Use for new files, large/structural changes, or when more than ~10 lines change. REPLACES the entire file with the content you send. The write is QUEUED — the file is NOT modified until the user approves the change in the sidebar. Returns the resolved path and a byte/line count.', 'parameters': l:write_params}}

    let l:ls_params = {'type': 'object', 'properties': {'path': {'type': 'string', 'description': 'Directory to list. Defaults to the project root. Relative paths are resolved against the working buffer.'}}, 'required': []}
    let l:ls = {'type': 'function', 'function': {'name': 'ls', 'description': 'List a directory. Entries ending in "/" are subdirectories. Returns at most a few hundred entries.', 'parameters': l:ls_params}}

    let l:find_params = {'type': 'object', 'properties': {'pattern': {'type': 'string', 'description': 'Glob pattern relative to the project root, e.g. "**/*.py", "src/**/*.go", "scripts/module/*"'}}, 'required': ['pattern']}
    let l:find = {'type': 'function', 'function': {'name': 'find', 'description': 'Find files by glob. Recursive globs need "**". Returns up to 200 matches.', 'parameters': l:find_params}}

    let l:grep_params = {'type': 'object', 'properties': {'pattern': {'type': 'string', 'description': 'Vim regex (use \\V to match literally, \\C for case-sensitive). Plain text is fine and will be treated as a literal substring.'}, 'path': {'type': 'string', 'description': 'Directory to search. Defaults to project root.'}, 'glob': {'type': 'string', 'description': 'File glob to restrict to, e.g. "*.py" or "scripts/module/*". Default "*".'}}, 'required': ['pattern']}
    let l:grep = {'type': 'function', 'function': {'name': 'grep', 'description': 'Grep a Vim regex inside files. Returns file:line:content triples. Stops after 100 matches.', 'parameters': l:grep_params}}

    let l:patch_params = {'type': 'object', 'properties': {'path': {'type': 'string', 'description': 'Path to the file to patch.'}, 'diff': {'type': 'string', 'description': 'A unified diff in diff -u format with @@ ... @@ context markers. Real newlines are required.'}}, 'required': ['path', 'diff']}
    let l:patch = {'type': 'function', 'function': {'name': 'patch', 'description': 'Apply a unified diff to an existing file. Default choice for small-to-medium edits (up to ~10 lines or a few hunks). The tool sanitizes messy diffs (headerless @@, CRLF, BOM) so it is more forgiving than raw patch(1). If it fails, fall back to write_file with the FULL new file content.', 'parameters': l:patch_params}}

    let l:list_buffers_params = {'type': 'object', 'properties': {}, 'required': []}
    let l:list_buffers = {'type': 'function', 'function': {'name': 'list_buffers', 'description': 'List all open Vim buffers by number and name.', 'parameters': l:list_buffers_params}}

    return [l:read, l:write, l:ls, l:find, l:grep, l:patch, l:list_buffers]
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Private Functions - Utility
""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! LLMAgent_GetContext(line1, line2)
    " Get context from range, or fall back to entire file
    if a:line1 != a:line2
        return join(getline(a:line1, a:line2), "\n")
    endif
    return join(getline(1, '$'), "\n")
endfunction

" Append one JSON-line event to the debug log, if g:llm_agent_debug is on.
" a:event is a dict; we add a timestamp, then serialize. Failures to
" write are swallowed silently — debug logging must never break the agent.
function! LLMAgent_DebugLog(event)
    if !g:llm_agent_debug || empty(g:llm_agent_debug_file)
        return
    endif
    let l:event = copy(a:event)
    let l:event.t = strftime('%Y-%m-%dT%H:%M:%S')
    try
        call writefile([json_encode(l:event)], g:llm_agent_debug_file, 'a')
    catch
        " Swallow — debug logging must not affect the agent.
    endtry
endfunction

" One-line api_request debug event (model, url, counts, full body). Used by
" both the sync and async request paths so the log shape stays identical.
function! LLMAgent_DebugLogApiRequest(body_json, tools)
    if !g:llm_agent_debug || empty(g:llm_agent_debug_file)
        return
    endif
    let l:url = g:llm_agent_api_url . '/chat/completions'
    call LLMAgent_DebugLog({
        \ 'kind': 'api_request',
        \ 'model': g:llm_agent_model,
        \ 'url': l:url,
        \ 'timeout': g:llm_agent_timeout,
        \ 'request_body': LLMAgent_PrettyJson(a:body_json),
        \ 'tools_count': len(a:tools),
        \ })
endfunction

" Debug JSON view: pretty-print a JSON string for human reading.
function! LLMAgent_PrettyJson(s)
    if empty(a:s)
        return ''
    endif
    try
        return json_encode(json_decode(a:s))
    catch
        return a:s
    endtry
endfunction

" Validate the proposed file content for the given path. Returns '' on
" success, or a short error message describing the syntax problem. This is
" a safety net: the LLM often produces syntactically invalid code (e.g.
" shell scripts with multi-line strings that bash can't parse). We only
" check filetypes where a fast, reliable validator exists in the system
" PATH; for everything else, we trust the LLM.
function! LLMAgent_ValidateFileSyntax(path, content)
    if empty(a:content)
        return ''
    endif
    " Decide the filetype from the extension (the LLM probably didn't set
    " filetype on the buffer).
    let l:ext = fnamemodify(a:path, ':e')
    if l:ext ==# 'sh' || l:ext ==# 'bash' || l:ext ==# 'zsh' || l:ext ==# 'ksh'
        if !executable('bash')
            return ''
        endif
        " bash -n parses without executing. We must stage the file in a
        " temp location (it isn't on disk yet) and feed the content via
        " stdin redirection, since bash -n requires a real file.
        let l:tmp = tempname() . '.' . l:ext
        try
            call writefile(split(a:content, "\n", 1), l:tmp)
        catch
            return ''
        endtry
        let l:out = system('bash -n ' . shellescape(l:tmp) . ' 2>&1')
        call delete(l:tmp)
        if v:shell_error != 0
            " Trim the noisy temp-file path from the error.
            let l:out = substitute(l:out, escape(l:tmp, '/\') . ': ', '', 'g')
            " Strip leading "line N: " prefixes that bash emits, since
            " they're noise; the message we keep is the actual reason.
            let l:lines = split(l:out, "\n")
            " Find the first line with the word "syntax error" / "unexpected".
            let l:short = ''
            for l:line in l:lines
                if l:line =~? 'syntax error\|unexpected'
                    let l:short = l:line
                    break
                endif
            endfor
            if empty(l:short)
                let l:short = l:lines[0]
            endif
            return l:short
        endif
        return ''
    elseif l:ext ==# 'py'
        if !executable('python3')
            return ''
        endif
        let l:tmp = tempname() . '.py'
        try
            call writefile(split(a:content, "\n", 1), l:tmp)
        catch
            return ''
        endtry
        let l:out = system('python3 -m py_compile ' . shellescape(l:tmp) . ' 2>&1')
        call delete(l:tmp)
        if v:shell_error != 0
            let l:out = substitute(l:out, '\s*\^+\s*$', '', '')
            let l:out = substitute(l:out, escape(l:tmp, '/\') . ':', 'line', 'g')
            return l:out
        endif
        return ''
    elseif l:ext ==# 'lua' || l:ext ==# 'json'
        " JSON has a built-in validator in vim via json_decode.
        if l:ext ==# 'json'
            try
                call json_decode(a:content)
            catch
                return 'JSON parse error: ' . v:exception
            endtry
        endif
        " Lua: skip (no reliable validator without `luac`).
    endif
    return ''
endfunction

" Queue a write for the user's approval, after syntax-validating the
" content. Returns '' on success (and adds the entry to
" s:llm_agent_write_list). On failure returns an error message; the
" entry is NOT added.
function! LLMAgent_QueueWrite(path, content)
    let l:syntax_err = LLMAgent_ValidateFileSyntax(a:path, a:content)
    if !empty(l:syntax_err)
        return 'syntax check failed for ' . a:path . ': ' . l:syntax_err . '  The file was NOT queued. Fix the syntax and call write_file again.'
    endif
    call add(s:llm_agent_write_list, {'path': a:path, 'content': a:content})
    " A successful write means the LLM gave up on patch for this file.
    if has_key(s:llm_agent_patch_fails, a:path)
        call remove(s:llm_agent_patch_fails, a:path)
    endif
    if has_key(s:llm_agent_patch_fail_diffs, a:path)
        call remove(s:llm_agent_patch_fail_diffs, a:path)
    endif
    return ''
endfunction

" Translate a curl exit code into a short, actionable hint. Currently
" only handles exit 28 (timeout); other exit codes pass through with the
" raw exit number so the user can look them up in `man curl`.
function! LLMAgent_CurlExitHint(exit_code)
    if a:exit_code == 0
        return ''
    endif
    if a:exit_code == 28
        return 'Operation timed out after g:llm_agent_timeout=' . g:llm_agent_timeout . 's. The model is too slow for this timeout — increase g:llm_agent_timeout (e.g. `let g:llm_agent_timeout = 180`) and rerun. The pending turn is dropped; rerun :LLMAgent / :LLMAsk to retry.'
    endif
    return ''
endfunction

" Decode JSON-style escape sequences that the LLM might leave literal in
" string arguments. Most commonly this is \n, \t, \r, \" and \\. We only
" do this when the string has actual backslashes — pure text is returned
" unchanged.
function! LLMAgent_DecodeEscapes(s)
    if stridx(a:s, '\') < 0
        return a:s
    endif
    let l:out = a:s
    let l:out = substitute(l:out, '\\n',  "\n", 'g')
    let l:out = substitute(l:out, '\\t',  "\t", 'g')
    let l:out = substitute(l:out, '\\r',  "\r", 'g')
    let l:out = substitute(l:out, '\\"',  '"',  'g')
    let l:out = substitute(l:out, '\\\\', '\', 'g')
    return l:out
endfunction

" Repair a near-miss unified-diff hunk header line. patch(1) requires
" "@@ -N[,M] +A[,B] @@" to start the line; anything else containing @@
" makes it die with "Only garbage was found in the patch input". LLMs
" produce recognizable near-misses, so fix them in place:
"   - BOM or stray text glued before the @@ (keep only from the @@ on)
"   - double spaces, tabs, NBSP, unicode minus/en-dash in the numbers
"   - missing -/+ range signs ("@@ 51 51 @@")
"   - git combined-diff "@@@ -a -b +c @@@" (drop to plain "@@ ... @@")
" Non-hunk lines pass through untouched.
function! LLMAgent_FixHunkHeader(line)
    " Skip real diff content lines: a context line starting with ' ',
    " added line '+' with content, removed line '-', or no-newline "\".
    " Heuristic: the rest of the line MUST contain at least one @ to be
    " a header candidate. A bare '+ foo bar' added line never contains @
    " unless it's literally quoting a header; if so, the LLM should have
    " used @@ on a fresh line. Likewise '- foo bar' is a removed line.
    if a:line =~# '^[ +\\-]'
        if stridx(a:line, '@') < 0
            return a:line
        endif
        " '+' or '-' followed by a recognizable "@@ -N +N @@" header on
        " the rest of the line: rewrite. Otherwise it is genuine content
        " carrying an @ symbol — leave alone.
        let l:tail = substitute(a:line, '^[ +-]', '', '')
        if l:tail !~# '@@'
            return a:line
        endif
    endif
    " Normalize look-alike characters and whitespace on the whole line
    " first, so the header-shape patterns below can recognize the parts.
    let l:line = substitute(a:line, '[\u2012\u2013\u2212\uFE58\uFF0D]', '-', 'g')
    let l:line = substitute(l:line, '[\u00A0\u202F\u2007\u2002\u2003\u2004\u2005\u2006\u2009\u200A\u3000]', ' ', 'g')
    let l:line = substitute(l:line, '[\uFEFF\u200B]', '', 'g')
    let l:line = substitute(l:line, '\t', ' ', 'g')
    " Find the first @-run followed by a signed or bare number — the
    " header opening. A BOM or prose glued in front of it is dropped by
    " working from there.
    let l:open = match(l:line, '@\+\s*[+\-]\?\d')
    if l:open < 0
        " No header pattern at all. Leave the line alone — StripDiffProse
        " should have removed it earlier; if it didn't, better to keep
        " the line than risk corrupting it.
        return a:line
    endif
    let l:body = strpart(l:line, l:open)
    " Split at the LAST @-run: it is the closer; anything after it is the
    " section heading. When the only @-run is the opener, the closer is
    " missing and we re-add one below.
    let l:last_at = strridx(l:body, '@')
    let l:run_start = l:last_at
    while l:run_start > 0 && l:body[l:run_start - 1] ==# '@'
        let l:run_start -= 1
    endwhile
    let l:heading = ''
    if l:run_start > l:open
        let l:heading = strpart(l:body, l:last_at + 1)
        let l:body = strpart(l:body, 0, l:run_start)
    endif
    " Drop stray noise chars that ended up between the @ runs. After the
    " split, the body is "@@ -N +N @@"; anything else between the two
    " @@ runs is LLM chatty punctuation we should discard.
    let l:keep = '@+-0123456789, '
    let l:body2 = ''
    let l:i = 0
    while l:i < strlen(l:body)
        let l:ch = strpart(l:body, l:i, 1)
        if stridx(l:keep, l:ch) >= 0
            let l:body2 .= l:ch
        endif
        let l:i += 1
    endwhile
    let l:body = l:body2
    " Drop any chars that wedged themselves between two @ runs, like the
    " "5" in "@5@@" -> "@@". Vim regex: from one @ through the next @,
    " remove anything that is not a sign, comma, digit or whitespace.
    let l:body = substitute(l:body, '@[^@+-0-9 ,]\+@', '@@', 'g')
    let l:body = substitute(l:body, '@[^@+-0-9 ,]\+@', '@@', 'g')
    " Combined-diff "@@@" openers/closers collapse to "@@".
    let l:body = substitute(l:body, '@\+', '@@', 'g')
    " Squeeze runs of spaces to one, and spaces after commas to none.
    let l:body = substitute(l:body, '\s\+', ' ', 'g')
    let l:body = substitute(l:body, ',\s*', ',', 'g')
    " Canonical spacing: one space after the opening @@ and before the
    " closing @@; none after commas.
    let l:body = substitute(l:body, '^@+\s*', '@@ ', '')
    let l:body = substitute(l:body, '\s\+$', '', '')
    " Missing range signs: "@@ 51 51" -> "@@ -51 +51" (bare line numbers).
    let l:body = substitute(l:body, '^@@\s\+\(\d\+\)\(\,\d\+\)\=\s\+\(\d\+\)\(\,\d\+\)\= *$', '@@ -\1\2 +\3\4 @@', '')
    if l:body !~# '@@$'
        let l:body .= ' @@'
    endif
    let l:body = substitute(l:body, '\s\+@@$', ' @@', '')
    " If, after the rewrite, the header still doesn't look valid, leave
    " the original line alone — patch(1) will give a more useful error
    " than our sanitizer guessing.
    if l:body !~# '^@@ \-\d\+\(,\d\+\)\? +\d\+\(,\d\+\)\? @@\(.*\)$'
        return a:line
    endif
    " Re-attach the heading (with any trailing whitespace that was there
    " originally — useful for "fHelp()" style section names that patch
    " preserves verbatim). The validator may add a closing @@ if the
    " original had none; the heading remains in both cases.
    return l:body . l:heading
endfunction

" Resolve a path the LLM gives us against the working buffer's directory
" (or cwd if no working buffer is set). The LLM often sends relative paths
" like "scripts/module/foo.py" while editing a file at "src/main.go" — we
" want to interpret those against the directory of the file the user is
" editing, which is the same place the LLM sees in its system prompt.
" A path that resolves above the project root is returned unchanged but the
" caller is expected to reject it (security check).
function! LLMAgent_ResolveToolPath(raw_path)
    if empty(a:raw_path)
        return ''
    endif
    " Absolute paths (or home-relative ~/) are returned as-is after simplify.
    " Vim has no isabs(); compare fnamemodify before/after :p to detect.
    if a:raw_path =~ '^[~/]' || fnamemodify(a:raw_path, ':p') ==# fnamemodify(a:raw_path, ':.')
        return simplify(a:raw_path)
    endif
    " Decide the base directory:
    "   1. The working buffer's directory, if pinned and on disk.
    "   2. The current buffer's directory.
    "   3. The cwd.
    let l:base = ''
    if exists('s:llm_agent_working_buf') && bufexists(s:llm_agent_working_buf)
        let l:base = fnamemodify(bufname(s:llm_agent_working_buf), ':p:h')
    endif
    if empty(l:base) || !isdirectory(l:base)
        let l:base = expand('%:p:h')
    endif
    if empty(l:base) || !isdirectory(l:base)
        let l:base = getcwd()
    endif
    return simplify(l:base . '/' . a:raw_path)
endfunction

" True if a:path (already absolute and simplified) lives above the
" project root. Used to refuse parent-traversal after path resolution.
" The project root comes from `git -C <a:path>` when a:path is inside a
" repo (falls back to cwd otherwise). Note we pass the file's DIRECTORY,
" not the file itself: `git -C <file>` fails with "Not a directory" even
" when the file is inside a repo, which used to make the check fall back
" to cwd and wrongly refuse files outside the cwd.
function! LLMAgent_IsOutsideProject(path)
    if a:path =~ '^\.\.'
        return 1
    endif
    if a:path !~ '^/'
        " Relative — caller should have resolved this; treat as unsafe.
        return 1
    endif
    " Prefer the file's own directory; when it isn't a directory (or the
    " file was deleted), fall back to its parent via fnamemodify.
    let l:probe = isdirectory(a:path) ? a:path : fnamemodify(a:path, ':h')
    let l:root = system('git -C ' . shellescape(l:probe) . ' rev-parse --show-toplevel 2>/dev/null')
    let l:root = substitute(l:root, '\n\+$', '', '')
    if v:shell_error != 0 || empty(l:root)
        " No git repo. Fall back to cwd as the project root.
        let l:root = getcwd()
    endif
    " A path is inside the project if it starts with l:root + '/'.
    return stridx(a:path . '/', l:root . '/') != 0
endfunction

" Resolve a buffer number to a project-relative path string, or '' if the
" buffer is unnamed / part of the agent's own UI. Mirrors the relative-path
" logic in LLMAgent_GetFileContext so the two stay in sync.
function! LLMAgent_ResolveBufPath(bufnr)
    if !bufexists(a:bufnr)
        return ''
    endif
    let l:abs = fnamemodify(bufname(a:bufnr), ':p')
    if empty(l:abs) || l:abs =~ 'LLMAgent-'
        return ''
    endif
    let l:git_root = system('git -C ' . shellescape(fnamemodify(l:abs, ':h')) . ' rev-parse --show-toplevel 2>/dev/null')
    let l:git_root = substitute(l:git_root, '\n\+$', '', '')
    if v:shell_error == 0 && !empty(l:git_root)
        return substitute(l:abs, '^' . escape(l:git_root, '.\') . '/', '', '')
    endif
    return fnamemodify(l:abs, ':.')
endfunction

" Build a structured location block the LLM can reliably parse. Tells the
" model: which file, what range (with absolute line numbers), and the
" selected text (or 'no selection' if a:line1==a:line2==0). A few lines of
" surrounding context are included so the LLM can reason about braces,
" indentation, etc. without an extra read_file round-trip.
"
" a:mode values:
"   'visual'  - line1/line2 came from a visual selection (text included)
"   'range'   - line1/line2 came from :line1,line2 (text included)
"   'cursor'  - single line / no range; just file + line + 5 lines of context
"   'none'    - file only, no line info
function! LLMAgent_BuildLocationContext(bufnr, line1, line2, mode)
    let l:rel = LLMAgent_ResolveBufPath(a:bufnr)
    if empty(l:rel)
        return ''
    endif
    let l:ft = getbufvar(a:bufnr, '&filetype')
    let l:header = 'File: ' . l:rel
    if !empty(l:ft)
        let l:header .= ' (' . l:ft . ')'
    endif

    if a:mode == 'none' || (a:line1 == 0 && a:line2 == 0)
        return l:header
    endif

    if a:mode == 'cursor' || a:line1 == a:line2
        let l:line = a:line1
        let l:lo = max([1, l:line - 2])
        " Over-fetch and let getbufline return what exists. Vim pads missing
        " line numbers with empty strings, so we drop trailing empties.
        let l:hi = l:line + 2
        let l:lines = getbufline(a:bufnr, l:lo, l:hi)
        let l:snippet = []
        for l:i in range(len(l:lines))
            let l:n = l:lo + l:i
            if empty(l:lines[l:i]) && l:n > l:line
                " Trailing empty padding from getbufline past EOF
                break
            endif
            let l:marker = (l:n == l:line) ? '>' : ' '
            call add(l:snippet, printf('%s %4d| %s', l:marker, l:n, l:lines[l:i]))
        endfor
        let l:body = l:header . "\nLine: " . l:line . "\nContext:" . "\n```" . "\n" . join(l:snippet, "\n") . "\n```"
        return l:body
    endif

    " Range / visual mode: line1..line2 with their actual content
    let l:lo = max([1, a:line1])
    let l:hi = a:line2
    let l:lines = getbufline(a:bufnr, l:lo, l:hi)
    let l:snippet = []
    for l:i in range(len(l:lines))
        let l:n = l:lo + l:i
        if empty(l:lines[l:i]) && l:n > a:line1
            " Trailing empty padding from getbufline past EOF
            break
        endif
        call add(l:snippet, printf('  %4d| %s', l:n, l:lines[l:i]))
    endfor
    let l:body = l:header . "\nRange: lines " . l:lo . '-' . l:hi . "\nSelection:" . "\n```" . "\n" . join(l:snippet, "\n") . "\n```"
    return l:body
endfunction

" Capture the user's last visual selection AND its exact line range. Returns
" a dict with keys: text, line1, line2, mode. mode is one of:
"   'visual'  - we are currently in visual mode
"   'range'   - not in visual now, but the '< '> marks point at a
"               previous visual selection
"   'none'    - no selection information is available
" line1/line2 are 0 when mode == 'none'.
" Always restores the unnamed register.
function! LLMAgent_CaptureSelection()
    let l:save_reg = @"
    let l:save_regtype = getregtype('"')
    try
        " Path 1: we're currently in visual mode (rare for command invocation,
        " but happens with operator-pending mappings and :normal tricks).
        if mode() ==# 'v' || mode() ==# 'V' || mode() ==# "\<C-V>"
            let l:line1 = line('v')
            let l:line2 = line('.')
            if l:line2 < l:line1
                let [l:line1, l:line2] = [l:line2, l:line1]
            endif
            normal! gv"xy
            return {'text': @x, 'line1': l:line1, 'line2': l:line2, 'mode': 'visual'}
        endif

        " Path 2: invoked from a :command. Vim exits visual mode before the
        " command runs, but the '< '> marks still describe the last visual
        " selection. If those marks are set to valid lines in the current
        " buffer (or to lines we can re-yank), re-yank the text and return
        " the range. The '<' and '>' marks track per-buffer, so a stale
        " selection from a different buffer is harmless — those marks
        " are simply unset (line() returns 0) in the new buffer.
        let l:start_mark = line("'<")
        let l:end_mark = line("'>")
        if l:start_mark > 0 && l:end_mark > 0
            let l:line1 = min([l:start_mark, l:end_mark])
            let l:line2 = max([l:start_mark, l:end_mark])
            " Sanity: marks must be inside the current buffer's line range.
            let l:last_line = line('$')
            if l:line1 >= 1 && l:line2 <= l:last_line
                silent execute 'normal! ' . l:line1 . 'GV' . l:line2 . 'G"xy'
                if !empty(@x)
                    return {'text': @x, 'line1': l:line1, 'line2': l:line2, 'mode': 'range'}
                endif
            endif
        endif

        return {'text': '', 'line1': 0, 'line2': 0, 'mode': 'none'}
    finally
        let @" = l:save_reg
        call setreg('"', l:save_reg, l:save_regtype)
    endtry
endfunction

" Reset all in-memory agent conversation state. The sidebar display buffer is
" not touched (use :LLMClear for that). Safe to call when state is unset.
function! LLMAgent_Reset()
    let s:llm_agent_messages = []
    let s:llm_agent_write_list = []
    let s:llm_agent_response_text = ''
    let s:llm_agent_patch_fails = {}
    let s:llm_agent_patch_fail_diffs = {}
    let s:llm_agent_read_files = {}
    let s:acp_response_text = ''
    let s:acp_write_list = []
    let s:acp_turn_error = ''
    if exists('s:llm_agent_working_buf')
        unlet s:llm_agent_working_buf
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Private Functions - System Prompt
""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! LLMAgent_GetSystemPrompt()
    if !empty(g:llm_agent_system_prompt)
        return g:llm_agent_system_prompt
    endif
    return 'You are a helpful coding assistant. Be concise and direct. When asked to generate or fix code, return only the code.'
endfunction

function! LLMAgent_GetFileContext()
    " Use saved working buffer if available (set before sidebar opens)
    if exists('s:llm_agent_working_buf') && bufexists(s:llm_agent_working_buf)
        let l:buf = s:llm_agent_working_buf
        let l:buf_path = fnamemodify(bufname(l:buf), ':p')
    else
        let l:buf = bufnr('%')
        let l:buf_path = expand('%:p')
    endif
    if empty(l:buf_path) || l:buf_path =~ 'LLMAgent-'
        return ''
    endif
    let l:info = ''
    " Try git-root relative path first
    let l:git_root = system('git -C ' . shellescape(fnamemodify(l:buf_path, ':h')) . ' rev-parse --show-toplevel 2>/dev/null')
    let l:git_root = substitute(l:git_root, '\n\+$', '', '')
    if v:shell_error == 0 && !empty(l:git_root)
        let l:rel = fnamemodify(l:buf_path, ':p')
        let l:rel = substitute(l:rel, '^' . escape(l:git_root, '.\') . '/', '', '')
    else
        let l:rel = fnamemodify(l:buf_path, ':.')
    endif
    let l:info .= 'Working on file: ' . l:rel
    let l:ft = getbufvar(l:buf, '&filetype')
    if !empty(l:ft)
        let l:info .= ' (' . l:ft . ')'
    endif
    return l:info
endfunction

" Build the system prompt used by both API and ACP backends. It bundles the
" base system prompt, the current file's context, and the tool-use rules the
" agent must follow.
function! LLMAgent_GetAgentSystemPrompt()
    let l:prompt = LLMAgent_GetSystemPrompt()
    let l:file_ctx = LLMAgent_GetFileContext()
    if !empty(l:file_ctx)
        let l:prompt .= "\n\n" . l:file_ctx
    endif
    " If a working buffer is pinned (e.g. user opened :LLMAgent from inside
    " a source file), include its path / filetype so the LLM can target it
    " with read_file / write_file even if the user doesn't mention it again.
    if exists('s:llm_agent_working_buf') && bufexists(s:llm_agent_working_buf)
        let l:loc = LLMAgent_BuildLocationContext(s:llm_agent_working_buf, 0, 0, 'none')
        if !empty(l:loc)
            let l:prompt .= "\n\nActive buffer:\n" . l:loc
        endif
    endif
    " If the LLM has been failing at patch on a path, scold it loudly.
    if !empty(s:llm_agent_patch_fails)
        let l:warn = "\n\nPATCH FAILURES THIS SESSION (use write_file for these):"
        for l:p in keys(s:llm_agent_patch_fails)
            let l:warn .= "\n- " . l:p . " failed " . s:llm_agent_patch_fails[l:p] . " time(s)"
        endfor
        let l:warn .= "\nFor each: call read_file, then call write_file with the COMPLETE new content. Do NOT call patch again on these."
        let l:prompt .= l:warn
    endif
    let l:rules = "\n\nWORKFLOW (follow this order):"
    let l:rules .= "\n1. If you have NOT yet called read_file on the target file in this conversation, do that first. You cannot patch or rewrite a file you have not read."
    let l:rules .= "\n2. Prefer patch for small-to-medium edits (up to ~10 lines or a few hunks). It sends only the changed lines, is cheap, and the tool sanitizes messy diffs (headerless @@, CRLF, BOM) so it is more forgiving than raw patch(1). Before calling patch, you must have just read the file so you know the exact current line content."
    let l:rules .= "\n3. Use write_file for LARGE or STRUCTURAL changes: new files, rewriting most of a file, refactor / restructure / reformat, or when more than ~10 lines change. write_file REPLACES the entire file with what you send — never send only the changed lines (that destroys the rest). Always send every line of the new file, including unchanged ones."
    let l:rules .= "\n4. If patch fails once, call read_file again to refresh, then call write_file with the full file. Do NOT retry patch with a guess."
    let l:rules .= "\n5. To find files, use find with a glob (e.g. '**/*.py'). To search, use grep with a regex. To list a directory, use ls."
    let l:rules .= "\n6. Never put code in your text response — always modify files via tools."
    let l:rules .= "\n7. After tools finish, give a short text summary (1-3 sentences). Do not include code blocks."
    let l:rules .= "\n8. Stop calling tools as soon as the task is done. Do not call tools just to confirm what you already know."
    let l:rules .= "\n\nRESPONSE FORMATTING RULES:"
    let l:rules .= "\n- Sidebar is narrow. Use short sentences, blank lines between them, and simple ## or - markdown only."
    let l:rules .= "\n- Do NOT use markdown tables (the sidebar renders them poorly). Use bullet lists instead."
    let l:rules .= "\n- Do NOT repeat the user's question or paste the file contents back at them."
    let l:rules .= "\n- Reference files by path, e.g. 'updated scripts/module/LLMAgent.vim', not by quoting full contents."
    let l:rules .= "\n\nTOOL CALL FORMAT:"
    let l:rules .= "\n- Each tool call's arguments MUST be a single valid JSON object."
    let l:rules .= "\n- No markdown, no code fences, no prose, no comments, and no trailing commas inside the arguments JSON. Use the exact parameter names the tool defines."
    let l:rules .= "\n- Call the smallest set of tools that gets the job done. Do not call a tool you do not need, and do not call read_file on a file you have already read this conversation."
    return l:prompt . l:rules
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Private Functions - Backend
""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Build the JSON body for a chat-completion request. a:tools is a list of
" tool definitions (omit / pass [] for a plain text completion).
function! LLMAgent_APIRequestBody(messages, tools)
    let l:body = {'model': g:llm_agent_model, 'messages': a:messages}
    if !empty(a:tools)
        let l:body['tools'] = a:tools
    endif
    return l:body
endfunction

" Build the curl command that POSTs a:bodyfile to the chat endpoint. When
" a:outfile is empty the response goes to stdout (used by the blocking
" LLMAgent_CallAPI); otherwise it is written to a:outfile (-o).
function! LLMAgent_BuildCurlCmd(bodyfile, outfile)
    let l:url = g:llm_agent_api_url . '/chat/completions'
    let l:curl_cmd = 'curl -s -m ' . g:llm_agent_timeout
    if !empty(g:llm_agent_api_key)
        let l:curl_cmd .= ' -H "Authorization: Bearer ' . g:llm_agent_api_key . '"'
    endif
    let l:curl_cmd .= ' -H "Content-Type: application/json"'
    let l:curl_cmd .= ' -d @' . shellescape(a:bodyfile)
    if !empty(a:outfile)
        let l:curl_cmd .= ' -o ' . shellescape(a:outfile)
    endif
    let l:curl_cmd .= ' ' . shellescape(l:url)
    return l:curl_cmd
endfunction

" Issue one chat-completion request against the configured API and return the
" decoded response as a dict, or {'error': '...'} on transport / parse errors.
" This is the synchronous path: system() blocks, but it works everywhere and
" is used as the fallback when background jobs are unavailable.
function! LLMAgent_CallAPI(messages, ...)
    let l:tools = (a:0 > 0 && type(a:1) == type([])) ? a:1 : []
    let l:body_json = json_encode(LLMAgent_APIRequestBody(a:messages, l:tools))
    let l:tmpfile = tempname()
    call writefile([l:body_json], l:tmpfile)
    call LLMAgent_DebugLogApiRequest(l:body_json, l:tools)

    let l:curl_cmd = LLMAgent_BuildCurlCmd(l:tmpfile, '')
    let l:response = system(l:curl_cmd)
    call delete(l:tmpfile)

    let l:data = {}
    if v:shell_error != 0
        let l:data = {'error': LLMAgent_CurlError(v:shell_error, l:response)}
    else
        let l:parsed = LLMAgent_ParseCompletion(l:response)
        let l:data = (has_key(l:parsed, 'error')) ? l:parsed : l:parsed['data']
    endif
    call LLMAgent_DebugLog({'kind': 'api_response', 'body': LLMAgent_PrettyJson(l:response), 'error': get(l:data, 'error', '')})
    return l:data
endfunction

" Async, non-blocking version of LLMAgent_CallAPI. Launches curl as a
" background job that writes the response body to a temp file (-o) and
" stderr to another (2>); LLMAgent_OnAPIExit parses the result and invokes
" Callback (a Funcref) with the same dict LLMAgent_CallAPI returns.
" Falls back to the blocking LLMAgent_CallAPI when jobs are unavailable —
" identical results, it just freezes Vim while the request runs.
function! LLMAgent_APIRequestAsync(messages, tools_opt, Callback)
    " Refuse to overlap a request already in flight; the entry points guard
    " too, but this is the last line of defense for shared script state.
    if s:llm_agent_api_job isnot v:null && LLMAgent_JobRunning(s:llm_agent_api_job)
        call call(a:Callback, [{'error': 'an API request is already in flight; use :LLMStop to cancel'}])
        return
    endif

    let l:tools = (type(a:tools_opt) == type([])) ? a:tools_opt : []
    let l:body_json = json_encode(LLMAgent_APIRequestBody(a:messages, l:tools))
    let l:bodyfile = tempname()
    call writefile([l:body_json], l:bodyfile)
    call LLMAgent_DebugLogApiRequest(l:body_json, l:tools)

    let l:outfile = tempname()
    let l:errfile = tempname()
    " Run via a shell so the 2> redirect works under both jobstart (string
    " command) and job_start (string command).
    let l:shell_cmd = LLMAgent_BuildCurlCmd(l:bodyfile, l:outfile) . ' 2> ' . shellescape(l:errfile)

    " Stash state for the exit callback.
    let s:llm_agent_api_cb = a:Callback
    let s:llm_agent_api_outfile = l:outfile
    let s:llm_agent_api_errfile = l:errfile
    let s:llm_agent_api_bodyfile = l:bodyfile

    let l:job = LLMAgent_JobStart(l:shell_cmd, function('LLMAgent_OnAPIExit'))
    if l:job is v:null
        " No job support: clean up and run the blocking request instead.
        call LLMAgent_APIClearJobState()
        let l:data = LLMAgent_CallAPI(a:messages, l:tools)
        call call(a:Callback, [l:data])
        return
    endif
    let s:llm_agent_api_job = l:job
endfunction

" Clear the async request state and delete its temp files.
function! LLMAgent_APIClearJobState()
    for l:key in ['outfile', 'errfile', 'bodyfile']
        let l:f = s:llm_agent_api_{l:key}
        if !empty(l:f) | call delete(l:f) | endif
        let s:llm_agent_api_{l:key} = ''
    endfor
    let s:llm_agent_api_job = v:null
    let s:llm_agent_api_cb = ''
endfunction

" Build the same error dict LLMAgent_CallAPI / LLMAgent_OnAPIExit use for a
" curl failure, so sync and async paths report problems identically.
function! LLMAgent_CurlError(exit_code, stderr)
    let l:hint = LLMAgent_CurlExitHint(a:exit_code)
    let l:msg = 'curl failed (exit ' . a:exit_code . ')'
    if !empty(a:stderr)
        let l:msg .= ': ' . substitute(a:stderr, '\n\+$', '', '')
    endif
    if !empty(l:hint)
        let l:msg .= '  ' . l:hint
    endif
    return l:msg
endfunction

" Decode a chat-completion response body. Returns {'data': <dict>} or
" {'error': '...'} when the body is not valid JSON.
function! LLMAgent_ParseCompletion(response)
    try
        let l:data = json_decode(a:response)
        if type(l:data) != type({})
            throw 'not an object'
        endif
        return {'data': l:data}
    catch
        call LLMAgent_DebugLog({'kind': 'api_error', 'stage': 'json_decode', 'body': strpart(a:response, 0, 4000)})
        return {'error': 'Failed to parse JSON response'}
    endtry
endfunction

" Job exit callback (nvim: on_exit(job_id, exit_code, event); vim:
" exit_cb(job, status)). Reads the response file, builds the same dict
" LLMAgent_CallAPI returns, and invokes the stashed callback. Then clears
" job state so a new turn can start.
function! LLMAgent_OnAPIExit(...)
    " a:1 = job id / job handle, a:2 = exit code. If the request was already
    " cancelled by LLMAgent_Stop before this callback fired, state is empty:
    " bail out, there is nothing to read or delete.
    if empty(s:llm_agent_api_cb) && empty(s:llm_agent_api_outfile)
        let s:llm_agent_api_job = v:null
        return
    endif
    let l:Cb = s:llm_agent_api_cb
    let l:exit_code = a:2

    " Read what curl left on disk BEFORE cleaning up: APIClearJobState()
    " deletes the temp files, so they must be consumed first.
    if l:exit_code != 0
        let l:err = filereadable(s:llm_agent_api_errfile) ? join(readfile(s:llm_agent_api_errfile), "\n") : ''
        call LLMAgent_DebugLog({'kind': 'api_error', 'stage': 'curl', 'exit': l:exit_code, 'stderr': strpart(l:err, 0, 2000)})
        call LLMAgent_APIClearJobState()
        call call(l:Cb, [{'error': LLMAgent_CurlError(l:exit_code, l:err)}])
        return
    endif

    let l:response = filereadable(s:llm_agent_api_outfile) ? join(readfile(s:llm_agent_api_outfile), "\n") : ''
    call LLMAgent_APIClearJobState()

    let l:parsed = LLMAgent_ParseCompletion(l:response)
    call LLMAgent_DebugLog({'kind': 'api_response', 'body': LLMAgent_PrettyJson(l:response), 'error': get(l:parsed, 'error', '')})
    call call(l:Cb, [(has_key(l:parsed, 'error')) ? l:parsed : l:parsed['data']])
endfunction

" One-shot query via the ACP backend, used by the single-shot commands
" (:LLMAsk/:LLMExplain/write/fix/refactor). Starts a FRESH session for this
" query, sends the prompt, waits for the turn to resolve, and returns the
" response in the same shape callers expect: {'content': ...} or
" {'error': ...}. A fresh session per call keeps single-shot queries stateless
" (matching the old single-shot behavior) so they neither pollute nor inherit
" the agent loop's session context. Blocks during the turn, like the ACP agent
" loop.
function! LLMAgent_ACPOneShot(prompt)
    if !LLMAgent_EnsureACP()
        return {'error': 'Failed to start ACP process'}
    endif
    if !LLMAgent_ACPInitialize()
        return {'error': 'Failed to initialize ACP session'}
    endif
    " Force a fresh session for this query.
    let s:acp_session_id = ''
    if !LLMAgent_ACPSessionNew()
        return {'error': 'Failed to create ACP session'}
    endif

    if !LLMAgent_ACPSendPrompt([{'type': 'text', 'text': a:prompt}])
        return {'error': empty(s:acp_turn_error) ? 'ACP session/prompt failed' : s:acp_turn_error}
    endif
    let l:content = s:acp_response_text
    " Reset per-turn state and drop the session so the next call starts fresh.
    let s:acp_response_text = ''
    let s:acp_turn_error = ''
    let s:acp_session_id = ''
    return {'content': l:content}
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Private Functions - ACP Process Management
""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Returns 1 if the ACP job is active, 0 otherwise. Nvim stores a channel id
" (number) in s:acp_job_id, but Vim stores a Job object, so a direct `> 0`
" comparison throws E910 ("Using a Job as a Number") under Vim. Use this
" helper for every "is the process alive?" check so both editors work.
function! LLMAgent_ACPOpen()
    if s:acp_job_id is v:null
        return 0
    endif
    if has('nvim')
        return type(s:acp_job_id) == v:t_number && s:acp_job_id > 0
    endif
    return type(s:acp_job_id) == v:t_job && job_status(s:acp_job_id) ==# 'run'
endfunction

" Send one JSON-RPC request over the ACP connection and block until its
" response arrives (the stdout handler resolves the pending entry and the
" wait loop pumps the event loop). Returns the 'result' dict on success,
" or v:null on timeout / connection loss / JSON-RPC error (an error message
" is logged to the sidebar).
function! LLMAgent_ACPRequest(method, params, max_100ms_cycles)
    let l:id = s:acp_next_req_id
    let s:acp_next_req_id += 1
    let s:acp_pending_reqs[l:id] = a:method
    call LLMAgent_SendACP({
        \ 'jsonrpc': '2.0',
        \ 'method': a:method,
        \ 'params': a:params,
        \ 'id': l:id,
        \ })
    let l:waited = 0
    while !has_key(s:acp_completed, string(l:id)) && LLMAgent_ACPOpen() && l:waited < a:max_100ms_cycles
        call LLMAgent_JobWaitJob(s:acp_job_id, 100)
        let l:waited += 1
    endwhile
    if !has_key(s:acp_completed, string(l:id))
        return v:null
    endif
    let l:res = s:acp_completed[l:id]
    call remove(s:acp_completed, string(l:id))
    return l:res
endfunction

" Send a session/prompt turn and wait for it to resolve. The agent streams
" updates via session/update (handled by the stdout callbacks, which append
" to s:acp_response_text / s:acp_write_list) and finally answers the
" session/prompt request. Returns 1 on success; on any failure
" s:acp_turn_error holds the message.
function! LLMAgent_ACPSendPrompt(content_blocks)
    let s:acp_response_text = ''
    let s:acp_turn_error = ''
    let l:res = LLMAgent_ACPRequest('session/prompt', {'sessionId': s:acp_session_id, 'prompt': a:content_blocks}, g:llm_agent_timeout * 10)
    if l:res is v:null
        if LLMAgent_ACPOpen()
            let s:acp_turn_error = (empty(s:acp_turn_error) ? 'ACP turn timed out' : s:acp_turn_error)
        elseif empty(s:acp_turn_error)
            let s:acp_turn_error = 'ACP process died during turn'
        endif
        return 0
    endif
    if !empty(s:acp_turn_error)
        return 0
    endif
    return 1
endfunction

function! LLMAgent_EnsureACP()
    " Drop a stale handle so we start a fresh process when the agent died.
    if LLMAgent_ACPOpen()
        if has('nvim')
            try
                call jobpid(s:acp_job_id)
            catch
                let s:acp_job_id = v:null
            endtry
        else
            if job_status(s:acp_job_id) ==# 'fail'
                let s:acp_job_id = v:null
            endif
        endif
    endif

    if LLMAgent_ACPOpen()
        return 1
    endif

    let s:acp_job_id = LLMAgent_JobStart(g:llm_agent_acp_cmd, function('LLMAgent_ACPOnExit'), function('LLMAgent_ACPOnStdout'))
    if s:acp_job_id is v:null
        return 0
    endif

    let s:acp_session_id = ''
    let s:acp_pending_reqs = {}
    let s:acp_completed = {}
    let s:acp_prompt_resolved = 0
    return 1
endfunction

function! LLMAgent_StopACP()
    call LLMAgent_JobStop(s:acp_job_id)
    call LLMAgent_ACPResetState()
endfunction

" Cancel an in-flight 'api' backend request (the async curl job) and reset the
" tool-loop state so a new turn can start. Safe to call when nothing is running.
" Mirrors LLMAgent_StopACP for the ACP backend.
function! LLMAgent_Stop()
    if s:llm_agent_api_cb isnot '' || LLMAgent_JobRunning(s:llm_agent_api_job)
        call LLMAgent_SidebarLog('Stopped', 'System')
    endif
    call LLMAgent_JobStop(s:llm_agent_api_job)
    call LLMAgent_APIClearJobState()
    let s:llm_agent_turn = 0
    let s:llm_agent_single_ctx = {}
endfunction

" Reset ALL ACP transient state. Called on stop, before a new session, and on
" unclean exit. Keeps s:acp_next_req_id so request IDs don't collide.
function! LLMAgent_ACPResetState()
    let s:acp_job_id = v:null
    let s:acp_session_id = ''
    let s:acp_pending_reqs = {}
    let s:acp_completed = {}
    let s:acp_prompt_resolved = 0
    let s:acp_initialized = 0
    let s:acp_agent_name = ''
    let s:acp_write_list = []
    let s:acp_response_text = ''
    let s:acp_turn_error = ''
    let s:acp_terminal_output = ''
endfunction

function! LLMAgent_SendACP(msg)
    if !LLMAgent_ACPOpen()
        return
    endif
    let l:json_str = type(a:msg) == v:t_dict ? json_encode(a:msg) : a:msg
    if has('nvim')
        call chansend(s:acp_job_id, l:json_str . "\n")
    else
        call ch_sendraw(s:acp_job_id, l:json_str . "\n")
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Private Functions - ACP Message Handler
""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Variadic so the same function serves both editors: Nvim calls the job's
" on_stdout as (job_id, data, event) — 3 list-args — while Vim's out_cb calls
" it as (channel, msg). a:2 is the payload either way. A fixed 3-arg
" signature throws E119 under Vim.
function! LLMAgent_ACPOnStdout(...)
    if has('nvim')
        let l:lines = a:2
    else
        " Vim: data is a single string, split by newline
        let l:lines = split(a:2, "\n", 1)
    endif
    for l:line in l:lines
        if empty(l:line)
            continue
        endif
        " Skip non-JSON startup output
        if l:line[0] != '{' && l:line[0] != '['
            continue
        endif
        call LLMAgent_HandleACPMessage(l:line)
    endfor
endfunction

function! LLMAgent_ACPOnStderr(...)
    " Silently ignore stderr (ACP uses stdout for protocol messages)
endfunction

function! LLMAgent_ACPOnExit(...)
    " Variadic exit callback: nvim's on_exit passes (job_id, exit_code, event);
    " Vim's exit_cb passes (job, status) — a:1/a:2 line up either way.
    "
    " Ignore a stale exit callback from a job we already stopped and replaced.
    " Only act when the callback is for the job we currently track — otherwise
    " a killed predecessor's late callback would clobber a freshly started
    " replacement (e.g. :LLMReset then an immediate :LLMAgent), leaving the new
    " job orphaned and init stuck.
    if s:acp_job_id is v:null
        return
    endif
    if has('nvim')
        if a:1 != s:acp_job_id
            return
        endif
    else
        if type(a:1) == v:t_job
            if type(s:acp_job_id) != v:t_job || a:1 isnot s:acp_job_id
                return
            endif
        else
            " a:1 is a channel (string command via shell produced channel-style
            " arg in some Vim builds): only treat as stale when a newer job
            " already replaced the one we track.
            if LLMAgent_ACPOpen() && type(s:acp_job_id) == v:t_job && a:1 isnot s:acp_job_id
                return
            endif
        endif
    endif
    call LLMAgent_ACPResetState()
    " If prompt was not yet resolved, mark with error
    if !s:acp_prompt_resolved
        let s:acp_turn_error = 'ACP process exited (code ' . a:2 . ')'
        let s:acp_prompt_resolved = 1
    endif
endfunction

function! LLMAgent_HandleACPMessage(line)
    try
        let l:msg = json_decode(a:line)
    catch
        return
    endtry

    " Check if it's a notification (no id field) - always a session/update
    if !has_key(l:msg, 'id')
        if has_key(l:msg, 'method') && l:msg['method'] == 'session/update'
            call LLMAgent_HandleACPUpdate(l:msg['params'])
        endif
        return
    endif

    " Check if it's a response to one of our requests
    if has_key(l:msg, 'result') || has_key(l:msg, 'error')
        let l:id = has_key(l:msg, 'id') ? l:msg['id'] : 0
        let l:req = get(s:acp_pending_reqs, l:id, '')
        if !empty(l:req)
            call remove(s:acp_pending_reqs, l:id)
            " Record the raw response so the blocking LLMAgent_ACPRequest
            " loop can pick it up; per-request flags below are derived state.
            let s:acp_completed[l:id] = has_key(l:msg, 'error') ? {'error': l:msg['error']} : {'result': l:msg['result']}
            if has_key(l:msg, 'error')
                call LLMAgent_ACPHandleError(l:id, l:req, l:msg['error'])
                return
            endif
            if l:req == 'initialize'
                let s:acp_initialized = 1
                let l:info = get(l:msg['result'], 'agentInfo', {})
                let s:acp_agent_name = get(l:info, 'name', '')
            elseif l:req == 'session/new'
                let s:acp_session_id = l:msg['result']['sessionId']
            endif
            return
        endif
    endif

    " It's a request from the agent (has method + id, not a response)
    if has_key(l:msg, 'method') && has_key(l:msg, 'id')
        call LLMAgent_HandleACPRequest(l:msg)
        return
    endif
endfunction

function! LLMAgent_HandleACPRequest(msg)
    let l:method = a:msg['method']
    let l:id = a:msg['id']
    let l:params = get(a:msg, 'params', {})

    if l:method == 'fs/read_text_file'
        let l:path = l:params['path']
        let l:content = ''
        if filereadable(l:path)
            let l:lines = readfile(l:path)
            let l:content = join(l:lines, "\n")
        else
            call LLMAgent_SendACP({'jsonrpc': '2.0', 'id': l:id, 'error': {'code': -32002, 'message': 'File not found: ' . l:path}})
            return
        endif
        call LLMAgent_SendACP({'jsonrpc': '2.0', 'id': l:id, 'result': {'content': l:content}})

    elseif l:method == 'fs/write_text_file'
        let l:path = l:params['path']
        let l:content = l:params['content']
        " Defer write: tell agent success, queue for user approval
        call add(s:acp_write_list, {'path': l:path, 'content': l:content})
        call LLMAgent_SendACP({'jsonrpc': '2.0', 'id': l:id, 'result': {}})

    elseif l:method == 'terminal/create'
        let l:command = l:params['command']
        let l:cwd = get(l:params, 'cwd', '.')
        let l:cmd = 'cd ' . shellescape(l:cwd) . ' 2>/dev/null && ' . l:command . ' 2>&1'
        let l:output = system(l:cmd)
        let l:terminal_id = reltime()
        let s:acp_terminal_output = l:output
        call LLMAgent_SendACP({'jsonrpc': '2.0', 'id': l:id, 'result': {'terminalId': string(l:terminal_id)}})

    elseif l:method == 'terminal/output'
        let l:terminal_id = l:params['terminalId']
        let l:output = get(s:, 'acp_terminal_output', '')
        call LLMAgent_SendACP({'jsonrpc': '2.0', 'id': l:id, 'result': {'output': l:output, 'exitStatus': {'exitCode': 0}, 'truncated': v:false}})

    elseif l:method == 'terminal/wait_for_exit'
        call LLMAgent_SendACP({'jsonrpc': '2.0', 'id': l:id, 'result': {'exitCode': 0}})

    elseif l:method == 'terminal/kill'
        call LLMAgent_SendACP({'jsonrpc': '2.0', 'id': l:id, 'result': {}})

    elseif l:method == 'terminal/release'
        let s:acp_terminal_output = ''
        call LLMAgent_SendACP({'jsonrpc': '2.0', 'id': l:id, 'result': {}})

    elseif l:method == 'session/request_permission'
        " Auto-allow all permissions from the agent
        call LLMAgent_SendACP({'jsonrpc': '2.0', 'id': l:id, 'result': {'outcome': {'selected': {'optionId': 'allow_once'}}}})

    else
        call LLMAgent_SendACP({'jsonrpc': '2.0', 'id': l:id, 'error': {'code': -32601, 'message': 'Method not found: ' . l:method}})
    endif
endfunction

function! LLMAgent_ACPHandleError(id, method, error)
    let l:err_msg = has_key(a:error, 'message') ? a:error['message'] : string(a:error)
    if a:method == 'session/prompt'
        let s:acp_turn_error = l:err_msg
        let s:acp_prompt_resolved = 1
    endif
    call LLMAgent_SidebarLog('ACP ' . a:method . ' error: ' . l:err_msg, 'Error')
endfunction

function! LLMAgent_HandleACPUpdate(params)
    let l:update = get(a:params, 'update', {})
    if empty(l:update)
        return
    endif

    " Handle agent_message_chunk streaming updates. The content field can be
    " either a single content block (dict, e.g. {"type":"text","text":"..."})
    " or a list of blocks depending on the ACP server version; handle both.
    if has_key(l:update, 'content')
        let l:content = l:update['content']
        let l:blocks = type(l:content) == type([]) ? l:content : [l:content]
        for l:block in l:blocks
            if type(l:block) == type({}) && get(l:block, 'type', '') ==# 'text'
                let s:acp_response_text .= l:block['text']
            endif
        endfor
    endif

    " Handle Diff notifications
    if has_key(l:update, 'diff') && type(l:update['diff']) == v:t_list
        for l:diff in l:update['diff']
            if has_key(l:diff, 'path') && has_key(l:diff, 'new')
                call add(s:acp_write_list, {'path': l:diff['path'], 'content': l:diff['new']})
            endif
        endfor
    endif

    " Handle ToolCallComplete - log tool activity
    if has_key(l:update, 'toolCallComplete')
        let l:tool = l:update['toolCallComplete']
        let l:name = get(l:tool, 'name', 'unknown')
        call LLMAgent_SidebarLog(l:name, 'Tool')
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Private Functions - ACP Agent Loop
""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Perform the ACP initialize handshake. The server requires an initialize
" request (and its response) followed by a notifications/initialized
" notification BEFORE any session/new. Without this, session/new gets no
" session. Idempotent: skips if already initialized.
function! LLMAgent_ACPInitialize()
    if s:acp_initialized
        return 1
    endif
    let l:id = s:acp_next_req_id
    let s:acp_next_req_id += 1
    let s:acp_pending_reqs[l:id] = 'initialize'
    call LLMAgent_SendACP({
        \ 'jsonrpc': '2.0',
        \ 'id': l:id,
        \ 'method': 'initialize',
        \ 'params': {'protocolVersion': 1, 'clientCapabilities': {}},
        \ })
    let l:waited = 0
    while !s:acp_initialized && LLMAgent_ACPOpen() && l:waited < 50
        call LLMAgent_JobWaitJob(s:acp_job_id, 100)
        let l:waited += 1
    endwhile
    if !s:acp_initialized
        return 0
    endif
    " Notify the server the initialize phase is complete (no response expected).
    call LLMAgent_SendACP({'jsonrpc': '2.0', 'method': 'notifications/initialized'})
    return 1
endfunction

function! LLMAgent_ACPSessionNew()
    if !empty(s:acp_session_id)
        return 1
    endif
    " Send session/new and wait for the response. opencode requires
    " mcpServers to be an array (omitting it makes session/new fail with
    " "Invalid params"); cwd is the project root.
    let l:cwd = getcwd()
    let l:res = LLMAgent_ACPRequest('session/new', {'cwd': l:cwd, 'mcpServers': []}, 50)
    if l:res is v:null
        return 0
    endif
    if has_key(l:res, 'error')
        return 0
    endif
    return !empty(s:acp_session_id)
endfunction

" Render the conversation history as labelled text, the way ACP turns must be
" sent (ACP has no message list — everything is one prompt string).
" Tool messages are skipped: their effects are already reflected in the files.
function! LLMAgent_ACPBuildPromptBlocks(prompt)
    let l:system_prompt = LLMAgent_GetAgentSystemPrompt()
    let l:body = ''
    if empty(s:llm_agent_messages)
        " New conversation: system prompt + user prompt.
        let l:body = empty(a:prompt) ? '' : a:prompt
    else
        " Continue existing conversation - send full message history as
        " formatted text. Tool messages are skipped: their effects were
        " already summarized in assistant turns.
        for l:msg in s:llm_agent_messages
            if l:msg['role'] == 'system'
                let l:body .= '[System]' . "\n" . l:msg['content'] . "\n\n"
            elseif l:msg['role'] == 'user'
                let l:body .= '[User]' . "\n" . l:msg['content'] . "\n\n"
            elseif l:msg['role'] == 'assistant'
                let l:body .= '[Assistant]' . "\n" . l:msg['content'] . "\n\n"
            endif
        endfor
        if !empty(a:prompt)
            let l:body .= '[User]' . "\n" . a:prompt
        endif
    endif
    let l:text = empty(l:body) ? l:system_prompt : l:system_prompt . "\n\n---\n\n" . l:body
    return [{'type': 'text', 'text': l:text}]
endfunction

function! LLMAgent_RunWithToolsACP(prompt)
    let s:acp_response_text = ''
    let s:acp_write_list = []
    let s:acp_turn_error = ''

    " Start ACP process if not running
    if !LLMAgent_EnsureACP()
        call LLMAgent_SidebarLog('Failed to start ACP process', 'Error')
        return
    endif

    " Complete the initialize handshake before any session/new.
    if !LLMAgent_ACPInitialize()
        call LLMAgent_SidebarLog('Failed to initialize ACP session', 'Error')
        return
    endif

    " Create session if needed
    if !LLMAgent_ACPSessionNew()
        call LLMAgent_SidebarLog('Failed to create ACP session', 'Error')
        return
    endif

    " Send the turn and wait for it to resolve (the agent may call us back
    " for fs/terminal tools while it runs).
    if !LLMAgent_ACPSendPrompt(LLMAgent_ACPBuildPromptBlocks(a:prompt))
        call LLMAgent_SidebarLog(empty(s:acp_turn_error) ? 'ACP process died during turn' : s:acp_turn_error, 'Error')
        return
    endif

    " Stream accumulated response to sidebar
    if !empty(s:acp_response_text)
        call LLMAgent_SidebarLog(s:acp_response_text, 'Agent')
    endif

    " Store in conversation history
    if empty(s:llm_agent_messages) && !empty(a:prompt)
        let s:llm_agent_messages = [
            \ {'role': 'system', 'content': LLMAgent_GetAgentSystemPrompt()},
            \ {'role': 'user', 'content': a:prompt}
            \ ]
    elseif !empty(a:prompt)
        call add(s:llm_agent_messages, {'role': 'user', 'content': a:prompt})
    endif
    if !empty(s:acp_response_text)
        call add(s:llm_agent_messages, {'role': 'assistant', 'content': s:acp_response_text})
    endif

    " Write approval — sync to shared write list for approval callbacks
    let s:llm_agent_write_list = s:acp_write_list
    call LLMAgent_FinishAgentTurn('')

    " The ACP agent (e.g. opencode) writes files directly to disk, bypassing
    " our write queue, so reload any open buffer whose file changed on disk.
    call LLMAgent_ReloadChangedBuffers()
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Private Functions - Display Window
""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! LLMAgent_DisplayOpen(text, source_buf, source_range, mode)
    " mode: 'view', 'write', 'replace'
    " source_range: for 'write' -> [line, col]; for 'replace' -> [line1, line2]

    if has('nvim')
        call LLMAgent_DisplayFloating(a:text, a:source_buf, a:source_range, a:mode)
    elseif has('popupwin')
        call LLMAgent_DisplayPopup(a:text, a:source_buf, a:source_range, a:mode)
    else
        call LLMAgent_DisplayPreview(a:text, a:source_buf, a:source_range, a:mode)
    endif
endfunction

function! LLMAgent_DisplaySetupBuffer(buf, source_buf, source_range, mode)
    call setbufvar(a:buf, '&buftype', 'nofile')
    call setbufvar(a:buf, '&bufhidden', 'wipe')
    call setbufvar(a:buf, '&swapfile', 0)
    call setbufvar(a:buf, 'llm_agent_source_buf', a:source_buf)
    call setbufvar(a:buf, 'llm_agent_source_range', a:source_range)
    call setbufvar(a:buf, 'llm_agent_mode', a:mode)
endfunction

function! LLMAgent_DisplayFloating(text, source_buf, source_range, mode)
    let l:buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(l:buf, 0, -1, v:true, split(a:text, '\n'))
    call LLMAgent_DisplaySetupBuffer(l:buf, a:source_buf, a:source_range, a:mode)
    call nvim_buf_set_option(l:buf, 'modifiable', v:false)

    let l:lines = split(a:text, '\n')
    let l:width = min([80, &columns - 8])
    let l:height = min([len(l:lines) + 2, &lines - 6])
    if l:height < 3
        let l:height = 3
    endif

    let l:row = (&lines - l:height) / 2
    let l:col = (&columns - l:width) / 2

    let s:llm_agent_win = nvim_open_win(l:buf, v:true, {
        \ 'relative': 'editor',
        \ 'width': l:width,
        \ 'height': l:height,
        \ 'row': l:row,
        \ 'col': l:col,
        \ 'style': 'minimal',
        \ 'border': 'single',
        \ })

    " Buffer-local keymaps for the floating window
    call nvim_buf_set_keymap(l:buf, 'n', '<CR>', ':call LLMAgent_AcceptFloating()<CR>', {'silent': v:true, 'nowait': v:true})
    call nvim_buf_set_keymap(l:buf, 'n', 'q', ':call LLMAgent_CloseFloating()<CR>', {'silent': v:true, 'nowait': v:true})
    call nvim_buf_set_keymap(l:buf, 'n', '<Esc>', ':call LLMAgent_CloseFloating()<CR>', {'silent': v:true, 'nowait': v:true})
endfunction

function! LLMAgent_DisplayPopup(text, source_buf, source_range, mode)
    let l:lines = split(a:text, '\n')
    let l:width = min([80, &columns - 8])
    let l:height = min([len(l:lines), &lines - 6])
    if l:height < 3
        let l:height = 3
    endif

    " Store metadata for accept
    let s:llm_agent_popup_source_buf = a:source_buf
    let s:llm_agent_popup_source_range = a:source_range
    let s:llm_agent_popup_mode = a:mode
    let s:llm_agent_popup_text = a:text

    let s:llm_agent_popup_id = popup_create(l:lines, {
        \ line: (&lines - l:height) / 2,
        \ col: (&columns - l:width) / 2,
        \ minwidth: l:width,
        \ maxwidth: l:width,
        \ minheight: l:height,
        \ maxheight: l:height,
        \ padding: [1,1,1,1],
        \ border: [],
        \ title: ' LLM Agent (Enter=accept, q=close) ',
        \ close: 'button',
        \ mapping: 0,
        \ filter: function('LLMAgent_PopupFilter'),
        \ })
endfunction

function! LLMAgent_PopupFilter(id, key)
    if a:key == 'q' || a:key == "\<Esc>" || a:key == "\x1b"
        call popup_close(a:id)
        return 1
    elseif a:key == "\<CR>" || a:key == "\r" || a:key == "\n"
        call popup_close(a:id)
        call LLMAgent_AcceptFromPopup()
        return 1
    endif
    " Allow scrolling
    return 0
endfunction

function! LLMAgent_DisplayPreview(text, source_buf, source_range, mode)
    " Use preview window as legacy fallback
    execute 'pedit LLMAgent-Response'
    wincmd P
    setlocal modifiable
    %delete _
    call setline(1, split(a:text, '\n'))
    call LLMAgent_DisplaySetupBuffer(bufnr('%'), a:source_buf, a:source_range, a:mode)
    setlocal nomodifiable

    nnoremap <buffer> <silent> <CR> :call LLMAgent_AcceptFromPreview()<CR>
    nnoremap <buffer> <silent> q :pclose<CR>
    nnoremap <buffer> <silent> <Esc> :pclose<CR>

    wincmd p
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Private Functions - Accept Actions
""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! LLMAgent_AcceptFloating()
    if !has('nvim') || !exists('s:llm_agent_win')
        return
    endif
    let l:buf = nvim_win_get_buf(s:llm_agent_win)
    let l:text = join(nvim_buf_get_lines(l:buf, 0, -1, v:true), "\n")
    let l:source_buf = getbufvar(l:buf, 'llm_agent_source_buf')
    let l:source_range = getbufvar(l:buf, 'llm_agent_source_range')
    let l:mode = getbufvar(l:buf, 'llm_agent_mode')

    call nvim_win_close(s:llm_agent_win, v:true)
    unlet s:llm_agent_win

    call LLMAgent_DoAccept(l:text, l:source_buf, l:source_range, l:mode)
endfunction

function! LLMAgent_CloseFloating()
    if has('nvim') && exists('s:llm_agent_win')
        call nvim_win_close(s:llm_agent_win, v:true)
        unlet s:llm_agent_win
    endif
endfunction

function! LLMAgent_AcceptFromPopup()
    if !exists('s:llm_agent_popup_text')
        return
    endif
    let l:text = s:llm_agent_popup_text
    let l:source_buf = s:llm_agent_popup_source_buf
    let l:source_range = s:llm_agent_popup_source_range
    let l:mode = s:llm_agent_popup_mode

    call LLMAgent_DoAccept(l:text, l:source_buf, l:source_range, l:mode)
endfunction

function! LLMAgent_AcceptFromPreview()
    let l:buf = bufnr('%')
    let l:text = join(getline(1, '$'), "\n")
    let l:source_buf = getbufvar(l:buf, 'llm_agent_source_buf')
    let l:source_range = getbufvar(l:buf, 'llm_agent_source_range')
    let l:mode = getbufvar(l:buf, 'llm_agent_mode')

    pclose

    call LLMAgent_DoAccept(l:text, l:source_buf, l:source_range, l:mode)
endfunction

function! LLMAgent_DoAccept(text, source_buf, source_range, mode)
    let l:win_buf = bufnr('%')
    if l:win_buf != a:source_buf
        execute 'buffer ' . a:source_buf
    endif

    if a:mode == 'write'
        " a:source_range = [line, col] - cursor position
        call cursor(a:source_range[0], a:source_range[1])
        let l:lines = split(a:text, '\n')
        call append(line('.'), l:lines)
    elseif a:mode == 'replace'
        " a:source_range = [line1, line2] - selection range
        let l:lines = split(a:text, '\n')
        execute a:source_range[0] . ',' . a:source_range[1] . 'delete _'
        call append(a:source_range[0] - 1, l:lines)
        " Remove the extra empty line at the end
        if getline(a:source_range[0] + len(l:lines)) == ''
            execute (a:source_range[0] + len(l:lines)) . 'delete _'
        endif
    endif
    " 'view' mode does nothing
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Private Functions - Core Execute
""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! LLMAgent_ToolReadFile(args)
    if !has_key(a:args, 'path')
        return {'ok': 0, 'error': 'read_file: missing "path" argument'}
    endif
    let l:path = LLMAgent_ResolveToolPath(a:args['path'])
    if empty(l:path)
        return {'ok': 0, 'error': 'read_file: empty "path"'}
    endif
    if LLMAgent_IsOutsideProject(l:path)
        return {'ok': 0, 'error': 'read_file: refused to read outside project (' . l:path . ')'}
    endif
    if !filereadable(l:path)
        return {'ok': 0, 'error': 'read_file: file not found (' . l:path . '). Use find or ls to locate it first.'}
    endif
    let l:lines = readfile(l:path)
    let l:start = get(a:args, 'start_line', 0)
    let l:end = get(a:args, 'end_line', 0)
    if l:start > 0 && l:end >= l:start
        if l:end > len(l:lines)
            let l:end = len(l:lines)
        endif
        if l:start > len(l:lines)
            return {'ok': 0, 'error': 'read_file: start_line ' . l:start . ' is past end of file (' . len(l:lines) . ' lines)'}
        endif
        let l:lines = l:lines[l:start - 1 : l:end - 1]
        let l:header = 'Lines ' . l:start . '-' . (l:start + len(l:lines) - 1) . ' of ' . l:path . ' (' . len(l:lines) . ' of ' . len(readfile(l:path)) . ' total):'
    else
        let l:header = 'Full file: ' . l:path . ' (' . len(l:lines) . ' lines):'
    endif
    " Number every line so the LLM can refer to specific lines.
    let l:numbered = []
    let l:n = max([1, get(a:args, 'start_line', 1)])
    for l:line in l:lines
        call add(l:numbered, printf('%4d| %s', l:n, l:line))
        let l:n += 1
    endfor
    let l:content = l:header . "\n" . join(l:numbered, "\n")
    if len(l:content) > 50000
        let l:content = strpart(l:content, 0, 50000) . "\n... (truncated, call read_file with start_line/end_line to see more)"
    endif
    " Mark this file as read so write_file / patch can verify the LLM
    " actually read it before modifying.
    let s:llm_agent_read_files[l:path] = 1
    return {'ok': 1, 'content': l:content}
endfunction

function! LLMAgent_ToolWriteFile(args)
    if !has_key(a:args, 'path') || !has_key(a:args, 'content')
        return {'ok': 0, 'error': 'write_file requires both "path" and "content" arguments'}
    endif
    let l:path = LLMAgent_ResolveToolPath(a:args['path'])
    if empty(l:path)
        return {'ok': 0, 'error': 'write_file: missing or empty "path"'}
    endif
    if LLMAgent_IsOutsideProject(l:path) || l:path =~ '\.git\(/\|$\|-\)'
        return {'ok': 0, 'error': 'write_file: refused to write outside project (' . l:path . ')'}
    endif
    " Refuse to write a file the LLM has not read in this conversation.
    " The LLM often makes up content based on stale memory; reading forces
    " it to use the current file. Allow an explicit override via the
    " write_file_force key (rarely useful).
    if !get(a:args, 'write_file_force', 0) && !has_key(s:llm_agent_read_files, l:path)
        " New file (doesn't exist) is OK — there's nothing to read.
        if filereadable(l:path)
            return {'ok': 0, 'error': 'write_file: refused — you have not called read_file on ' . l:path . ' in this conversation. Call read_file first, then call write_file with the COMPLETE current content (plus your changes). To override this safety check, pass write_file_force: true.'}
        endif
    endif
    " Decode escape sequences ONLY if the content has no real newlines. When
    " the LLM sends content as a JSON string, json_decode already turns \n
    " into real newlines, so a:args['content'] has real newlines as line
    " separators. Any literal \n / \t remaining in the content is part of the
    " SOURCE CODE (e.g. printf "...\n...", regex, etc.) and must be preserved —
    " decoding it would split lines and corrupt the file (see the same guard in
    " LLMAgent_ToolPatch). We only fall back to DecodeEscapes when there are no
    " real newlines at all, which means the LLM sent literal \n as line
    " separators (rare).
    let l:content = a:args['content']
    if stridx(l:content, "\n") < 0
        let l:content = LLMAgent_DecodeEscapes(l:content)
    endif
    if empty(l:content)
        return {'ok': 0, 'error': 'write_file: empty content; if you mean to create an empty file, send "\n"'}
    endif
    " Refuse content that looks like a diff, not a full file. After a failed
    " patch the LLM sometimes pastes the diff into write_file's content,
    " which would write the diff text as the file's literal contents.
    " Matches either a "headered" diff (^--- ...\n+++) or a headerless one
    " (^@@ -<digit>...).
    if l:content =~# '\m^--- .*\n+++ ' || l:content =~# '\m^@@ -\d'
        return {'ok': 0, 'error': 'write_file: content looks like a diff (starts with ---/+++ or @@). write_file expects the COMPLETE new file, not a diff. Re-send the full file content. (If you actually want to apply a diff, use the patch tool.)'}
    endif
    " Refuse content that is suspiciously shorter than the existing file.
    " This catches the "LLM sent only the changed lines" case which would
    " otherwise destroy the rest of the file. Bypass via write_file_force.
    let l:existing = filereadable(l:path) ? readfile(l:path) : []
    if !empty(l:existing) && !get(a:args, 'write_file_force', 0)
        let l:new_lines = len(split(l:content, "\n", 1))
        let l:old_lines = len(l:existing)
        if l:new_lines > 0 && l:new_lines * 3 < l:old_lines
            return {'ok': 0, 'error': 'write_file: new content has ' . l:new_lines . ' line(s) but the file has ' . l:old_lines . '. This looks like a partial write that would destroy the file. Either (a) re-send the COMPLETE file (all ' . l:old_lines . ' lines, with your changes), or (b) pass write_file_force: true if you really intend to shrink the file this much.'}
        endif
    endif
    let l:queue_err = LLMAgent_QueueWrite(l:path, l:content)
    if !empty(l:queue_err)
        return {'ok': 0, 'error': 'write_file: ' . l:queue_err}
    endif
    let l:msg = 'Queued for approval: ' . l:path . ' (' . len(l:content) . ' bytes, ' . len(split(l:content, "\n", 1)) . ' lines). Will NOT be written to disk until the user approves in the sidebar.'
    return {'ok': 1, 'content': l:msg}
endfunction

function! LLMAgent_ToolPatch(args)
    if !has_key(a:args, 'path') || !has_key(a:args, 'diff')
        return {'ok': 0, 'error': 'patch requires both "path" and "diff" arguments'}
    endif
    let l:path = LLMAgent_ResolveToolPath(a:args['path'])
    if empty(l:path)
        return {'ok': 0, 'error': 'patch: missing or empty "path"'}
    endif
    if LLMAgent_IsOutsideProject(l:path) || l:path =~ '\.git\(/\|$\|-\)'
        return {'ok': 0, 'error': 'patch: refused to write outside project (' . l:path . ')'}
    endif
    " Decode escape sequences ONLY if the diff has no real newlines. When
    " the LLM sends the diff as a JSON string, json_decode already turns
    " \n into real newlines, so a:args['diff'] has real newlines as line
    " separators. Any literal \n / \t remaining in the content is part of
    " the SOURCE CODE (e.g. printf "...\n...") and must be preserved —
    " decoding it would split diff lines and corrupt the patch. We only
    " fall back to DecodeEscapes when there are no real newlines at all,
    " which means the LLM sent literal \n as line separators (rare).
    let l:diff = a:args['diff']
    if stridx(l:diff, "\n") < 0
        let l:diff = LLMAgent_DecodeEscapes(l:diff)
    endif
    if !filereadable(l:path)
        return {'ok': 0, 'error': 'patch: file not found (' . l:path . '). If the file is new, use write_file instead.'}
    endif
    " Refuse to patch a file the LLM has not read this session. patch is
    " extremely sensitive to whitespace; a guessed diff is almost
    " guaranteed to fail. Force the LLM to either read first, or to
    " switch to write_file.
    if !get(a:args, 'patch_force', 0) && !has_key(s:llm_agent_read_files, l:path)
        return {'ok': 0, 'error': 'patch: refused — you have not called read_file on ' . l:path . ' in this conversation. Call read_file first so you know the EXACT current line content, then either (a) build a precise patch or (b) switch to write_file with the full new content. To override this safety check, pass patch_force: true.'}
    endif
    " Retry-loop breaker: if this path has already failed patch 2+ times
    " this session AND the submitted diff is identical to the one that just
    " failed, refuse to try again — the LLM is re-submitting the same broken
    " diff in a loop (common with files that have source lines containing a
    " literal \n). A different diff is always allowed through so a fresh,
    " valid attempt can clear the tracker. Force only the identical-retry
    " case toward write_file.
    if get(s:llm_agent_patch_fails, l:path, 0) >= 2
                \ && get(s:llm_agent_patch_fail_diffs, l:path, '') ==# l:diff
        return {'ok': 0, 'error': 'patch: ' . l:path . ' has already failed exactly ' . get(s:llm_agent_patch_fails, l:path, 0) . ' times with this same diff. It will not be applied — the file likely has source lines with literal newlines (e.g. printf "...\n...") that you keep splitting across diff lines. STOP re-sending this diff; call read_file to get the EXACT current content, then call write_file with the COMPLETE new file in `content`.'}
    endif

    " --- Pre-validate the diff -----------------------------------------
    " Catch the most common LLM mistakes before invoking patch(1), so the
    " error message is specific and actionable instead of "malformed patch".
    let l:lines = split(l:diff, "\n", 1)
    " Normalize line endings: mixed CRLF/LF wrecks patch(1) (a bare trailing
    " \r on a -/+ line makes the whole hunk "FAILED"). Strip any trailing CR.
    " Also drop a leading BOM on any line — a stray U+FEFF before a -/+ or
    " ---/+++ line makes patch(1) reject the whole hunk as malformed. BOMs
    " are a common LLM artifact when it echoes file content verbatim.
    let l:norm = []
    for l:l in l:lines
        if stridx(l:l, "\r") >= 0 && l:l =~# "\r$"
            let l:l = strpart(l:l, 0, strlen(l:l) - 1)
        endif
        let l:l = substitute(l:l, '^' . "\uFEFF", '', '')
        call add(l:norm, l:l)
    endfor
    let l:lines = l:norm
    if empty(l:lines)
        call LLMAgent_RecordPatchFail(l:path, l:diff)
        return {'ok': 0, 'error': 'patch: empty diff. If you only need to rewrite the file, use write_file.'}
    endif
    " Strip a single leading/trailing blank line the LLM often adds.
    while !empty(l:lines) && l:lines[0] =~ '^\s*$'
        let l:lines = l:lines[1:]
    endwhile
    while !empty(l:lines) && l:lines[-1] =~ '^\s*$'
        let l:lines = l:lines[:-2]
    endwhile
    if empty(l:lines)
        call LLMAgent_RecordPatchFail(l:path, l:diff)
        return {'ok': 0, 'error': 'patch: diff contains only blank lines. If you only need to rewrite the file, use write_file.'}
    endif
    " --- Strip leading prose ---------------------------------------------
    " patch(1) "Only garbage was found" can be triggered by a line before
    " the first ---/+++ pair that mentions "@@ -N +N @@" mid-line (e.g. an
    " LLM's prose preface). Drop everything before the first structural
    " line first, then sanitize the hunk headers themselves.
    let l:lines = LLMAgent_StripDiffProse(l:lines)

    " --- Sanitize hunk headers -------------------------------------------
    " patch(1) only accepts "@@ -N[,M] +A[,B] @@" at the START of a line.
    " LLMs emit near-misses that pass a naive ^@@ check: missing -/+
    " signs ("@@ 51 51 @@"), double spaces or tabs around the numbers,
    " NBSP / unicode minus characters, a BOM glued onto the @@, or git
    " combined-diff "@@@ -N -N +N @@@" headers. All of these make patch(1)
    " abort with "Only garbage was found in the patch input" — a dead end
    " for the LLM, since the error names nothing fixable. Normalize every
    " hunk header we can recognize; leave every other line untouched.
    let l:fixed_lines = []
    for l:line in l:lines
        call add(l:fixed_lines, LLMAgent_FixHunkHeader(l:line))
    endfor
    let l:lines = l:fixed_lines

    " A valid unified diff must have at least one @@ hunk.
    " Allowed line prefixes: @@ hunk header, --- /+++ file headers, context
    " line (space), + /- added/removed, \ "No newline" marker, blank line,
    " and the git extended-diff headers (diff --git, index, mode, rename,
    " copy, similarity, etc.) which LLMs often emit even when we asked for
    " plain unified diff.
    " We count bad-prefix lines for a HINT in the final error, but we do NOT
    " reject here — patch(1) is often more lenient than our validator and
    " can apply diffs with stray lines (e.g. continuation fragments from
    " source strings that contained a literal \n). Rejecting early caused
    " false positives where the LLM kept retrying the same diff.
let l:hunk_count = 0
    let l:bad_prefix_count = 0
    for l:line in l:lines
        " Count a BOM-prefixed "@@ ..." as a hunk header too — the
        " sanitizer just stripped that BOM so the line is usable.
        let l:line_nobom = substitute(l:line, '^' . "\uFEFF", '', '')
        if l:line =~# '^@@' || l:line_nobom =~# '^@@'
            let l:hunk_count += 1
        elseif l:line !~ '^\(@@\|---\|+++\|diff \|index \|old mode \|new mode \|deleted file \|new file \|similarity \|rename \|copy \|[\\ +-]\|$\)'
            let l:bad_prefix_count += 1
        endif
    endfor
    if l:hunk_count == 0
        call LLMAgent_RecordPatchFail(l:path, l:diff)
        return {'ok': 0, 'error': 'patch: diff has no @@ hunk header. Unified diffs must contain at least one "@@ -X,Y +A,B @@" line. If you only need to rewrite the file, use write_file.'}
    endif

    " --- Try `patch` (POSIX) -----------------------------------------------
    " patch(1) is the workhorse. We deliberately do NOT use `git apply`:
    " the target file may live outside any git working tree, and we cannot
    " assume the user's checkout layout. patch(1) applies to the temp copy
    " and we queue the resulting content for approval, so nothing touches
    " the tree.
    let l:original = readfile(l:path)
    let l:diff_file = tempname()
    let l:orig_file = tempname()
    let l:out_file = tempname()
    " patch(1) needs a trailing newline; some LLMs omit it. writefile
    " always adds one.
    call writefile(l:lines, l:diff_file)
    call writefile(l:original, l:orig_file)
    let l:cmd = 'patch -s -o ' . shellescape(l:out_file) . ' ' . shellescape(l:orig_file) . ' ' . shellescape(l:diff_file) . ' 2>&1'
    let l:err = system(l:cmd)
    call delete(l:diff_file)
    call delete(l:orig_file)

    if v:shell_error == 0
        let l:patched = readfile(l:out_file)
        call delete(l:out_file)
        let l:content = join(l:patched, "\n")
        let l:queue_err = LLMAgent_QueueWrite(l:path, l:content)
        if !empty(l:queue_err)
            call LLMAgent_RecordPatchFail(l:path, l:diff)
            return {'ok': 0, 'error': 'patch: applied by patch(1) but ' . l:queue_err}
        endif
        let l:msg = 'Patch applied via patch(1) and queued for approval: ' . l:path . ' (' . len(l:content) . ' bytes).'
        return {'ok': 1, 'content': l:msg}
    endif
    call delete(l:out_file)

    " --- Recovery: drop leading prose / code fences / out-of-place lines ---
    " patch(1) "Only garbage was found" comes from a line earlier in the
    " diff that GNU patch decides could be a hunk header but isn't. Strip
    " every line before the first real header ("---", "+++", "@@", or
    " "diff --git") and retry. This rescues diffs the LLM wrapped in
    " markdown fences or prefaced with prose that @@@ mentions misfire on.
    let l:recovered = LLMAgent_StripDiffProse(l:lines)
    if l:recovered !=# l:lines
        let l:diff_file3 = tempname()
        let l:out_file3 = tempname()
        call writefile(l:recovered, l:diff_file3)
        call writefile(l:original, l:orig_file)
        let l:cmd3 = 'patch -s -o ' . shellescape(l:out_file3) . ' ' . shellescape(l:orig_file) . ' ' . shellescape(l:diff_file3) . ' 2>&1'
        let l:err3 = system(l:cmd3)
        call delete(l:diff_file3)
        if v:shell_error == 0
            let l:patched = readfile(l:out_file3)
            call delete(l:out_file3)
            let l:content = join(l:patched, "\n")
            let l:queue_err = LLMAgent_QueueWrite(l:path, l:content)
            if !empty(l:queue_err)
                call LLMAgent_RecordPatchFail(l:path, l:diff)
                return {'ok': 0, 'error': 'patch: applied after stripping prose but ' . l:queue_err}
            endif
            let l:msg = 'Patch applied (after stripping leading prose) and queued for approval: ' . l:path . ' (' . len(l:content) . ' bytes).'
            return {'ok': 1, 'content': l:msg}
        endif
        call delete(l:out_file3)
    endif

    " --- Recovery: reconstruct headerless diffs ---------
    " A common LLM output (this model in particular) is a diff with NO
    " "---/+++" file headers AND a hunk header that is just "@@" with no
    " line numbers, e.g.
    "     @@
    "      echo "[Example]"
    "     -printf "run test: .sh -a"
    "     +printf "./setup.sh --setup"
    " patch(1) rejects this as "Only garbage" even though the body matches
    " the file byte-for-byte. Rebuild it: find the old
    " side (context + removed lines) in the current file, then emit
    " canonical ---/+++ and "@@ -N,M +N,M @@" headers so patch(1) applies.
    let l:rebuilt = LLMAgent_RebuildHeaderlessDiff(l:lines, l:original)
    if !empty(l:rebuilt)
        let l:content = join(l:rebuilt, "\n")
        let l:queue_err = LLMAgent_QueueWrite(l:path, l:content)
        if !empty(l:queue_err)
            call LLMAgent_RecordPatchFail(l:path, l:diff)
            return {'ok': 0, 'error': 'patch: rebuilt headerless diff but ' . l:queue_err}
        endif
        let l:msg = 'Patch applied (reconstructed from a headerless diff) and queued for approval: ' . l:path . ' (' . len(l:content) . ' bytes).'
        return {'ok': 1, 'content': l:msg}
    endif

    " --- Both failed: tell the LLM what to do next --------------------------
    " Record this path so the dispatcher can see at a glance that the LLM
    " is in a patch-loop, and the system prompt can be reinforced.
    call LLMAgent_RecordPatchFail(l:path, l:diff)
    " Always capture the raw diff to a debug file so we can diagnose the
    " failure even without the LLM turning on :LLMDebug. The path is stable
    " so the user can grab it next time patch fails.
    call LLMAgent_DebugDumpPatchDiff(l:path, l:lines, l:err)
    let l:hint = 'patch failed. patch(1) said: ' . substitute(l:err, "\n", ' ', 'g')
    if l:bad_prefix_count > 0
        let l:hint .= "\n\nThe diff also has " . l:bad_prefix_count . " line(s) that don't look like valid unified diff syntax (expected prefixes: \" \", \"+\", \"-\", \"\\\", \"@@\", \"---\", \"+++\", or a git extended header). This often happens when a SOURCE LINE contains a literal newline (e.g. printf \"...\\n\"...\") and you split it across two diff lines without a trailing \"\\\\\". patch(1) could not apply the diff as written."
    endif
    let l:hint .= "\n\nDO NOT RETRY patch with a guess. Call read_file on " . l:path . " to get the EXACT current content, then call write_file with the COMPLETE new file in `content`."
    let l:hint .= "\n\n(The raw failing diff was saved to /tmp/LLMAgent_LastPatchFail.diff — share it if you want help diagnosing.)"
    return {'ok': 0, 'error': l:hint}
endfunction

" Strip everything before the first diff-structure line and drop pure
" prose / markdown fences, returning a cleaner copy of the diff. Used as
" a recovery step when patch(1) reports "Only garbage was found".
function! LLMAgent_StripDiffProse(lines)
    let l:i = 0
    let l:start = -1
    while l:i < len(a:lines)
        if a:lines[l:i] =~# '^---\s' || a:lines[l:i] =~# '^+++\s'
            let l:start = l:i
            break
        endif
        if a:lines[l:i] =~# '^@@\s'
            let l:start = l:i
            break
        endif
        if a:lines[l:i] =~# '^diff \-\-git'
            let l:start = l:i
            break
        endif
        if a:lines[l:i] =~# '^index\s'
            let l:start = l:i
            break
        endif
        let l:i += 1
    endwhile
    if l:start <= 0
        return a:lines
    endif
    " Drop a leading "@@@ -a +b @@@" mis-fire: if the first kept line is
    " a combined-diff header AND there's no ---/+++ pair in the remainder,
    " the diff is really prose with a fake header — bail out and return
    " the original (recover failed).
    let l:tail = a:lines[l:start : ]
    let l:has_hdr = 0
    for l:line in l:tail
        if l:line =~# '^---\s' || l:line =~# '^diff \-\-git' || l:line =~# '^index\s'
            let l:has_hdr = 1
            break
        endif
    endfor
    if !l:has_hdr
        return a:lines
    endif
    return l:tail
endfunction

" Rebuild a headerless unified diff into canonical form by matching its
" old side (context + removed lines) against the current file.
"
" Some LLMs emit diffs that omit BOTH the "--- a/x" / "+++ b/x" file
" headers AND the line numbers in the "@@" header:
"     @@
"      echo "x"
"     -old
"     +new
" patch(1) rejects this with "Only garbage was found",
" yet the body content matches the file. Reconstruction:
"   1. require the first hunk header to be a bare "@@" (no -N +M numbers)
"      and the diff to have no ---/+++ file headers
"   2. gather the old-side sequence exactly as the file should contain it
"   3. locate it in the current file (must match once)
"   4. return lines with proper ---/+++ and "@@ -N,M +N,M @@" headers
" Returns a List (rebuilt diff lines) or '' if reconstruction is not
" possible / ambiguous.
function! LLMAgent_RebuildHeaderlessDiff(lines, original)
    " Find the first hunk-header line.
    let l:hunk_idx = -1
    let l:i = 0
    while l:i < len(a:lines)
        if a:lines[l:i] =~# '^@@\+'
            let l:hunk_idx = l:i
            break
        endif
        let l:i += 1
    endwhile
    if l:hunk_idx < 0
        return ''
    endif
    " The diff must be headerless: no ---/+++ pair anywhere.
    for l:line in a:lines
        if l:line =~# '^---\s' || l:line =~# '^+++\s' || l:line =~# '^diff \-\-git' || l:line =~# '^index\s'
            return ''
        endif
    endfor
    " The hunk header must carry no line numbers: "@@", "@@ @@",
    " "@@ fHelp()", etc. — but NOT "@@ -1,9 +1,10 @@" (already complete).
    if a:lines[l:hunk_idx] =~# '@@ \+\-\d\+\(,\d\+\)\? +\d\+\(,\d\+\)\?'
        return ''
    endif
    " Gather the body (everything after the hunk headers). The header may
    " be a bare "@@" or repeat as "@@ ... @@" — skip all leading @-only lines.
    let l:body = []
    let l:j = l:hunk_idx + 1
    while l:j < len(a:lines)
        if a:lines[l:j] =~# '^@@\+$'
            let l:j += 1
            continue
        endif
        call add(l:body, a:lines[l:j])
        let l:j += 1
    endwhile
    if empty(l:body)
        return ''
    endif
    " Parse the old side: context lines (space), removed lines (-), and
    " any line that does not start with "+" (a headerless diff may drop the
    " leading space on context lines too). The old side IS the file content.
    " Track the new-side length independently: context stays, '+' adds,
    " '-' is removed.
    let l:old_seq = []
    let l:new_cnt = 0
    for l:line in l:body
        if l:line =~# '^+'
            " added line: new side only
            let l:new_cnt += 1
        elseif l:line =~# '^ '
            " context line: both sides
            call add(l:old_seq, strpart(l:line, 1))
            let l:new_cnt += 1
        elseif l:line =~# '^-' && l:line !=# '---'
            " removed line: old side only
            call add(l:old_seq, strpart(l:line, 1))
        else
            " bare context line (no space prefix): both sides
            call add(l:old_seq, l:line)
            let l:new_cnt += 1
        endif
    endfor
    " Drop a trailing empty element if the body ended with a blank line.
    while !empty(l:old_seq) && l:old_seq[-1] ==# ''
        call remove(l:old_seq, -1)
    endwhile
    if empty(l:old_seq)
        return ''
    endif
    let l:n_old = len(l:old_seq)
    " Locate old_seq exactly once in the original file.
    let l:match_start = -1
    let l:match_count = 0
    let l:i2 = 0
    while l:i2 <= len(a:original) - l:n_old
        let l:match = 1
        let l:k = 0
        while l:k < l:n_old
            if a:original[l:i2 + l:k] !=# l:old_seq[l:k]
                let l:match = 0
                break
            endif
            let l:k += 1
        endwhile
        if l:match
            let l:match_start = l:i2
            let l:match_count += 1
        endif
        let l:i2 += 1
    endwhile
    if l:match_count != 1
        " Ambiguous or not found — do not guess.
        return ''
    endif
    let l:n_new = l:new_cnt
    " Build the reconstructed NEW file content directly: replace the matched
    " old-side span with the new side (context + added lines). Doing this by
    " content avoids patch(1)'s fragile hunk-anchoring (a hunk that ends at
    " the very end of the file can be rejected even when the lines match).
    let l:new_seq = []
    for l:line in l:body
        if l:line =~# '^+'
            call add(l:new_seq, strpart(l:line, 1))
        elseif l:line =~# '^ '
            call add(l:new_seq, strpart(l:line, 1))
        elseif l:line =~# '^-' && l:line !=# '---'
            " removed line: not on the new side
        else
            " bare context line (no space prefix)
            call add(l:new_seq, l:line)
        endif
    endfor
    while !empty(l:new_seq) && l:new_seq[-1] ==# ''
        call remove(l:new_seq, -1)
    endwhile
    let l:out = []
    " Head: lines before the match.
    let l:i3 = 0
    while l:i3 < l:match_start
        call add(l:out, a:original[l:i3])
        let l:i3 += 1
    endwhile
    " Middle: the new side.
    for l:line in l:new_seq
        call add(l:out, l:line)
    endfor
    " Tail: lines after the match.
    let l:i4 = l:match_start + l:n_old
    while l:i4 < len(a:original)
        call add(l:out, a:original[l:i4])
        let l:i4 += 1
    endwhile
    return l:out
endfunction

" Save the failing diff for diagnosis. /tmp/LLMAgent_LastPatchFail.diff is
" overwritten on every failure and is the most useful artifact when
" "patch fails every time" — it shows exactly what the LLM sent.
function! LLMAgent_DebugDumpPatchDiff(path, lines, patch_err)
    try
        call writefile([
            \ 'LLMAgent patch failure at ' . strftime('%Y-%m-%dT%H:%M:%S'),
            \ 'target path: ' . a:path,
            \ '',
            \ 'patch(1) said:',
            \ a:patch_err,
            \ '',
            \ 'raw diff lines (' . len(a:lines) . '):',
            \ ] + a:lines,
            \ '/tmp/LLMAgent_LastPatchFail.diff')
    catch
    endtry
endfunction

function! LLMAgent_ToolLs(args)
    let l:raw = get(a:args, 'path', '')
    let l:path = empty(l:raw) ? getcwd() : LLMAgent_ResolveToolPath(l:raw)
    if empty(l:path)
        return {'ok': 0, 'error': 'ls: missing "path"'}
    endif
    if LLMAgent_IsOutsideProject(l:path)
        return {'ok': 0, 'error': 'ls: refused to access outside project (' . l:path . ')'}
    endif
    if !isdirectory(l:path)
        return {'ok': 0, 'error': 'ls: directory not found (' . l:path . ')'}
    endif
    let l:entries = readdir(l:path)
    let l:result = 'Contents of ' . l:path . ' (' . len(l:entries) . ' entries):'
    let l:rows = []
    for l:entry in l:entries
        let l:full = l:path . '/' . l:entry
        if isdirectory(l:full)
            call add(l:rows, l:entry . '/')
        else
            call add(l:rows, l:entry)
        endif
    endfor
    if empty(l:rows)
        return {'ok': 1, 'content': l:result . "\n(empty directory)"}
    endif
    return {'ok': 1, 'content': l:result . "\n" . join(l:rows, "\n")}
endfunction

function! LLMAgent_ToolFind(args)
    if !has_key(a:args, 'pattern')
        return {'ok': 0, 'error': 'find: missing "pattern" argument'}
    endif
    let l:pattern = a:args['pattern']
    let l:base = getcwd()
    " If the user is editing a file, search relative to its project so a
    " pattern like "**/*.py" hits the right tree.
    if exists('s:llm_agent_working_buf') && bufexists(s:llm_agent_working_buf)
        let l:cand = fnamemodify(bufname(s:llm_agent_working_buf), ':p:h')
        if !empty(l:cand) && isdirectory(l:cand)
            let l:base = l:cand
        endif
    endif
    let l:files = globpath(l:base, l:pattern, 0, 1)
    if empty(l:files)
        return {'ok': 1, 'content': 'No files in ' . l:base . ' match pattern: ' . l:pattern}
    endif
    if len(l:files) > 200
        let l:files = l:files[:199]
        let l:result = 'First 200 of ' . l:pattern . ' matches under ' . l:base . ":\n" . join(l:files, "\n")
    else
        let l:result = 'Matches for ' . l:pattern . ' under ' . l:base . " (" . len(l:files) . " files):\n" . join(l:files, "\n")
    endif
    return {'ok': 1, 'content': l:result}
endfunction

function! LLMAgent_ToolGrep(args)
    if !has_key(a:args, 'pattern')
        return {'ok': 0, 'error': 'grep: missing "pattern" argument'}
    endif
    let l:pattern = a:args['pattern']
    let l:raw_path = get(a:args, 'path', '')
    let l:glob_filter = get(a:args, 'glob', '*')
    let l:path = empty(l:raw_path) ? getcwd() : LLMAgent_ResolveToolPath(l:raw_path)
    if empty(l:path)
        return {'ok': 0, 'error': 'grep: missing "path"'}
    endif
    if LLMAgent_IsOutsideProject(l:path)
        return {'ok': 0, 'error': 'grep: refused to search outside project (' . l:path . ')'}
    endif
    " Vim regex: anchor unanchored patterns at the start so the LLM's
    " common case ("function foo") matches a substring instead of treating
    " every space as an alternation.
    if l:pattern !~ '[\^$\\\.\*\[\(]'
        let l:pattern = '\V' . l:pattern
    endif
    let l:files = globpath(l:path, '**/' . l:glob_filter, 0, 1)
    let l:results = []
    let l:match_count = 0
    let l:capped = 0
    for l:file in l:files
        if !filereadable(l:file) || isdirectory(l:file)
            continue
        endif
        try
            let l:lines = readfile(l:file)
        catch
            continue
        endtry
        let l:line_num = 0
        for l:line in l:lines
            let l:line_num += 1
            try
                if l:line =~ l:pattern
                    if l:match_count >= 100
                        let l:capped = 1
                        break
                    endif
                    call add(l:results, l:file . ':' . l:line_num . ': ' . l:line)
                    let l:match_count += 1
                endif
            catch
                " Invalid Vim regex for this file's content; skip just this
                " file so other files still get searched.
                break
            endtry
        endfor
        if l:capped
            break
        endif
    endfor
    if l:capped
        call add(l:results, '... (truncated at 100 matches; narrow the pattern or glob to see more)')
    endif
    if empty(l:results)
        return {'ok': 1, 'content': 'No matches for /' . l:pattern . '/ under ' . l:path . ' (glob ' . l:glob_filter . ')'}
    endif
    return {'ok': 1, 'content': 'Matches for /' . l:pattern . '/ under ' . l:path . ' (glob ' . l:glob_filter . '):' . "\n" . join(l:results, "\n")}
endfunction

function! LLMAgent_ToolListBuffers()
    let l:bufs = []
    for l:i in range(1, bufnr('$'))
        if !buflisted(l:i)
            continue
        endif
        let l:name = bufname(l:i)
        if empty(l:name)
            let l:name = '[No Name]'
        endif
        call add(l:bufs, l:i . ': ' . l:name)
    endfor
    if empty(l:bufs)
        return {'ok': 1, 'content': 'No listed buffers.'}
    endif
    return {'ok': 1, 'content': 'Open buffers (' . len(l:bufs) . "):\n" . join(l:bufs, "\n")}
endfunction

function! LLMAgent_ExecuteTool(name, args)
    if a:name == 'read_file'
        return LLMAgent_ToolReadFile(a:args)
    elseif a:name == 'write_file'
        return LLMAgent_ToolWriteFile(a:args)
    elseif a:name == 'patch'
        return LLMAgent_ToolPatch(a:args)
    elseif a:name == 'ls'
        return LLMAgent_ToolLs(a:args)
    elseif a:name == 'find'
        return LLMAgent_ToolFind(a:args)
    elseif a:name == 'grep'
        return LLMAgent_ToolGrep(a:args)
    elseif a:name == 'list_buffers'
        return LLMAgent_ToolListBuffers()
    else
        return {'ok': 0, 'error': 'Unknown tool name: "' . a:name . '". Available: read_file, write_file, patch, ls, find, grep, list_buffers.'}
    endif
endfunction

" Decode one tool call's arguments. OpenAI sends 'arguments' as a JSON
" string, but some servers send a pre-parsed object. Returns
" {'args': <dict>} on success or {'error': '...'} — a malformed arguments
" string must NOT crash the turn with an uncaught E474.
function! LLMAgent_ParseToolArgs(raw_args)
    if type(a:raw_args) == type({})
        return {'args': a:raw_args}
    endif
    if type(a:raw_args) == type('')
        try
            let l:decoded = json_decode(a:raw_args)
            if type(l:decoded) != type({})
                let l:decoded = {'_raw': l:decoded}
            endif
            return {'args': l:decoded}
        catch
            return {'error': 'malformed tool arguments'}
        endtry
    endif
    return {'error': 'unexpected tool arguments type'}
endfunction

" Short one-line summary of tool arguments for the sidebar log.
function! LLMAgent_ToolArgsSummary(args)
    if has_key(a:args, 'path')
        return a:args['path']
    endif
    if has_key(a:args, 'pattern')
        return a:args['pattern']
    endif
    return ''
endfunction

" The assistant message that must be appended to the conversation history
" from one OpenAI chat-completion response (or {} when the response carries
" no choices at all). Keeping the raw message preserves tool_calls ids, the
" content, and any provider-specific extras the next request round-trips.
function! LLMAgent_ResponseMessage(data)
    if !has_key(a:data, 'choices') || empty(a:data['choices'])
        return {}
    endif
    return a:data['choices'][0]['message']
endfunction

" True when an OpenAI response message carries a non-empty content string.
function! LLMAgent_MessageHasText(message)
    let l:content = get(a:message, 'content', '')
    return type(l:content) == type('') ? !empty(trim(l:content)) : !empty(l:content)
endfunction

" Normalize a tool result into a flat string for sending back to the LLM.
" On success: returns the content. On failure: prefixes the error with a
" clear tag and a hint so the LLM can self-correct.
function! LLMAgent_FormatToolResult(tool_name, result)
    if !has_key(a:result, 'ok')
        " Backwards compat: old tools returned {content, error} only.
        if has_key(a:result, 'error')
            return '[TOOL_ERROR: ' . a:tool_name . '] ' . a:result['error']
        endif
        return get(a:result, 'content', '')
    endif
    if a:result['ok']
        return get(a:result, 'content', '')
    endif
    let l:err = get(a:result, 'error', 'unknown error')
    return '[TOOL_ERROR: ' . a:tool_name . '] ' . l:err
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Private Functions - Sidebar
""""""""""""""""""""""""""""""""""""""""""""""""""""""

" One-line status string naming the active backend and the model it uses.
" Shown at the top of the chat buffer so it's clear which engine is driving
" the tool. For 'api' the model is g:llm_agent_model; for 'acp' the model is
" whatever the ACP agent (e.g. claude-agent-acp) provides, so label it by the
" agent rather than a user-set model name.
function! LLMAgent_StatusLine()
    if g:llm_agent_backend ==# 'acp'
        " Use the agent name the ACP server reported at initialize
        " (e.g. "OpenCode", "Claude Code"); fall back to the command.
        let l:model = empty(s:acp_agent_name) ? g:llm_agent_acp_cmd : s:acp_agent_name
    else
        let l:model = g:llm_agent_model
    endif
    return 'mode: ' . g:llm_agent_backend . '  |  model: ' . l:model
endfunction

function! LLMAgent_SidebarOpen()
    let l:sidebar_width = LLMAgent_GetSidebarWidth()
    let l:input_height = LLMAgent_GetInputHeight()

    " Check if sidebar already exists (chat buffer)
    let l:chat_buf = bufnr('LLMAgent-Chat')
    if l:chat_buf > 0
        let l:chat_win = bufwinnr(l:chat_buf)
        if l:chat_win > 0
            " Sidebar exists — resize to match current terminal
            call LLMAgent_ResizeSidebarWindows(l:sidebar_width, l:input_height)
            let l:input_buf = bufnr('LLMAgent-Input')
            let l:input_win = bufwinnr(l:input_buf)
            if l:input_win > 0
                execute l:input_win . 'wincmd w'
                return
            endif
            execute l:chat_win . 'wincmd w'
            return
        endif
    endif

    " Create sidebar: vertical split at dynamic width
    if g:llm_agent_sidebar == 'left'
        execute 'leftabove ' . l:sidebar_width . 'vnew'
    elseif g:llm_agent_sidebar == 'bottom'
        execute 'below ' . l:sidebar_width . 'new'
    else
        execute 'rightbelow ' . l:sidebar_width . 'vnew'
    endif

    " Top area: Chat buffer
    silent file LLMAgent-Chat
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    setlocal nonumber
    setlocal norelativenumber
    setlocal signcolumn=no
    setlocal wrap
    setlocal linebreak
    setlocal breakindent
    setlocal breakindentopt=shift:2
    setlocal showbreak=
    setlocal filetype=markdown
    if line('$') == 1 && getline(1) == ''
        call setline(1, '=== LLM Agent ===')
        call append(1, LLMAgent_StatusLine())
        call append(2, '')
    endif
    setlocal nomodifiable

    " Bottom area: Input buffer
    below new
    execute 'resize ' . l:input_height
    silent file LLMAgent-Input
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    setlocal nonumber
    setlocal norelativenumber
    setlocal signcolumn=no
    setlocal wrap
    setlocal linebreak
    setlocal breakindent
    setlocal modifiable
    nnoremap <buffer> <silent> <CR> :call LLMAgent_SendInput()<CR>

    " Focus goes to input buffer
    let l:input_buf = bufnr('LLMAgent-Input')
    if l:input_buf > 0
        let l:input_win = bufwinnr(l:input_buf)
        if l:input_win > 0
            execute l:input_win . 'wincmd w'
        endif
    endif
endfunction

function! LLMAgent_ResizeSidebarWindows(sidebar_width, input_height)
    let l:chat_buf = bufnr('LLMAgent-Chat')
    let l:chat_win = bufwinnr(l:chat_buf)
    if l:chat_win > 0
        execute l:chat_win . 'wincmd w'
        execute 'vertical resize ' . a:sidebar_width
    endif
    let l:input_buf = bufnr('LLMAgent-Input')
    let l:input_win = bufwinnr(l:input_buf)
    if l:input_win > 0
        execute l:input_win . 'wincmd w'
        execute 'resize ' . a:input_height
    endif
endfunction

function! LLMAgent_OnResize()
    if bufnr('LLMAgent-Chat') > 0 && bufwinnr(bufnr('LLMAgent-Chat')) > 0
        call LLMAgent_ResizeSidebarWindows(LLMAgent_GetSidebarWidth(), LLMAgent_GetInputHeight())
    endif
endfunction

" Color table for sidebar log prefixes. Colors are defined at script
" load (see the `hi default LLMAgentHi*` lines near the top) and are the
" same regardless of colorscheme.
"   You / Agent / Error / Warning each get their own color.
"   Anything else (Tool, Result, System) is gray.
function! LLMAgent_PrefixHiGroup(prefix)
    if a:prefix ==# 'You'
        return 'LLMAgentHiYou'
    elseif a:prefix ==# 'Agent'
        return 'LLMAgentHiAgent'
    elseif a:prefix ==# 'Error'
        return 'LLMAgentHiError'
    elseif a:prefix ==# 'Warning'
        return 'LLMAgentHiWarning'
    endif
    return 'LLMAgentHiOther'
endfunction

function! LLMAgent_SidebarLog(text, ...)
    let l:buf = bufnr('LLMAgent-Chat')
    if l:buf < 0
        return
    endif
    let l:win = bufwinnr(l:buf)
    if l:win < 0
        " Sidebar not visible, show it
        call LLMAgent_SidebarOpen()
    endif

    " Switch to chat buffer
    let l:cur_win = winnr()
    let l:chat_win = bufwinnr(bufnr('LLMAgent-Chat'))
    if l:chat_win != winnr()
        execute l:chat_win . 'wincmd w'
    endif

    setlocal modifiable
    let l:prefix = get(a:, 1, '')
    let l:text = substitute(a:text, '\r\n\|\r', "\n", 'g')

    " Split on newlines and append each line individually
    " (Vim's append() does NOT split embedded \n into separate buffer lines)
    let l:lines = split(l:text, "\n", 1)
    if empty(l:lines)
        let l:lines = ['']
    endif

    if !empty(l:prefix)
        call append('$', '[' . l:prefix . '] ' . l:lines[0])
        " Highlight the [Prefix] tag in the line we just added.
        let l:hi = LLMAgent_PrefixHiGroup(l:prefix)
        if !empty(l:hi)
            let l:ln = line('$')
            " priority 10 = same as default, but scoped to the chat
            " window so it disappears when the buffer is wiped.
            call matchaddpos(l:hi, [[ln, 1, len(l:prefix) + 2]], 10, -1, {'window': l:chat_win})
        endif
        let l:i = 1
        while l:i < len(l:lines)
            call append('$', l:lines[l:i])
            let l:i += 1
        endwhile
        if l:prefix == 'Agent' || l:prefix == 'You'
            call append('$', '')
        endif
    else
        for l:line in l:lines
            call append('$', l:line)
        endfor
    endif
    normal! G
    setlocal nomodifiable

    execute l:cur_win . 'wincmd w'
    redraw
endfunction

function! LLMAgent_SendInput()
    " Grab all text from the input buffer
    let l:input_buf = bufnr('LLMAgent-Input')
    if l:input_buf < 0
        return
    endif
    let l:text = join(getbufline(l:input_buf, 1, '$'), "\n")
    let l:text = substitute(l:text, '\n\+$', '', '')
    if empty(l:text)
        return
    endif

    " Update working buffer: find the non-sidebar window
    let l:chat_buf = bufnr('LLMAgent-Chat')
    for l:w in range(1, winnr('$'))
        let l:b = winbufnr(l:w)
        if l:b != l:chat_buf && l:b != l:input_buf && buflisted(l:b)
            let l:bname = bufname(l:b)
            if !empty(l:bname) && l:bname !~ '^LLMAgent-'
                let s:llm_agent_working_buf = l:b
                break
            endif
        endif
    endfor

    " Log user message to chat
    call LLMAgent_SidebarLog(l:text, 'You')

    " Clear input buffer
    let l:cur_win = winnr()
    let l:input_win = bufwinnr(l:input_buf)
    execute l:input_win . 'wincmd w'
    setlocal modifiable
    %delete _
    execute l:cur_win . 'wincmd w'

    " Continue the conversation
    call LLMAgent_ContinueChat(l:text)
endfunction

" Show a unified diff (current on-disk content vs proposed content) for each
" queued write, so the user can see exactly what will change before approving.
" Renders into the chat buffer with per-line highlighting: green for added
" lines, red for removed lines, purple for @@ hunk markers, gray for the
" file header. No-op if the file doesn't exist yet (new file).
function! LLMAgent_ShowApprovalDiff(write_list)
    for l:entry in a:write_list
        let l:path = l:entry['path']
        if !filereadable(l:path)
            call LLMAgent_SidebarLog('NEW FILE: ' . l:path, 'System')
            continue
        endif
        let l:old = tempname()
        let l:new = tempname()
        call writefile(readfile(l:path), l:old)
        call writefile(split(l:entry['content'], "\n", 1), l:new)
        let l:diff = system('diff -u --label a/' . shellescape(fnamemodify(l:path, ':t')) . ' --label b/' . shellescape(fnamemodify(l:path, ':t')) . ' ' . shellescape(l:old) . ' ' . shellescape(l:new) . ' 2>&1')
        call delete(l:old)
        call delete(l:new)
        if empty(l:diff)
            continue
        endif
        call LLMAgent_SidebarLog('Diff for ' . l:path . ':', 'System')
        call LLMAgent_RenderDiff(l:diff)
    endfor
endfunction

" Append a unified diff to the chat buffer, one line at a time, with
" per-line highlight groups so additions/removals/hunks are color-coded.
function! LLMAgent_RenderDiff(diff)
    let l:buf = bufnr('LLMAgent-Chat')
    if l:buf < 0
        return
    endif
    let l:cur_win = winnr()
    let l:chat_win = bufwinnr(l:buf)
    if l:chat_win != winnr()
        execute l:chat_win . 'wincmd w'
    endif
    setlocal modifiable
    let l:lines = split(a:diff, "\n", 1)
    for l:line in l:lines
        call append('$', l:line)
        let l:ln = line('$')
        let l:hi = ''
        if l:line =~# '^@@'
            let l:hi = 'LLMAgentHiDiffHunk'
        elseif l:line =~# '^---\|^+++'
            let l:hi = 'LLMAgentHiDiffFile'
        elseif l:line =~# '^+'
            let l:hi = 'LLMAgentHiDiffAdd'
        elseif l:line =~# '^-'
            let l:hi = 'LLMAgentHiDiffDel'
        endif
        if !empty(l:hi)
            call matchaddpos(l:hi, [[l:ln, 1, len(l:line)]], 10, -1, {'window': l:chat_win})
        endif
    endfor
    normal! G
    setlocal nomodifiable
    execute l:cur_win . 'wincmd w'
    redraw
endfunction

function! LLMAgent_SidebarShowApproval(write_list)
    " Show approval prompt in the input area
    let l:input_buf = bufnr('LLMAgent-Input')
    if l:input_buf < 0
        return
    endif
    let l:cur_win = winnr()
    let l:input_win = bufwinnr(l:input_buf)
    execute l:input_win . 'wincmd w'

    " Save the normal input state
    let s:llm_agent_saved_input = getbufline(l:input_buf, 1, '$')

    " Write approval prompt to input buffer
    setlocal modifiable
    %delete _
    call setline(1, '┌─────────────────────────────────────────┐')
    call setline(2, '│ APPROVE ' . len(a:write_list) . ' write(s):')
    let l:row = 3
    for l:entry in a:write_list
        call setline(l:row, '│   ' . l:entry['path'] . ' (' . len(l:entry['content']) . ' bytes)')
        let l:row += 1
    endfor
    call setline(l:row, '│')
    call setline(l:row + 1, '│ Enter=apply  q=reject')
    call setline(l:row + 2, '└─────────────────────────────────────────┘')
    setlocal nomodifiable

    " Override input keymaps for approval
    silent! nunmap <buffer> <CR>
    nnoremap <buffer> <silent> <CR> :call LLMAgent_SidebarApprove()<CR>
    nnoremap <buffer> <silent> q :call LLMAgent_SidebarReject()<CR>
    nnoremap <buffer> <silent> <Esc> :call LLMAgent_SidebarReject()<CR>

    execute l:cur_win . 'wincmd w'
endfunction

function! LLMAgent_SidebarApprove()
    call LLMAgent_SidebarLog('Applied ' . len(s:llm_agent_write_list) . ' write(s)', 'System')
    call LLMAgent_ApplyWrites(s:llm_agent_write_list)
    call LLMAgent_RestoreInputKeymaps()
endfunction

function! LLMAgent_SidebarReject()
    call LLMAgent_SidebarLog('Writes rejected (' . len(s:llm_agent_write_list) . ' file(s))', 'System')
    call LLMAgent_RestoreInputKeymaps()
endfunction

function! LLMAgent_RestoreInputKeymaps()
    " Restore input buffer to normal editable state
    let l:input_buf = bufnr('LLMAgent-Input')
    if l:input_buf < 0
        return
    endif
    let l:cur_win = winnr()
    let l:input_win = bufwinnr(l:input_buf)
    execute l:input_win . 'wincmd w'

    silent! nunmap <buffer> <CR>
    silent! nunmap <buffer> q
    silent! nunmap <buffer> <Esc>
    nnoremap <buffer> <silent> <CR> :call LLMAgent_SendInput()<CR>

    setlocal modifiable
    %delete _

    execute l:cur_win . 'wincmd w'
endfunction

function! LLMAgent_ClearChat()
    let l:buf = bufnr('LLMAgent-Chat')
    if l:buf < 0
        return
    endif
    let l:cur_win = winnr()
    let l:chat_win = bufwinnr(l:buf)
    execute l:chat_win . 'wincmd w'
    setlocal modifiable
    %delete _
    call setline(1, '=== LLM Agent ===')
    call append(1, LLMAgent_StatusLine())
    call append(2, '')
    setlocal nomodifiable
    execute l:cur_win . 'wincmd w'
    let s:llm_agent_messages = []
    call LLMAgent_SidebarLog('Chat cleared', 'System')
endfunction

function! LLMAgent_ContinueChat(user_text)
    " In-flight guard (api backend): don't append a follow-up while a curl job
    " is running — it would collide on shared state. ACP has its own pending
    " state and is unaffected (s:llm_agent_api_job stays v:null there).
    if LLMAgent_JobRunning(s:llm_agent_api_job)
        call LLMAgent_SidebarLog('A turn is already running; use :LLMStop to cancel.', 'Warning')
        return
    endif
    if empty(s:llm_agent_messages)
        " No prior conversation; start a new agent session
        let s:llm_agent_messages = [
            \ {'role': 'system', 'content': LLMAgent_GetAgentSystemPrompt()},
            \ {'role': 'user', 'content': a:user_text}
            \ ]
    else
        call add(s:llm_agent_messages, {'role': 'user', 'content': a:user_text})
    endif
    call LLMAgent_RunWithTools('')
endfunction

" Final step of an agent turn: log the assistant's reply to the chat, then
" route any queued file writes through the user's approval / apply / skip
" flow. Callers can pass an empty a:content if they only want to flush the
" write list (e.g. when bailing out of the tool loop after max rounds).
function! LLMAgent_FinishAgentTurn(content)
    if !empty(a:content)
        call LLMAgent_SidebarLog(a:content, 'Agent')
    endif
    if empty(s:llm_agent_write_list)
        return
    endif
    if g:llm_agent_tool_confirm
        call LLMAgent_ShowApprovalDiff(s:llm_agent_write_list)
        call LLMAgent_SidebarShowApproval(s:llm_agent_write_list)
    else
        call LLMAgent_SidebarLog('Applying ' . len(s:llm_agent_write_list) . ' write(s)...', 'System')
        call LLMAgent_ApplyWrites(s:llm_agent_write_list)
    endif
endfunction

function! LLMAgent_RunWithTools(prompt)
    " Dispatch to the ACP backend.
    if g:llm_agent_backend == 'acp'
        call LLMAgent_RunWithToolsACP(a:prompt)
        return
    endif

    " In-flight guard: don't start a second turn while a curl job is running.
    " ACP has its own pending state and is handled by its own backend.
    if LLMAgent_JobRunning(s:llm_agent_api_job)
        call LLMAgent_SidebarLog('A turn is already running; use :LLMStop to cancel.', 'Warning')
        return
    endif

    let s:llm_agent_response_text = ''

    " Initialize messages if a prompt is given (new conversation)
    if !empty(a:prompt)
        let s:llm_agent_messages = [
            \ {'role': 'system', 'content': LLMAgent_GetAgentSystemPrompt()},
            \ {'role': 'user', 'content': a:prompt}
            \ ]
    endif

    let s:llm_agent_write_list = []
    let s:llm_agent_turn = 0
    let s:llm_agent_empty_count = 0
    let s:llm_agent_tools = LLMAgent_GetToolDefinitions()
    call LLMAgent_NextTurn()
endfunction

" Kick off the next agent turn (or the max-rounds final summary). Each turn
" yields to Vim's event loop while the curl job runs; LLMAgent_HandleAPIResponse
" resumes the loop when the response arrives.
function! LLMAgent_NextTurn()
    if s:llm_agent_turn >= g:llm_agent_tool_max_rounds
        call LLMAgent_SidebarLog('max rounds reached, asking for summary...', 'System')
        call add(s:llm_agent_messages, {'role': 'user', 'content': 'You have reached the limit of tool calls. Summarize what you found and any changes you made. Do NOT call any more tools.'})
        call LLMAgent_APIRequestAsync(s:llm_agent_messages, [], function('LLMAgent_HandleFinalResponse'))
        return
    endif
    call LLMAgent_SidebarLog('thinking... (' . (s:llm_agent_turn + 1) . '/' . g:llm_agent_tool_max_rounds . ')', 'Agent')
    let s:llm_agent_turn += 1
    call LLMAgent_APIRequestAsync(s:llm_agent_messages, s:llm_agent_tools, function('LLMAgent_HandleAPIResponse'))
endfunction

" Resume after an API response in the tool loop. Replaces the body of the old
" synchronous for-loop: on error stop; else either run tool calls and continue,
" or treat it as the final answer and finish the turn.
function! LLMAgent_HandleAPIResponse(data)
    if has_key(a:data, 'error')
        call LLMAgent_SidebarLog(a:data['error'], 'Error')
        return
    endif

    " An empty/missing choices array (content-filter, length-capped, some
    " server quirks) is the same class of "nothing output" as an empty reply.
    " Guard it instead of crashing on a:data['choices'][0].
    let l:message = LLMAgent_ResponseMessage(a:data)
    let l:has_tools = has_key(l:message, 'tool_calls') && !empty(l:message['tool_calls'])
    let l:content = get(l:message, 'content', '')
    let l:has_text = LLMAgent_MessageHasText(l:message)

    if l:has_tools
        let s:llm_agent_empty_count = 0
        call add(s:llm_agent_messages, l:message)

        for l:tool_call in l:message['tool_calls']
            let l:tool_name = l:tool_call['function']['name']
            " Arguments normally arrive as a JSON string (OpenAI spec), but
            " some servers send a pre-parsed object. Decode defensively via
            " LLMAgent_ParseToolArgs: a malformed arguments string must NOT
            " crash the turn with an uncaught E474.
            let l:parsed = LLMAgent_ParseToolArgs(get(l:tool_call['function'], 'arguments', ''))
            let l:tool_args = get(l:parsed, 'args', {})
            let l:args_err = get(l:parsed, 'error', '')

            " Log the tool call
            call LLMAgent_SidebarLog(l:tool_name . '(' . LLMAgent_ToolArgsSummary(l:tool_args) . ')', 'Tool')

            " Debug: record what the LLM asked for.
            let l:_evt = {}
            let l:_evt.kind = 'tool_call'
            let l:_evt.tool = l:tool_name
            let l:_evt.args = l:tool_args
            let l:_evt.id = get(l:tool_call, 'id', '')
            call LLMAgent_DebugLog(l:_evt)

            if !empty(l:args_err)
                " Could not parse arguments: report the error back to the model
                " as a tool result so it can retry, instead of throwing E474.
                call LLMAgent_SidebarLog(l:args_err, 'Error')
                let l:_evt = {'kind': 'tool_result', 'tool': l:tool_name, 'ok': 0, 'result_preview': l:args_err}
                call LLMAgent_DebugLog(l:_evt)
                let l:result_text = 'Error: ' . l:args_err . '. Please resend ' . l:tool_name . ' with valid JSON arguments.'
            else
                let l:tool_result = LLMAgent_ExecuteTool(l:tool_name, l:tool_args)
                let l:result_text = LLMAgent_FormatToolResult(l:tool_name, l:tool_result)

                " Debug: record what we sent back.
                let l:_evt = {}
                let l:_evt.kind = 'tool_result'
                let l:_evt.tool = l:tool_name
                let l:_evt.ok = get(l:tool_result, 'ok', -1)
                let l:_evt.result_preview = strpart(l:result_text, 0, 2000)
                let l:_evt.result_len = len(l:result_text)
                call LLMAgent_DebugLog(l:_evt)

                " Log truncated result in the sidebar (strip newlines to keep
                " the chat narrow). The full text still goes back to the LLM.
                let l:display = substitute(l:result_text, '\n', ' ', 'g')
                if len(l:display) > 80
                    let l:display = strpart(l:display, 0, 80) . '...'
                endif
                call LLMAgent_SidebarLog(l:display, 'Result')
            endif

            call add(s:llm_agent_messages, {
                \ 'role': 'tool',
                \ 'tool_call_id': get(l:tool_call, 'id', ''),
                \ 'content': l:result_text
                \ })
        endfor

        " Tools ran; start the next turn (async — returns to the event loop).
        call LLMAgent_NextTurn()
    elseif l:has_text
        " Final response - no more tool calls and we have a real answer.
        let s:llm_agent_empty_count = 0
        let s:llm_agent_response_text = get(l:message, 'content', '')
        call add(s:llm_agent_messages, l:message)
        call LLMAgent_FinishAgentTurn(s:llm_agent_response_text)
    else
        " Nothing usable: no tool calls and no text (or no choices at all).
        " Don't silently finish with empty content. Nudge the model to recover,
        " bounded by a consecutive-empty counter so it can't loop forever (the
        " max_rounds ceiling bounds it too). The nudge reuses the turn slot
        " this empty response consumed, so it does not burn extra budget:
        " NextTurn re-increments and re-checks the ceiling.
        let s:llm_agent_empty_count += 1
        if s:llm_agent_empty_count <= 2
            call LLMAgent_SidebarLog('empty response, retrying (' . s:llm_agent_empty_count . '/2)...', 'System')
            call add(s:llm_agent_messages, {'role': 'user', 'content': 'Your last response was empty. Either call a tool to make progress, or give your final text answer. Do not return an empty reply.'})
            let s:llm_agent_turn -= 1
            call LLMAgent_NextTurn()
        else
            call LLMAgent_SidebarLog('model produced no usable output after retries, stopping.', 'Error')
            call LLMAgent_FinishAgentTurn('')
        endif
    endif
endfunction

" Resume after the max-rounds final summary request.
function! LLMAgent_HandleFinalResponse(data)
    let l:message = has_key(a:data, 'error') ? {} : LLMAgent_ResponseMessage(a:data)
    if !empty(l:message)
        let s:llm_agent_response_text = get(l:message, 'content', '')
        call add(s:llm_agent_messages, l:message)
    elseif has_key(a:data, 'error')
        call LLMAgent_SidebarLog(a:data['error'], 'Error')
    else
        call LLMAgent_SidebarLog('LLM stopped responding.', 'Error')
    endif
    call LLMAgent_FinishAgentTurn(s:llm_agent_response_text)
endfunction

function! LLMAgent_ApplyWrites(write_list)
    for l:entry in a:write_list
        let l:dir = fnamemodify(l:entry['path'], ':h')
        if !empty(l:dir) && !isdirectory(l:dir)
            call mkdir(l:dir, 'p')
        endif
        let l:lines = split(l:entry['content'], '\n')
        call writefile(l:lines, l:entry['path'])
        echo 'LLMAgent: wrote ' . l:entry['path'] . ' (' . len(l:entry['content']) . ' bytes)'
    endfor
    call LLMAgent_ReloadWrittenBuffers(a:write_list)
endfunction

function! LLMAgent_ReloadWrittenBuffers(write_list)
    " Collect written paths as absolute paths for comparison
    let l:written_paths = {}
    for l:entry in a:write_list
        let l:abs = fnamemodify(l:entry['path'], ':p')
        let l:written_paths[l:abs] = 1
    endfor

    for l:i in range(1, bufnr('$'))
        if !buflisted(l:i)
            continue
        endif
        let l:buf_path = fnamemodify(bufname(l:i), ':p')
        if !has_key(l:written_paths, l:buf_path)
            continue
        endif
        " This buffer corresponds to a written file
        if getbufvar(l:i, '&modified')
            call LLMAgent_SidebarLog('Buffer ' . bufname(l:i) . ' has unsaved changes — save before reload', 'Warning')
        else
            " Reload the buffer silently
            let l:cur_win = winnr()
            let l:buf_win = bufwinnr(l:i)
            if l:buf_win > 0
                execute l:buf_win . 'wincmd w'
                edit!
                execute l:cur_win . 'wincmd w'
            endif
        endif
    endfor
endfunction

" Reload every open buffer whose file content differs from what's on disk.
" Used after an ACP turn, where the agent (e.g. opencode) writes files
" directly to disk and bypasses our write queue, so the Vim buffers go
" stale. Skips buffers with unsaved local changes (warns instead).
" Compares content (not mtime) so it also catches same-second writes.
function! LLMAgent_ReloadChangedBuffers()
    for l:i in range(1, bufnr('$'))
        if !buflisted(l:i)
            continue
        endif
        let l:path = bufname(l:i)
        if empty(l:path) || !filereadable(l:path)
            continue
        endif
        if getbufvar(l:i, '&modified')
            " Unsaved local edits: don't clobber them.
            continue
        endif
        " Compare the buffer's lines against the file on disk.
        let l:buf_lines = getbufline(l:i, 1, '$')
        let l:disk_lines = readfile(l:path)
        if l:buf_lines ==# l:disk_lines
            continue
        endif
        " Reload the buffer silently.
        let l:cur_win = winnr()
        let l:buf_win = bufwinnr(l:i)
        if l:buf_win > 0
            execute l:buf_win . 'wincmd w'
            edit!
            execute l:cur_win . 'wincmd w'
        endif
    endfor
endfunction

function! LLMAgent_Execute(action, context, user_input, mode)
    let l:system_prompt = LLMAgent_GetAgentSystemPrompt()

    " Build user prompt based on action
    if a:action == 'explain'
        let l:prompt = g:llm_agent_prompt_explain . "\n" . a:context
    elseif a:action == 'fix'
        let l:prompt = g:llm_agent_prompt_fix . "\n" . a:context
    elseif a:action == 'refactor'
        let l:prompt = g:llm_agent_prompt_refactor . "\n" . a:context
    elseif a:action == 'write'
        let l:prompt = g:llm_agent_prompt_write . "\n" . a:user_input
    elseif a:action == 'custom'
        let l:prompt = a:user_input
    else
        " 'ask' - user provides free-form prompt, context attached if present
        let l:prompt = a:user_input
        if !empty(a:context)
            let l:prompt .= "\n\nContext:\n" . a:context
        endif
    endif

    echo 'LLMAgent: thinking...'

    " Note: streaming is not implemented; the single-shot path is used instead.
    " g:llm_agent_streaming is preserved for backward compatibility.

    " Build source info for accept. Prefer the working buffer pinned by the
    " command, but fall back to the current buffer (which may differ if the
    " user switched windows between command and result). Capture this BEFORE
    " the async dispatch: the response arrives later when cursor/'< may have
    " moved.
    let l:source_buf = exists('s:llm_agent_working_buf') && bufexists(s:llm_agent_working_buf)
        \ ? s:llm_agent_working_buf
        \ : bufnr('%')
    if a:mode == 'write'
        let l:source_range = [line('.'), col('.')]
    elseif a:mode == 'replace'
        " source_range will be overridden by the command functions
        let l:source_range = [line("'<"), line("'>")]
    else
        let l:source_range = [line('.'), col('.')]
    endif

    if g:llm_agent_backend == 'api'
        " Async, non-blocking: stash the display params for the callback, then
        " return control to Vim while curl runs.
        if LLMAgent_JobRunning(s:llm_agent_api_job)
            call LLMAgent_SidebarLog('A turn is already running; use :LLMStop to cancel.', 'Warning')
            return
        endif
        let s:llm_agent_single_ctx = {'source_buf': l:source_buf, 'source_range': l:source_range, 'mode': a:mode}
        let l:messages = [
            \ {'role': 'system', 'content': l:system_prompt},
            \ {'role': 'user', 'content': l:prompt}
            \ ]
        call LLMAgent_APIRequestAsync(l:messages, [], function('LLMAgent_OnSingleResponse'))
        return
    endif

    " ACP backend: one-shot query via the ACP session (synchronous), then
    " display the result through the same accept/replace window as the api path.
    let l:full_prompt = l:system_prompt . "\n\n" . l:prompt
    let l:result = LLMAgent_ACPOneShot(l:full_prompt)
    if has_key(l:result, 'error')
        echo 'LLMAgent error: ' . l:result['error']
        return
    endif
    redraw
    call LLMAgent_DisplayOpen(l:result['content'], l:source_buf, l:source_range, a:mode)
endfunction

" Async callback for the single-shot (ask/explain/write) path on the api
" backend. Opens the display window with the response using the params stashed
" in s:llm_agent_single_ctx by LLMAgent_Execute.
function! LLMAgent_OnSingleResponse(data)
    let l:ctx = s:llm_agent_single_ctx
    let s:llm_agent_single_ctx = {}
    if has_key(a:data, 'error')
        echo 'LLMAgent error: ' . a:data['error']
        return
    endif
    let l:message = LLMAgent_ResponseMessage(a:data)
    if empty(l:message)
        echo 'LLMAgent error: empty response'
        return
    endif
    redraw
    call LLMAgent_DisplayOpen(get(l:message, 'content', ''), l:ctx['source_buf'], l:ctx['source_range'], l:ctx['mode'])
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Public Commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""

" LLMChat - Open the chat sidebar (tool-enabled AI agent: read_file,
" write_file, ls, find, grep, list_buffers).
command! -nargs=? -range LLMChat call LLMAgent_CommandChat(<q-args>)
function! LLMAgent_CommandChat(args)
    let l:buf = bufnr('%')
    let l:sel = LLMAgent_CaptureSelection()
    let l:prompt = a:args

    " If no args, check for input prompt
    if empty(l:prompt)
        let l:prompt = input('LLM Chat: ')
    endif

    " Empty prompt with no selection = open empty chat sidebar
    if empty(l:prompt) && l:sel['mode'] ==# 'none'
        let s:llm_agent_working_buf = l:buf
        call LLMAgent_Reset()
        call LLMAgent_SidebarOpen()
        return
    endif

    if empty(l:prompt)
        return
    endif

    " Attach a structured location block so the LLM knows the file, range, and
    " line numbers — not just a blob of selected text.
    let l:loc = LLMAgent_BuildLocationContext(l:buf, l:sel['line1'], l:sel['line2'], l:sel['mode'])
    if !empty(l:loc)
        let l:prompt .= "\n\n" . l:loc
    endif

    let s:llm_agent_working_buf = l:buf
    call LLMAgent_Reset()
    call LLMAgent_SidebarOpen()
    call LLMAgent_SidebarLog(l:prompt, 'You')
    call LLMAgent_RunWithTools(l:prompt)
endfunction

" LLMAsk - Free-form question, optional visual selection as context
command! -nargs=? -range LLMAsk call LLMAgent_CommandAsk(<q-args>)
function! LLMAgent_CommandAsk(args)
    let l:buf = bufnr('%')
    let s:llm_agent_working_buf = l:buf
    let l:sel = LLMAgent_CaptureSelection()
    let l:prompt = a:args
    if empty(l:prompt)
        let l:prompt = input('LLM Ask: ')
    endif
    if empty(l:prompt)
        return
    endif
    let l:loc = LLMAgent_BuildLocationContext(l:buf, l:sel['line1'], l:sel['line2'], l:sel['mode'])
    if !empty(l:loc)
        let l:prompt .= "\n\n" . l:loc
    endif
    call LLMAgent_Execute('ask', '', l:prompt, 'view')
endfunction

" LLMAskExplain - One-shot: explain selected code or word under cursor.
command! -range LLMAskExplain call LLMAgent_CommandExplain()
function! LLMAgent_CommandExplain()
    let l:buf = bufnr('%')
    let s:llm_agent_working_buf = l:buf
    let l:sel = LLMAgent_CaptureSelection()
    if l:sel['mode'] ==# 'none'
        " No visual selection — explain the cursor line
        let l:line = line('.')
        let l:ctx = getline(l:line)
        if empty(l:ctx)
            echo 'LLMAgent: nothing to explain'
            return
        endif
        let l:loc = LLMAgent_BuildLocationContext(l:buf, l:line, l:line, 'cursor')
        call LLMAgent_Execute('explain', l:loc, '', 'view')
        return
    endif
    let l:loc = LLMAgent_BuildLocationContext(l:buf, l:sel['line1'], l:sel['line2'], 'range')
    if empty(l:loc)
        echo 'LLMAgent: nothing to explain'
        return
    endif
    call LLMAgent_Execute('explain', l:loc, '', 'view')
endfunction

" LLMChatReset - Wipe in-memory conversation state (multi-turn history,
" write queue, working-buffer pin). The sidebar display buffer is preserved;
" use :LLMChatClear to wipe that too.
command! LLMChatReset call LLMAgent_Reset() | call LLMAgent_SidebarLog('Session reset (history cleared)', 'System')

" LLMChatStop - Cancel an in-flight agent turn (the async curl job) and
" free the tool loop so a new turn can start immediately.
command! LLMChatStop call LLMAgent_Stop()

" LLMChatClear - Clear chat history (sidebar display only).
command! LLMChatClear call LLMAgent_ClearChat()

" LLMChatDebug [on|off|path] - Toggle or set the debug log location. When
" on, every API request/response and every tool call is appended as a JSON
" line to the log file, so you can share the log to debug misbehavior.
command! -nargs=? LLMChatDebug call LLMAgent_DebugCmd(<q-args>)
function! LLMAgent_DebugCmd(arg)
    if a:arg ==# 'off' || a:arg ==# '0'
        let g:llm_agent_debug = 0
        echo 'LLMAgent debug logging: OFF'
        return
    endif
    if a:arg ==# 'on'
        let g:llm_agent_debug = 1
    elseif !empty(a:arg)
        let g:llm_agent_debug_file = expand(a:arg)
        let g:llm_agent_debug = 1
    elseif empty(g:llm_agent_debug_file)
        " First-time :LLMDebug: pick a default in cwd.
        let g:llm_agent_debug_file = getcwd() . '/llmagent-debug.jsonl'
        let g:llm_agent_debug = 1
    else
        let g:llm_agent_debug = !g:llm_agent_debug
    endif
    if g:llm_agent_debug
        " Truncate the log so each :LLMDebug session starts fresh.
        try | call writefile([], g:llm_agent_debug_file) | catch | endtry
        echo 'LLMAgent debug logging: ON -> ' . g:llm_agent_debug_file
    else
        echo 'LLMAgent debug logging: OFF (file kept at ' . g:llm_agent_debug_file . ')'
    endif
endfunction

" LLMChatToggle - Toggle sidebar open/close.
command! LLMChatToggle call LLMAgent_ToggleSidebar()
function! LLMAgent_ToggleSidebar()
    let l:chat_buf = bufnr('LLMAgent-Chat')
    if l:chat_buf > 0
        let l:chat_win = bufwinnr(l:chat_buf)
        if l:chat_win > 0
            " Sidebar is visible, close it
            execute l:chat_win . 'wincmd c'
            let l:input_buf = bufnr('LLMAgent-Input')
            if l:input_buf > 0
                let l:input_win = bufwinnr(l:input_buf)
                if l:input_win > 0
                    execute l:input_win . 'wincmd c'
                endif
            endif
            return
        endif
    endif
    " Sidebar not visible, open it
    call LLMAgent_SidebarOpen()
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Keymaps
""""""""""""""""""""""""""""""""""""""""""""""""""""""

if g:llm_agent_enable_keymaps
    " Visual mode - operate on selection
    xnoremap <silent> <Leader>la :<C-u>LLMAsk<CR>
    xnoremap <silent> <Leader>le :<C-u>LLMExplain<CR>
    xnoremap <silent> <Leader>lg :<C-u>LLMAgent<CR>

    " Normal mode
    nnoremap <silent> <Leader>la :LLMAsk<CR>
    nnoremap <silent> <Leader>le :LLMExplain<CR>
    nnoremap <silent> <Leader>lg :LLMAgent<CR>
endif

" Restore the user's 'cpoptions'.
let &cpoptions = s:save_cpo
unlet s:save_cpo
