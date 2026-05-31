" File: LLMAgent.vim
" Description: AI-powered code assistant using LLM APIs or CLI tools.
"   Backend 'api': Uses OpenAI-compatible API with function-calling tools.
"   Backend 'cli': Uses ACP (Agent Client Protocol) JSON-RPC over stdio.
"     Compatible ACP tools:
"       - Claude:  npx -y @agentclientprotocol/claude-agent-acp  (API key)
"       - Claude:  npx -y claude-code-acp                        (Pro/Max subscription)
"       - Gemini:  gemini --experimental-acp -p ""               (built-in)
"       - Copilot: copilot --acp --stdio                        (built-in)
" Usage:
"   :LLMAsk [prompt]       - Ask a question to the LLM
"   :LLMExplain            - Explain selected code or word under cursor
"   :LLMFix                - Fix selected code
"   :LLMRefactor           - Refactor selected code
"   :LLMWrite [prompt]     - Generate code from prompt
"   :LLMDiff               - Show diff of proposed changes
"   :LLMPatch              - Apply LLM changes directly
"
" Dependencies: curl (for API mode), Node.js (for claude-agent-acp)
" Supported: Vim 8+, Neovim

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup LLMAgentGroup
    autocmd!
    autocmd VimResized * call LLMAgent_OnResize()
    autocmd VimLeavePre * call LLMAgent_StopACP()
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Variables
""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:llm_agent_backend         = get(g:, 'llm_agent_backend', 'api')
let g:llm_agent_cli_cmd         = get(g:, 'llm_agent_cli_cmd', 'claude')
let g:llm_agent_api_url         = get(g:, 'llm_agent_api_url', 'http://localhost:11434/v1')
let g:llm_agent_api_key         = get(g:, 'llm_agent_api_key', '')
let g:llm_agent_model           = get(g:, 'llm_agent_model', 'minimax-m2.7:cloud')
let g:llm_agent_streaming       = get(g:, 'llm_agent_streaming', 0)
let g:llm_agent_enable_keymaps  = get(g:, 'llm_agent_enable_keymaps', 0)
let g:llm_agent_system_prompt   = get(g:, 'llm_agent_system_prompt', '')
let g:llm_agent_timeout         = get(g:, 'llm_agent_timeout', 60)
let g:llm_agent_prompt_write    = get(g:, 'llm_agent_prompt_write', 'Write code for the following request. Return ONLY the code, no markdown fences, no explanation:')
let g:llm_agent_prompt_explain  = get(g:, 'llm_agent_prompt_explain', 'Explain the following code concisely:')
let g:llm_agent_prompt_fix      = get(g:, 'llm_agent_prompt_fix', 'Fix any bugs or issues in the following code. Return ONLY the corrected code, no markdown fences, no explanation:')
let g:llm_agent_prompt_refactor = get(g:, 'llm_agent_prompt_refactor', 'Refactor the following code to be cleaner and more efficient. Return ONLY the refactored code, no markdown fences, no explanation:')
let g:llm_agent_tool_max_rounds  = get(g:, 'llm_agent_tool_max_rounds', 10)
let g:llm_agent_tool_confirm     = get(g:, 'llm_agent_tool_confirm', 1)
let g:llm_agent_sidebar          = get(g:, 'llm_agent_sidebar', 'right')
let g:llm_agent_acp_cmd           = get(g:, 'llm_agent_acp_cmd', 'npx -y @agentclientprotocol/claude-agent-acp')
let g:llm_agent_acp_auto_approve  = get(g:, 'llm_agent_acp_auto_approve', 0)
let g:llm_agent_acp_max_rounds    = get(g:, 'llm_agent_acp_max_rounds', 20)

function! LLMAgent_GetSidebarWidth()
    return max([40, float2nr(&columns * 0.3)])
endfunction

function! LLMAgent_GetInputHeight()
    return max([5, min([10, float2nr(&lines * 0.15)])])
endfunction

" Script-local state for multi-turn conversation
let s:llm_agent_messages = []

" ACP (Agent Client Protocol) state
let s:acp_job_id = -1
let s:acp_session_id = ''
let s:acp_pending_reqs = {}
let s:acp_prompt_resolved = 0
let s:acp_write_list = []
let s:acp_response_text = ''
let s:acp_turn_error = ''
let s:acp_next_req_id = 1
let s:acp_current_action = ''  " tracks the LLMAgent action for context

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Tool Definitions (OpenAI function-calling format)
""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! LLMAgent_GetToolDefinitions()
    return [
        \ {
        \   'type': 'function',
        \   'function': {
        \     'name': 'read_file',
        \     'description': 'Read the contents of a file. Optionally specify a line range.',
        \     'parameters': {
        \       'type': 'object',
        \       'properties': {
        \         'path': {'type': 'string', 'description': 'Path to the file to read'},
        \         'start_line': {'type': 'integer', 'description': 'Optional: starting line number (1-based)'},
        \         'end_line': {'type': 'integer', 'description': 'Optional: ending line number (inclusive)'}
        \       },
        \       'required': ['path']
        \     }
        \   }
        \ },
        \ {
        \   'type': 'function',
        \   'function': {
        \     'name': 'write_file',
        \     'description': 'Write or create a file with the given content. Changes will be shown as a diff for approval before applying.',
        \     'parameters': {
        \       'type': 'object',
        \       'properties': {
        \         'path': {'type': 'string', 'description': 'Path to the file to write'},
        \         'content': {'type': 'string', 'description': 'The complete file content to write'}
        \       },
        \       'required': ['path', 'content']
        \     }
        \   }
        \ },
        \ {
        \   'type': 'function',
        \   'function': {
        \     'name': 'ls',
        \     'description': 'List files and directories in a given directory.',
        \     'parameters': {
        \       'type': 'object',
        \       'properties': {
        \         'path': {'type': 'string', 'description': 'Directory path to list (defaults to current working directory)'}
        \       },
        \       'required': []
        \     }
        \   }
        \ },
        \ {
        \   'type': 'function',
        \   'function': {
        \     'name': 'find',
        \     'description': 'Find files matching a glob pattern.',
        \     'parameters': {
        \       'type': 'object',
        \       'properties': {
        \         'pattern': {'type': 'string', 'description': 'Glob pattern to match (e.g. "**/*.lua", "src/**/*.py")'}
        \       },
        \       'required': ['pattern']
        \     }
        \   }
        \ },
        \ {
        \   'type': 'function',
        \   'function': {
        \     'name': 'grep',
        \     'description': 'Search for a pattern within files. Returns matching file paths and line content.',
        \     'parameters': {
        \       'type': 'object',
        \       'properties': {
        \         'pattern': {'type': 'string', 'description': 'Regular expression pattern to search for'},
        \         'path': {'type': 'string', 'description': 'Directory or file path to search in (defaults to cwd)'},
        \         'glob': {'type': 'string', 'description': 'Optional file glob filter (e.g. "*.lua", "*.py")'}
        \       },
        \       'required': ['pattern']
        \     }
        \   }
        \ },
        \ {
        \   'type': 'function',
        \   'function': {
        \     'name': 'patch',
        \     'description': 'Apply a unified diff patch to a file. The diff must be in standard unified diff format (diff -u format with @@ markers). Changes are accumulated for approval.',
        \     'parameters': {
        \       'type': 'object',
        \       'properties': {
        \         'path': {'type': 'string', 'description': 'Path to the file to patch'},
        \         'diff': {'type': 'string', 'description': 'Unified diff content to apply (diff -u format)'}
        \       },
        \       'required': ['path', 'diff']
        \     }
        \   }
        \ },
        \ {
        \   'type': 'function',
        \   'function': {
        \     'name': 'list_buffers',
        \     'description': 'List all open Vim buffer names.',
        \     'parameters': {
        \       'type': 'object',
        \       'properties': {},
        \       'required': []
        \     }
        \   }
        \ }
        \ ]
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Private Functions - Utility
""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! LLMAgent_GetVisualSelection()
    let l:save_reg = @"
    let l:save_regtype = getregtype('"')
    try
        normal! gv"xy
        return @x
    finally
        let @" = l:save_reg
        call setreg('"', l:save_reg, l:save_regtype)
    endtry
endfunction

function! LLMAgent_GetContext(line1, line2)
    " Get context from range, or fall back to entire file
    if a:line1 != a:line2
        return join(getline(a:line1, a:line2), "\n")
    endif
    return join(getline(1, '$'), "\n")
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
        let l:buf_path = fnamemodify(bufname(s:llm_agent_working_buf), ':p')
    else
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
    let l:ft = ''
    if exists('s:llm_agent_working_buf') && bufexists(s:llm_agent_working_buf)
        let l:ft = getbufvar(s:llm_agent_working_buf, '&filetype')
    endif
    if !empty(l:ft)
        let l:info .= ' (' . l:ft . ')'
    endif
    return l:info
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Private Functions - Backend
""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! LLMAgent_CallAPI(messages)
    let l:body = {'model': g:llm_agent_model, 'messages': a:messages}
    let l:body_json = json_encode(l:body)

    let l:tmpfile = tempname()
    call writefile([l:body_json], l:tmpfile)

    let l:curl_cmd = 'curl -s -m ' . g:llm_agent_timeout
    if !empty(g:llm_agent_api_key)
        let l:curl_cmd .= ' -H "Authorization: Bearer ' . g:llm_agent_api_key . '"'
    endif
    let l:curl_cmd .= ' -H "Content-Type: application/json"'
    let l:curl_cmd .= ' -d @' . shellescape(l:tmpfile)
    let l:curl_cmd .= ' ' . shellescape(g:llm_agent_api_url . '/chat/completions')

    let l:response = system(l:curl_cmd)
    call delete(l:tmpfile)

    if v:shell_error != 0
        return {'error': 'curl failed (exit ' . v:shell_error . '): ' . l:response}
    endif

    try
        let l:data = json_decode(l:response)
    catch
        return {'error': 'Failed to parse JSON response: ' . l:response}
    endtry

    if has_key(l:data, 'error')
        return {'error': l:data['error']['message']}
    endif
    if has_key(l:data, 'choices') && len(l:data['choices']) > 0
        let l:content = l:data['choices'][0]['message']['content']
        return {'content': l:content}
    endif
    return {'error': 'Unexpected API response format'}
endfunction

function! LLMAgent_CallCLI(prompt)
    let l:tmpfile = tempname()
    call writefile([a:prompt], l:tmpfile)

    let l:cmd = g:llm_agent_cli_cmd . ' < ' . shellescape(l:tmpfile)
    let l:response = system(l:cmd)
    call delete(l:tmpfile)

    if v:shell_error != 0
        return {'error': 'CLI failed (exit ' . v:shell_error . '): ' . l:response}
    endif

    return {'content': l:response}
endfunction

function! LLMAgent_Call(system_prompt, user_prompt)
    if g:llm_agent_backend == 'api'
        let l:messages = [
            \ {'role': 'system', 'content': a:system_prompt},
            \ {'role': 'user', 'content': a:user_prompt}
            \ ]
        return LLMAgent_CallAPI(l:messages)
    else
        let l:full_prompt = a:system_prompt . "\n\n" . a:user_prompt
        return LLMAgent_CallCLI(l:full_prompt)
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Private Functions - ACP Process Management
""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! LLMAgent_EnsureACP()
    if s:acp_job_id > 0
        if has('nvim')
            try
                call jobpid(s:acp_job_id)
            catch
                let s:acp_job_id = -1
            endtry
        else
            if job_status(s:acp_job_id) == 'fail'
                let s:acp_job_id = -1
            endif
        endif
    endif

    if s:acp_job_id > 0
        return 1
    endif

    if has('nvim')
        let l:cmd_parts = split(g:llm_agent_acp_cmd)
        let s:acp_job_id = jobstart(l:cmd_parts, {
            \ 'on_stdout': function('LLMAgent_ACPOnStdout'),
            \ 'on_stderr': function('LLMAgent_ACPOnStderr'),
            \ 'on_exit': function('LLMAgent_ACPOnExit'),
            \ })
        if s:acp_job_id <= 0
            return 0
        endif
    else
        let s:acp_job_id = job_start(g:llm_agent_acp_cmd, {
            \ 'out_cb': function('LLMAgent_ACPOnStdout'),
            \ 'err_cb': function('LLMAgent_ACPOnStderr'),
            \ 'exit_cb': function('LLMAgent_ACPOnExit'),
            \ 'mode': 'nl',
            \ })
        if job_status(s:acp_job_id) == 'fail'
            let s:acp_job_id = -1
            return 0
        endif
    endif

    let s:acp_session_id = ''
    let s:acp_pending_reqs = {}
    let s:acp_prompt_resolved = 0
    let s:acp_next_req_id = 1
    return 1
endfunction

function! LLMAgent_StopACP()
    if s:acp_job_id > 0
        if has('nvim')
            call jobstop(s:acp_job_id)
        else
            call job_stop(s:acp_job_id)
        endif
    endif
    let s:acp_job_id = -1
    let s:acp_session_id = ''
    let s:acp_pending_reqs = {}
    let s:acp_prompt_resolved = 0
endfunction

function! LLMAgent_SendACP(msg)
    if s:acp_job_id <= 0
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

function! LLMAgent_ACPOnStdout(job_id, data, event)
    if has('nvim')
        let l:lines = a:data
    else
        " Vim: data is a single string, split by newline
        let l:lines = split(a:data, "\n", 1)
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

function! LLMAgent_ACPOnStderr(job_id, data, event)
    " Silently ignore stderr (ACP uses stdout for protocol messages)
endfunction

function! LLMAgent_ACPOnExit(job_id, exit_code, event)
    let s:acp_job_id = -1
    let s:acp_session_id = ''
    " If prompt was not yet resolved, mark with error
    if !s:acp_prompt_resolved
        let s:acp_turn_error = 'ACP process exited (code ' . a:exit_code . ')'
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
            if has_key(l:msg, 'error')
                call LLMAgent_ACPHandleError(l:id, l:req, l:msg['error'])
                return
            endif
            if l:req == 'session/new'
                let s:acp_session_id = l:msg['result']['sessionId']
                let s:acp_prompt_resolved = 0
            elseif l:req == 'session/prompt'
                let s:acp_prompt_resolved = 1
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
        let s:acp_terminal_running = 0
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
        if exists('s:acp_terminal_output')
            unlet s:acp_terminal_output
        endif
        let s:acp_terminal_running = 0
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

    " Handle ContentChunk streaming updates
    if has_key(l:update, 'content') && type(l:update['content']) == v:t_list
        for l:block in l:update['content']
            if has_key(l:block, 'type') && l:block['type'] == 'text'
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

function! LLMAgent_ACPSessionNew()
    if empty(s:acp_session_id)
        let l:id = s:acp_next_req_id
        let s:acp_next_req_id += 1
        let s:acp_pending_reqs[l:id] = 'session/new'
        let s:acp_prompt_resolved = 0
        let l:cwd = getcwd()
        call LLMAgent_SendACP({
            \ 'jsonrpc': '2.0',
            \ 'method': 'session/new',
            \ 'params': {'cwd': l:cwd, 'mcpServers': []},
            \ 'id': l:id,
            \ })
        " Wait for session to be created
        let l:waited = 0
        while empty(s:acp_session_id) && s:acp_job_id > 0 && l:waited < 50
            if has('nvim')
                call jobwait([s:acp_job_id], 100)
            else
                sleep 100m
            endif
            let l:waited += 1
        endwhile
    endif
    return !empty(s:acp_session_id)
endfunction

function! LLMAgent_RunWithToolsACP(prompt)
    let s:acp_response_text = ''
    let s:acp_write_list = []
    let s:acp_turn_error = ''
    let s:acp_prompt_resolved = 0

    " Start ACP process if not running
    if !LLMAgent_EnsureACP()
        call LLMAgent_SidebarLog('Failed to start ACP process', 'Error')
        return
    endif

    " Create session if needed
    if !LLMAgent_ACPSessionNew()
        call LLMAgent_SidebarLog('Failed to create ACP session', 'Error')
        return
    endif

    " Build prompt content blocks
    let l:content_blocks = []

    " Add system prompt if starting new conversation
    if !empty(a:prompt)
        let l:system_prompt = LLMAgent_GetSystemPrompt()
        let l:file_ctx = LLMAgent_GetFileContext()
        if !empty(l:file_ctx)
            let l:system_prompt .= "\n\n" . l:file_ctx
        endif
        let l:system_prompt .= "\n\nCRITICAL RULES:\n1. To see file content, use read_file. To write files, use write_file.\n2. After making changes, respond with a brief text summary.\n3. Stop calling tools when the task is complete.\n4. Format text responses with actual line breaks - use short paragraphs and markdown formatting."
    endif

    " Add conversation history from s:llm_agent_messages
    if empty(s:llm_agent_messages)
        " New conversation - build from system_prompt + user prompt
        if !empty(l:system_prompt)
            call add(l:content_blocks, {'type': 'text', 'text': l:system_prompt . "\n\n---\n\n" . a:prompt})
        else
            call add(l:content_blocks, {'type': 'text', 'text': a:prompt})
        endif
    else
        " Continue existing conversation - send full message history as formatted text
        let l:history = ''
        for l:msg in s:llm_agent_messages
            if l:msg['role'] == 'system'
                let l:history .= '[System]' . "\n" . l:msg['content'] . "\n\n"
            elseif l:msg['role'] == 'user'
                let l:history .= '[User]' . "\n" . l:msg['content'] . "\n\n"
            elseif l:msg['role'] == 'assistant'
                let l:history .= '[Assistant]' . "\n" . l:msg['content'] . "\n\n"
            elseif l:msg['role'] == 'tool'
                " Skip tool messages - they were side-effects
                continue
            endif
        endfor
        if !empty(a:prompt)
            let l:history .= '[User]' . "\n" . a:prompt
        endif
        if !empty(l:system_prompt)
            let l:history = l:system_prompt . "\n\n---\n\n" . l:history
        endif
        call add(l:content_blocks, {'type': 'text', 'text': l:history})
    endif

    " Send prompt
    let l:id = s:acp_next_req_id
    let s:acp_next_req_id += 1
    let s:acp_pending_reqs[l:id] = 'session/prompt'
    call LLMAgent_SendACP({
        \ 'jsonrpc': '2.0',
        \ 'method': 'session/prompt',
        \ 'params': {'sessionId': s:acp_session_id, 'prompt': l:content_blocks},
        \ 'id': l:id,
        \ })

    " Wait for the turn to complete (agent may call us back for tools)
    let l:waited = 0
    let l:max_wait = g:llm_agent_timeout * 10  " timeout * 10 polling cycles
    while !s:acp_prompt_resolved && s:acp_job_id > 0 && l:waited < l:max_wait
        if has('nvim')
            call jobwait([s:acp_job_id], 100)
        else
            sleep 100m
        endif
        let l:waited += 1
    endwhile

    if !s:acp_prompt_resolved && s:acp_job_id <= 0
        call LLMAgent_SidebarLog('ACP process died during turn', 'Error')
        return
    endif

    if !empty(s:acp_turn_error)
        call LLMAgent_SidebarLog(s:acp_turn_error, 'Error')
        return
    endif

    " Stream accumulated response to sidebar
    if !empty(s:acp_response_text)
        call LLMAgent_SidebarLog(s:acp_response_text, 'Agent')
    endif

    " Store in conversation history
    if empty(s:llm_agent_messages) && !empty(a:prompt)
        let l:system = LLMAgent_GetSystemPrompt()
        let l:file_ctx = LLMAgent_GetFileContext()
        if !empty(l:file_ctx)
            let l:system .= "\n\n" . l:file_ctx
        endif
        let s:llm_agent_messages = [
            \ {'role': 'system', 'content': l:system},
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
    if !empty(s:acp_write_list) && g:llm_agent_tool_confirm
        call LLMAgent_SidebarShowApproval(s:acp_write_list)
    elseif !empty(s:acp_write_list)
        call LLMAgent_ApplyWrites(s:acp_write_list)
    endif
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
    let l:path = a:args['path']
    let l:start = get(a:args, 'start_line', 0)
    let l:end = get(a:args, 'end_line', 0)
    let l:path = simplify(l:path)
    if l:path =~ '^\.\.'
        return {'error': 'Cannot read files outside the current directory'}
    endif
    if !filereadable(l:path)
        return {'error': 'File not found: ' . l:path}
    endif
    let l:lines = readfile(l:path)
    if l:start > 0 && l:end >= l:start
        let l:lines = l:lines[l:start - 1 : l:end - 1]
    endif
    let l:content = join(l:lines, "\n")
    if len(l:content) > 50000
        let l:content = strpart(l:content, 0, 50000) . "\n... (truncated)"
    endif
    return {'content': l:content}
endfunction

function! LLMAgent_ToolWriteFile(args)
    let l:path = simplify(a:args['path'])
    if l:path =~ '^\.\.'
        return {'error': 'Cannot write outside the current directory'}
    endif
    let l:content = a:args['content']
    call add(s:llm_agent_write_list, {'path': l:path, 'content': l:content})
    return {'content': 'Write queued for approval: ' . l:path . ' (' . len(l:content) . ' bytes)'}
endfunction

function! LLMAgent_ToolPatch(args)
    let l:path = simplify(a:args['path'])
    if l:path =~ '^\.\.'
        return {'error': 'Cannot patch outside the current directory'}
    endif

    let l:diff = a:args['diff']

    " Read original file content
    if !filereadable(l:path)
        return {'error': 'File not found: ' . l:path}
    endif
    let l:original = readfile(l:path)

    " Write diff and original to temp files, apply patch
    let l:diff_file = tempname()
    let l:orig_file = tempname()
    call writefile(split(l:diff, '\n'), l:diff_file)
    call writefile(l:original, l:orig_file)

    " Try to apply patch, capture result
    let l:patched_file = tempname()
    let l:cmd = 'patch -s -o ' . shellescape(l:patched_file) . ' ' . shellescape(l:orig_file) . ' ' . shellescape(l:diff_file) . ' 2>&1'
    let l:error = system(l:cmd)
    call delete(l:diff_file)
    call delete(l:orig_file)

    if v:shell_error != 0
        call delete(l:patched_file)
        return {'error': 'Patch failed: ' . l:error}
    endif

    let l:patched_content = readfile(l:patched_file)
    call delete(l:patched_file)

    let l:content = join(l:patched_content, "\n")
    call add(s:llm_agent_write_list, {'path': l:path, 'content': l:content})
    return {'content': 'Patch applied and queued for approval: ' . l:path . ' (' . len(l:content) . ' bytes)'}
endfunction

function! LLMAgent_ToolLs(args)
    let l:path = get(a:args, 'path', '.')
    let l:path = simplify(l:path)
    if l:path =~ '^\.\.'
        return {'error': 'Cannot access outside the current directory'}
    endif
    if !isdirectory(l:path)
        return {'error': 'Directory not found: ' . l:path}
    endif
    let l:entries = readdir(l:path)
    let l:result = ''
    for l:entry in l:entries
        let l:full = l:path . '/' . l:entry
        if isdirectory(l:full)
            let l:result .= l:entry . "/\n"
        else
            let l:result .= l:entry . "\n"
        endif
    endfor
    if empty(l:result)
        return {'content': '(empty directory)'}
    endif
    return {'content': l:result}
endfunction

function! LLMAgent_ToolFind(args)
    let l:pattern = a:args['pattern']
    let l:files = globpath('.', l:pattern, 0, 1)
    if empty(l:files)
        return {'content': 'No files found matching: ' . l:pattern}
    endif
    if len(l:files) > 200
        let l:files = l:files[:199]
        let l:result = join(l:files, "\n") . "\n... (truncated, showing first 200)"
    else
        let l:result = join(l:files, "\n")
    endif
    return {'content': l:result}
endfunction

function! LLMAgent_ToolGrep(args)
    let l:pattern = a:args['pattern']
    let l:path = get(a:args, 'path', '.')
    let l:glob_filter = get(a:args, 'glob', '*')
    let l:path = simplify(l:path)
    if l:path =~ '^\.\.'
        return {'error': 'Cannot search outside the current directory'}
    endif
    let l:files = globpath(l:path, '**/' . l:glob_filter, 0, 1)
    let l:results = []
    let l:match_count = 0
    for l:file in l:files
        if l:match_count >= 100
            call add(l:results, '... (truncated, max 100 matches)')
            break
        endif
        if !filereadable(l:file) || isdirectory(l:file)
            continue
        endif
        let l:lines = readfile(l:file)
        let l:line_num = 0
        for l:line in l:lines
            let l:line_num += 1
            try
                if l:line =~ l:pattern
                    call add(l:results, l:file . ':' . l:line_num . ': ' . l:line)
                    let l:match_count += 1
                    if l:match_count >= 100
                        break
                    endif
                endif
            catch
                " Invalid regex pattern, skip this file
                break
            endtry
        endfor
    endfor
    if empty(l:results)
        return {'content': 'No matches found for: ' . l:pattern}
    endif
    return {'content': join(l:results, "\n")}
endfunction

function! LLMAgent_ToolListBuffers()
    let l:bufs = []
    for l:i in range(1, bufnr('$'))
        if buflisted(l:i)
            let l:name = bufname(l:i)
            if empty(l:name)
                let l:name = '[No Name]'
            endif
            call add(l:bufs, l:i . ': ' . l:name)
        endif
    endfor
    return {'content': join(l:bufs, "\n")}
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
        return {'error': 'Unknown tool: ' . a:name}
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Private Functions - Sidebar
""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
        call append(1, '')
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
    call append(1, '')
    setlocal nomodifiable
    execute l:cur_win . 'wincmd w'
    let s:llm_agent_messages = []
    call LLMAgent_SidebarLog('Chat cleared', 'System')
endfunction

function! LLMAgent_ContinueChat(user_text)
    if empty(s:llm_agent_messages)
        " No prior conversation; start a new agent session
        let l:system_prompt = LLMAgent_GetSystemPrompt()
        let l:file_ctx = LLMAgent_GetFileContext()
        if !empty(l:file_ctx)
            let l:system_prompt .= "\n\n" . l:file_ctx
        endif
        let l:system_prompt .= "\n\nCRITICAL RULES:\n1. To modify files, you MUST use write_file or patch tools. NEVER output code in your text response.\n2. To see file content, use read_file. To search code, use grep or find. To list directories, use ls.\n3. After making changes, respond with a brief text summary. Do NOT include code blocks.\n4. Stop calling tools when the task is complete.\n5. Format your text responses with actual line breaks. Use short paragraphs separated by blank lines. Never output a single long line — break it up with newlines every 1-2 sentences. Use markdown formatting (## headers, - bullets, | tables) with proper line breaks between rows."
        let s:llm_agent_messages = [
            \ {'role': 'system', 'content': l:system_prompt},
            \ {'role': 'user', 'content': a:user_text}
            \ ]
    else
        call add(s:llm_agent_messages, {'role': 'user', 'content': a:user_text})
    endif
    call LLMAgent_RunWithTools('')
endfunction

function! LLMAgent_RunWithTools(prompt)
    " Dispatch to ACP backend for CLI mode
    if g:llm_agent_backend == 'cli'
        call LLMAgent_RunWithToolsACP(a:prompt)
        return
    endif

    let s:llm_agent_response_text = ''

    " Initialize messages if a prompt is given (new conversation)
    if !empty(a:prompt)
        let l:system_prompt = LLMAgent_GetSystemPrompt()
        let l:file_ctx = LLMAgent_GetFileContext()
        if !empty(l:file_ctx)
            let l:system_prompt .= "\n\n" . l:file_ctx
        endif
        let l:system_prompt .= "\n\nCRITICAL RULES:\n1. To modify files, you MUST use write_file or patch tools. NEVER output code in your text response.\n2. To see file content, use read_file. To search code, use grep or find. To list directories, use ls.\n3. After making changes, respond with a brief text summary. Do NOT include code blocks.\n4. Stop calling tools when the task is complete.\n5. Format your text responses with actual line breaks. Use short paragraphs separated by blank lines. Never output a single long line — break it up with newlines every 1-2 sentences. Use markdown formatting (## headers, - bullets, | tables) with proper line breaks between rows."
        let s:llm_agent_messages = [
            \ {'role': 'system', 'content': l:system_prompt},
            \ {'role': 'user', 'content': a:prompt}
            \ ]
    endif

    let s:llm_agent_write_list = []

    for l:turn in range(g:llm_agent_tool_max_rounds)
        call LLMAgent_SidebarLog('thinking... (' . (l:turn + 1) . '/' . g:llm_agent_tool_max_rounds . ')', 'Agent')

        let l:body = {
            \ 'model': g:llm_agent_model,
            \ 'messages': s:llm_agent_messages,
            \ 'tools': LLMAgent_GetToolDefinitions()
            \ }
        let l:tmpfile = tempname()
        call writefile([json_encode(l:body)], l:tmpfile)

        let l:curl_cmd = 'curl -s -m ' . g:llm_agent_timeout
        if !empty(g:llm_agent_api_key)
            let l:curl_cmd .= ' -H "Authorization: Bearer ' . g:llm_agent_api_key . '"'
        endif
        let l:curl_cmd .= ' -H "Content-Type: application/json"'
        let l:curl_cmd .= ' -d @' . shellescape(l:tmpfile)
        let l:curl_cmd .= ' ' . shellescape(g:llm_agent_api_url . '/chat/completions')

        let l:response = system(l:curl_cmd)
        call delete(l:tmpfile)

        if v:shell_error != 0
            call LLMAgent_SidebarLog('curl failed (exit ' . v:shell_error . ')', 'Error')
            return
        endif

        try
            let l:data = json_decode(l:response)
        catch
            call LLMAgent_SidebarLog('Failed to parse response', 'Error')
            return
        endtry

        if has_key(l:data, 'error')
            call LLMAgent_SidebarLog(l:data['error']['message'], 'Error')
            return
        endif

        let l:choice = l:data['choices'][0]
        let l:message = l:choice['message']

        " Check for tool calls
        if has_key(l:message, 'tool_calls') && !empty(l:message['tool_calls'])
            call add(s:llm_agent_messages, l:message)

            for l:tool_call in l:message['tool_calls']
                let l:tool_name = l:tool_call['function']['name']
                let l:tool_args = json_decode(l:tool_call['function']['arguments'])

                " Log the tool call
                let l:args_summary = ''
                if has_key(l:tool_args, 'path')
                    let l:args_summary = l:tool_args['path']
                elseif has_key(l:tool_args, 'pattern')
                    let l:args_summary = l:tool_args['pattern']
                endif
                call LLMAgent_SidebarLog(l:tool_name . '(' . l:args_summary . ')', 'Tool')

                let l:tool_result = LLMAgent_ExecuteTool(l:tool_name, l:tool_args)
                let l:result_text = has_key(l:tool_result, 'error') ? 'ERROR: ' . l:tool_result['error'] : l:tool_result['content']

                " Log truncated result
                let l:display = substitute(l:result_text, '\n', ' ', 'g')
                if len(l:display) > 80
                    let l:display = strpart(l:display, 0, 80) . '...'
                endif
                call LLMAgent_SidebarLog(l:display, 'Result')

                call add(s:llm_agent_messages, {
                    \ 'role': 'tool',
                    \ 'tool_call_id': l:tool_call['id'],
                    \ 'content': l:result_text
                    \ })
            endfor
        else
            " Final response - no more tool calls
            let l:content = l:message['content']
            let s:llm_agent_response_text = l:content
            call add(s:llm_agent_messages, l:message)

            if !empty(s:llm_agent_write_list) && g:llm_agent_tool_confirm
                call LLMAgent_SidebarLog(l:content, 'Agent')
                call LLMAgent_SidebarShowApproval(s:llm_agent_write_list)
            elseif !empty(s:llm_agent_write_list)
                call LLMAgent_SidebarLog('Applying ' . len(s:llm_agent_write_list) . ' write(s)...', 'System')
                call LLMAgent_ApplyWrites(s:llm_agent_write_list)
                call LLMAgent_SidebarLog(l:content, 'Agent')
            else
                call LLMAgent_SidebarLog(l:content, 'Agent')
            endif
            return
        endif
    endfor

    " Max rounds reached - force a final response without tools
    call LLMAgent_SidebarLog('max rounds reached, asking for summary...', 'System')
    call add(s:llm_agent_messages, {'role': 'user', 'content': 'You have reached the limit of tool calls. Summarize what you found and any changes you made. Do NOT call any more tools.'})

    let l:body = {'model': g:llm_agent_model, 'messages': s:llm_agent_messages}
    let l:tmpfile = tempname()
    call writefile([json_encode(l:body)], l:tmpfile)
    let l:curl_cmd = 'curl -s -m ' . g:llm_agent_timeout
    if !empty(g:llm_agent_api_key)
        let l:curl_cmd .= ' -H "Authorization: Bearer ' . g:llm_agent_api_key . '"'
    endif
    let l:curl_cmd .= ' -H "Content-Type: application/json"'
    let l:curl_cmd .= ' -d @' . shellescape(l:tmpfile)
    let l:curl_cmd .= ' ' . shellescape(g:llm_agent_api_url . '/chat/completions')
    let l:response = system(l:curl_cmd)
    call delete(l:tmpfile)

    if v:shell_error == 0
        try
            let l:data = json_decode(l:response)
            let l:content = l:data['choices'][0]['message']['content']
            let s:llm_agent_response_text = l:content
            call add(s:llm_agent_messages, l:data['choices'][0]['message'])
        catch
            let l:content = 'LLM stopped responding.'
        endtry
    else
        let l:content = 'LLM stopped responding (timeout).'
    endif

    if !empty(s:llm_agent_write_list) && g:llm_agent_tool_confirm
        call LLMAgent_SidebarLog(l:content, 'Agent')
        call LLMAgent_SidebarShowApproval(s:llm_agent_write_list)
    elseif !empty(s:llm_agent_write_list)
        call LLMAgent_ApplyWrites(s:llm_agent_write_list)
        call LLMAgent_SidebarLog(l:content, 'Agent')
    else
        call LLMAgent_SidebarLog(l:content, 'Agent')
    endif
endfunction

function! LLMAgent_ShowWriteDiff(write_list)
    let l:summary = ['LLM Agent wants to write ' . len(a:write_list) . ' file(s):']
    for l:entry in a:write_list
        call add(l:summary, '  ' . l:entry['path'] . ' (' . len(l:entry['content']) . ' bytes)')
    endfor
    call add(l:summary, '')
    call add(l:summary, 'Enter=apply  q=reject')
    if has('nvim')
        let l:buf = nvim_create_buf(v:false, v:true)
        call nvim_buf_set_lines(l:buf, 0, -1, v:true, l:summary)
        call nvim_buf_set_option(l:buf, 'modifiable', v:false)
        let l:w = min([80, &columns - 8])
        let l:h = len(l:summary)
        let s:llm_agent_confirm_win = nvim_open_win(l:buf, v:true, {
            \ 'relative': 'editor',
            \ 'width': l:w,
            \ 'height': l:h,
            \ 'row': (&lines - l:h) / 2,
            \ 'col': (&columns - l:w) / 2,
            \ 'style': 'minimal',
            \ 'border': 'single',
            \ })
        call nvim_buf_set_keymap(l:buf, 'n', '<CR>', ':call LLMAgent_ApplyWritesCallback()<CR>', {'silent': v:true, 'nowait': v:true})
        call nvim_buf_set_keymap(l:buf, 'n', 'q', ':call LLMAgent_RejectWritesCallback()<CR>', {'silent': v:true, 'nowait': v:true})
        call nvim_buf_set_keymap(l:buf, 'n', '<Esc>', ':call LLMAgent_RejectWritesCallback()<CR>', {'silent': v:true, 'nowait': v:true})
    elseif has('popupwin')
        let s:llm_agent_confirm_popup = popup_create(l:summary, {
            \ 'line': (&lines - len(l:summary)) / 2,
            \ 'col': (&columns - 80) / 2,
            \ 'minwidth': 60,
            \ 'padding': [1,1,1,1],
            \ 'border': [],
            \ 'title': ' LLM Write Confirmation ',
            \ 'close': 'button',
            \ 'mapping': 0,
            \ 'filter': function('LLMAgent_ConfirmFilter'),
            \ })
    else
        pedit LLMAgent-Confirm
        wincmd P
        setlocal modifiable
        %delete _
        call setline(1, l:summary)
        setlocal nomodifiable
        nnoremap <buffer> <silent> <CR> :call LLMAgent_ApplyWritesCallback()<CR>
        nnoremap <buffer> <silent> q :pclose<CR>
        nnoremap <buffer> <silent> <Esc> :pclose<CR>
        wincmd p
    endif
endfunction

function! LLMAgent_ConfirmFilter(id, key)
    if a:key == 'q' || a:key == "\<Esc>" || a:key == "\x1b"
        call popup_close(a:id)
        call LLMAgent_RejectWritesCallback()
        return 1
    elseif a:key == "\<CR>" || a:key == "\r"
        call popup_close(a:id)
        call LLMAgent_ApplyWritesCallback()
        return 1
    endif
    return 0
endfunction

function! LLMAgent_ApplyWritesCallback()
    if has('nvim') && exists('s:llm_agent_confirm_win')
        call nvim_win_close(s:llm_agent_confirm_win, v:true)
        unlet s:llm_agent_confirm_win
    endif
    if exists('s:llm_agent_write_list')
        call LLMAgent_ApplyWrites(s:llm_agent_write_list)
    endif
    if exists('s:llm_agent_response_text')
        let l:text = s:llm_agent_response_text
        let l:source_buf = bufnr('%')
        redraw
        call LLMAgent_DisplayOpen(l:text, l:source_buf, [line('.'), col('.')], 'view')
    endif
endfunction

function! LLMAgent_RejectWritesCallback()
    if has('nvim') && exists('s:llm_agent_confirm_win')
        call nvim_win_close(s:llm_agent_confirm_win, v:true)
        unlet s:llm_agent_confirm_win
    endif
    if exists('s:llm_agent_write_list')
        echo 'LLMAgent: writes rejected (' . len(s:llm_agent_write_list) . ' file(s))'
    endif
    if exists('s:llm_agent_response_text')
        let l:text = s:llm_agent_response_text
        let l:source_buf = bufnr('%')
        redraw
        call LLMAgent_DisplayOpen(l:text, l:source_buf, [line('.'), col('.')], 'view')
    endif
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

function! LLMAgent_Execute(action, context, user_input, mode)
    let l:system_prompt = LLMAgent_GetSystemPrompt()

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

    if g:llm_agent_streaming
        " TODO: implement streaming via job_start / jobstart
        echom 'LLMAgent: streaming not yet supported, using request mode'
    endif

    let l:result = LLMAgent_Call(l:system_prompt, l:prompt)

    if has_key(l:result, 'error')
        echo 'LLMAgent error: ' . l:result['error']
        return
    endif

    let l:content = l:result['content']

    " Build source info for accept
    let l:source_buf = bufnr('%')
    if a:mode == 'write'
        let l:source_range = [line('.'), col('.')]
    elseif a:mode == 'replace'
        " source_range will be overridden by the command functions
        let l:source_range = [line("'<"), line("'>")]
    else
        let l:source_range = [line('.'), col('.')]
    endif

    redraw
    call LLMAgent_DisplayOpen(l:content, l:source_buf, l:source_range, a:mode)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""    Public Commands
""""""""""""""""""""""""""""""""""""""""""""""""""""""

" LLMAgent - Tool-enabled AI agent (read_file, write_file, ls, find, grep, list_buffers)
command! -nargs=? -range LLMAgent call LLMAgent_CommandAgent(<q-args>)
function! LLMAgent_CommandAgent(args)
    let l:context = ''
    try
        let l:context = LLMAgent_GetVisualSelection()
    catch
    endtry
    let l:prompt = a:args

    " If no args, check for input prompt
    if empty(l:prompt)
        let l:prompt = input('LLM Agent: ')
    endif

    " Empty prompt with no context = open empty chat sidebar
    if empty(l:prompt) && empty(l:context)
        let s:llm_agent_working_buf = bufnr('%')
        let s:llm_agent_messages = []
        call LLMAgent_SidebarOpen()
        return
    endif

    if empty(l:prompt)
        return
    endif

    if !empty(l:context)
        let l:prompt = l:prompt . "\n\nUser selected code context:\n" . l:context
    endif
    let s:llm_agent_working_buf = bufnr('%')
    let s:llm_agent_messages = []
    call LLMAgent_SidebarOpen()
    call LLMAgent_SidebarLog(l:prompt, 'You')
    call LLMAgent_RunWithTools(l:prompt)
endfunction

" LLMAsk - Free-form question, optional visual selection as context
command! -nargs=? -range LLMAsk call LLMAgent_CommandAsk(<q-args>)
function! LLMAgent_CommandAsk(args)
    let l:context = ''
    try
        let l:context = LLMAgent_GetVisualSelection()
    catch
    endtry
    let l:prompt = a:args
    if empty(l:prompt)
        let l:prompt = input('LLM Ask: ')
    endif
    if empty(l:prompt)
        return
    endif
    call LLMAgent_Execute('ask', l:context, l:prompt, 'view')
endfunction

" LLMExplain - Explain selected code or word under cursor
command! -range LLMExplain call LLMAgent_CommandExplain()
function! LLMAgent_CommandExplain()
    let l:context = LLMAgent_GetContext(line("'<"), line("'>"))
    if empty(l:context)
        echo 'LLMAgent: nothing to explain'
        return
    endif
    call LLMAgent_Execute('explain', l:context, '', 'view')
endfunction

" LLMClear - Clear chat history
command! LLMClear call LLMAgent_ClearChat()

" LLMToggle - Toggle sidebar open/close
command! LLMToggle call LLMAgent_ToggleSidebar()
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
