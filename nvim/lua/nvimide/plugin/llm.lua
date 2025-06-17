---@class nvimide.core: nvimide.plugin
local LLM = {}

----------------------------------------------------------------
----    Plugin
----------------------------------------------------------------
function get_avante_v0024()
    token_reserve = 10000
    -- FIXME, <leader> just don't work on vim.keymap.set, so i workaround it.
    leader_key='\\'

    return {
        "yetone/avante.nvim",
        event = "VeryLazy",
        -- lazy = false,
        -- version = false, -- Never set this value to "*"! Never!
        -- version = "*",
        tag = "v0.0.25",
        opts = {
            behaviour = {
                auto_apply_diff_after_generation = true,
                auto_focus_on_diff_view = true,
                -- use_cwd_as_project_root = true,
                -- enable_token_counting = false,
                --[[
                auto_focus_sidebar = true,
                auto_suggestions = false, -- Experimental stage
                auto_suggestions_respect_ignore = false,
                auto_set_highlight_group = true,
                auto_set_keymaps = true,
                auto_apply_diff_after_generation = false,
                jump_result_buffer_on_finish = false,
                support_paste_from_clipboard = false,
                minimize_diff = true,
                enable_token_counting = true,
                use_cwd_as_project_root = false,
                auto_focus_on_diff_view = false,
                --]]
            },
            ---@alias avante.Mode "agentic" | "legacy"
            -- mode = "agentic",
            mode = "legacy",
            -- add any opts here
            mappings = {
                -- NOTE: The following will be safely set by avante.nvim
                --[[
                -- NOTE: other keybinding could be found on scripts/framework/KeyMapFunction.vim
                    nmap <silent> <Leader>aC :AvanteClear<CR>
                    nmap <silent> <Leader>ab :AvanteBuild<CR>
                    nmap <silent> <Leader>am :AvanteModels<CR>
                    nmap <silent> <Leader>an :AvanteNewChat<CR>
                --]]
                ask = leader_key .. "aa",
                edit = leader_key .. "ae",
                refresh = leader_key .. "ar",
                focus = leader_key .. "af",
                stop = leader_key .. "aS",
                toggle = {
                    default = leader_key .. "at",
                    debug = leader_key .. "ad",
                    hint = leader_key .. "aH",
                    suggestion = leader_key .. "as",
                    repomap = leader_key .. "aR",
                },
                files = {
                    add_current = leader_key .. "ac", -- Add current buffer to selected files
                    add_all_buffers = leader_key .. "aB", -- Add all buffer files to selected files
                },
                select_model = leader_key .. "a?", -- Select model command
                select_history = leader_key .. "ah", -- Select history command
                sidebar = {
                    close = {"q" },
                },
            },
            windows = {
                ---@alias AvantePosition "right" | "left" | "top" | "bottom" | "smart"
                position = "smart",
                sidebar_header = {
                    enabled = true, -- true, false to enable/disable the header
                    align = "center", -- left, center, right for title
                    rounded = false,
                },
                edit = {
                    start_insert = false, -- Start insert mode when opening the edit window
                },
                ask = {
                    start_insert = false, -- Start insert mode when opening the ask window
                },
            },
            -- for example
            provider = vim.g.IDE_CFG_LLM_PROVIDER,
            providers = {
                gemini = {
                    __inherited_from = 'gemini',

                    model = vim.g.IDE_CFG_LLM_GEMINI_MODEL,
                    extra_request_body = {
                        generationConfig = {
                            temperature = 0,
                        },
                        temperature = 0,
                        max_tokens = 1000000 - token_reserve,
                    },
                },
                google_gemini = {
                    __inherited_from = 'gemini',
                    api_key_name = 'GEMINI_API_KEY_2',

                    model = vim.g.IDE_CFG_LLM_GEMINI_MODEL,
                    extra_request_body = {
                        generationConfig = {
                            temperature = 0,
                        },
                        max_tokens = 1000000 - token_reserve,
                    }
                },
                -- for second google account
                google_gemini_2 = {
                    __inherited_from = 'gemini',
                    api_key_name = 'GEMINI_API_KEY_2',

                    model = vim.g.IDE_CFG_LLM_GEMINI_MODEL,
                    extra_request_body = {
                        generationConfig = {
                            temperature = 0,
                        },
                        max_tokens = 1000000 - token_reserve,
                    }
                },
                LLMLocal = {
                    __inherited_from = 'openai',

                    endpoint = vim.g.IDE_CFG_LLM_OPENAPI_URL,
                    api_key_name = '',

                    model = vim.g.IDE_CFG_LLM_OPENAPI_MODEL,

                    extra_request_body = {
                        temperature = 0,
                    },
                    max_tokens = 1000000 - token_reserve,
                },
                -- OpenWRT --
                openwrt = {
                    __inherited_from = 'openai',
                    endpoint = vim.g.IDE_CFG_LLM_OPENWRT_URL,
                    api_key_name = 'OPENROUTER_API_KEY',

                    -- for compatiable, disable tool
                    disable_tools = true,
                    -- enable_cursor_planning_mode = true,

                    model = vim.g.IDE_CFG_LLM_OPENWRT_MODEL,
                    -- max_tokens = 1000000 - token_reserve,
                },
                -- NOTE. If use openwrt, please export this on shell, export OPENROUTER_API_KEY=""
                -- max_completion_tokens => set to max_tokens - 10,000
                paid_ort_google_gemini_25_flash_preview = {
                    __inherited_from = 'openai',
                    endpoint = vim.g.IDE_CFG_LLM_OPENWRT_URL,
                    api_key_name = 'OPENROUTER_API_KEY',

                    disable_tools = true,
                    -- enable_cursor_planning_mode = true,

                    model = 'google/gemini-2.5-flash-preview',
                    max_tokens = 1048576 - token_reserve,
                },
                ort_google_gemini_20_flash = {
                    __inherited_from = 'openai',
                    endpoint = vim.g.IDE_CFG_LLM_OPENWRT_URL,
                    api_key_name = 'OPENROUTER_API_KEY',

                    disable_tools = true,
                    -- enable_cursor_planning_mode = true,

                    model = 'google/gemini-2.0-flash-exp:free',
                    max_tokens = 1048576 - token_reserve,
                    -- max_completion_tokens = 120000,
                },
                ort_deepseek_v3 = {
                    __inherited_from = 'openai',
                    endpoint = vim.g.IDE_CFG_LLM_OPENWRT_URL,
                    api_key_name = 'OPENROUTER_API_KEY',

                    disable_tools = true,
                    -- enable_cursor_planning_mode = true,

                    model = 'deepseek/deepseek-chat-v3-0324:free',
                    extra_request_body = {
                        max_completion_tokens = 131072 - token_reserve,
                    },
                    -- max_completion_tokens = 120000,
                },
                ort_deepseek_r1 = {
                    __inherited_from = 'openai',
                    endpoint = vim.g.IDE_CFG_LLM_OPENWRT_URL,
                    api_key_name = 'OPENROUTER_API_KEY',

                    disable_tools = true,
                    -- enable_cursor_planning_mode = true,

                    -- model = 'deepseek/deepseek-r1:free',
                    model = 'deepseek/deepseek-r1-0528:free',
                    extra_request_body = {
                        max_completion_tokens = 163840 - token_reserve,
                    },
                    -- max_completion_tokens = 150000,
                },
                -- Ollama --
                ollama_qwen25_coder_14b_q6 = {
                    __inherited_from = 'ollama',

                    -- disable_tools = true,
                    enable_cursor_planning_mode = true,
                    model = "qwen2.5-coder:14b-instruct-q6_K",
                },

            },
        },
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = "make",
        -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            --- The below dependencies are optional,
            "echasnovski/mini.pick", -- for file_selector provider mini.pick
            "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
            "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
            "ibhagwan/fzf-lua", -- for file_selector provider fzf
            "stevearc/dressing.nvim", -- for input provider dressing
            "folke/snacks.nvim", -- for input provider snacks
            "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
            "zbirenbaum/copilot.lua", -- for providers='copilot'
            {
                -- support for image pasting
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    -- recommended settings
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        -- required for Windows users
                        use_absolute_path = true,
                    },
                },
            },
            {
                -- Make sure to set this up properly if you have lazy=true
                'MeanderingProgrammer/render-markdown.nvim',
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
    }
end
function get_avante_v0023()
    token_reserve = 10000
    -- FIXME, <leader> just don't work on vim.keymap.set, so i workaround it.
    leader_key='\\'

    return {
        "yetone/avante.nvim",
        -- event = "VeryLazy",
        lazy = false,
        -- cmd = {"AvanteAsk", "AvanteToggle", "AvanteEdit"},
        -- version = "*", -- Never set this value to "*"! Never!
        version = false, -- Never set this value to "*"! Never!
        -- use the settings above to autotag, don't know why that didn't recomment it.
        -- tag = "v0.0.23",
        -- NOTE. test after fill it.
        commit = "f9025ff", -- support ollama
        -- commit = "adae032f5fbc611d59545792d3c5bb1c9ddc3fdb", -- test for newer version on 0511
        opts = {
            behaviour = {
                auto_apply_diff_after_generation = true,
                --[[
                auto_focus_sidebar = true,
                auto_suggestions = false, -- Experimental stage
                auto_suggestions_respect_ignore = false,
                auto_set_highlight_group = true,
                auto_set_keymaps = true,
                jump_result_buffer_on_finish = false,
                support_paste_from_clipboard = false,
                minimize_diff = true,
                enable_token_counting = true,
                use_cwd_as_project_root = false,
                auto_focus_on_diff_view = false,
                --]]
            },
            windows = {
                ---@alias AvantePosition "right" | "left" | "top" | "bottom" | "smart"
                position = "right",
                wrap = true, -- similar to vim.o.wrap
                width = 30, -- default % based on available width in vertical layout
                height = 30, -- default % based on available height in horizontal layout
                sidebar_header = {
                    enabled = true, -- true, false to enable/disable the header
                    align = "center", -- left, center, right for title
                    rounded = false,
                },
                edit = {
                    start_insert = false, -- Start insert mode when opening the edit window
                },
                ask = {
                    floating = false, -- Open the 'AvanteAsk' prompt in a floating window
                    start_insert = false, -- Start insert mode when opening the ask window
                },
            },
            hints = {
                enabled = true,  -- Enable/Disable visual selection tips
            },
            mappings = {
                ---@class AvanteConflictMappings
                diff = {
                    ours = "co",
                    theirs = "ct",
                    all_theirs = "ca",
                    both = "cb",
                    cursor = "cc",
                    next = "]x",
                    prev = "[x",
                },
                suggestion = {
                    accept = "<M-l>",
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-]>",
                },
                jump = {
                    next = "]]",
                    prev = "[[",
                },
                submit = {
                    normal = "<CR>",
                    insert = "<C-s>",
                },
                cancel = {
                    normal = { "<C-c>", "<Esc>", "q" },
                    insert = { "<C-c>" },
                },
                -- NOTE: The following will be safely set by avante.nvim
                ask = leader_key .. "aa",
                edit = leader_key .. "ae",
                refresh = leader_key .. "ar",
                focus = leader_key .. "af",
                stop = leader_key .. "aS",
                toggle = {
                    default = leader_key .. "at",
                    debug = leader_key .. "ad",
                    hint = leader_key .. "aH",
                    suggestion = leader_key .. "as",
                    repomap = leader_key .. "aR",
                },
                sidebar = {
                    apply_all = "A",
                    apply_cursor = "a",
                    retry_user_request = "r",
                    edit_user_request = "e",
                    switch_windows = "<Tab>",
                    reverse_switch_windows = "<S-Tab>",
                    remove_file = "d",
                    add_file = "@",
                    -- close = { "<Esc>", "q" },
                    close = {"q" },
                    ---@alias AvanteCloseFromInput { normal: string | nil, insert: string | nil }
                    ---@type AvanteCloseFromInput | nil
                    close_from_input = nil, -- e.g., { normal = "<Esc>", insert = "<C-d>" }
                },
                files = {
                    add_current = leader_key .. "ac", -- Add current buffer to selected files
                    add_all_buffers = leader_key .. "aB", -- Add all buffer files to selected files
                },
                select_model = leader_key .. "a?", -- Select model command
                select_history = leader_key .. "ah", -- Select history command
            },
            -- add any opts here
            -- for example
            ollama = {
                endpoint = vim.g.IDE_CFG_LLM_OLLAMA_URL,
                enable_cursor_planning_mode = true,
                model = vim.g.IDE_CFG_LLM_OLLAMA_MODEL,
            },
            --[[
            provider = "openai",
            openai = {
                endpoint = "https://api.openai.com/v1",
                model = "gpt-4o", -- your desired model (or use gpt-4o, etc.)
                timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
                temperature = 0,
                max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
                --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
            },
            --]]
            --[[
            gemini = {
                -- @see https://ai.google.dev/gemini-api/docs/models/gemini
                model = "gemini-2.5-pro-exp-03-25",
                temperature = 0,
                max_tokens = 1000000 - token_reserve,
                -- max_completion_tokens = 1000000 - token_reserve,
            },
            --]]
            provider = vim.g.IDE_CFG_LLM_PROVIDER,

            vendors = {
                LLMLocal = {
                    __inherited_from = 'openai',

                    endpoint = vim.g.IDE_CFG_LLM_OPENAPI_URL,
                    api_key_name = '',

                    model = vim.g.IDE_CFG_LLM_OPENAPI_MODEL,
                    temperature = 0,
                    max_tokens = 1000000 - token_reserve,
                },
                google_gemini = {
                    __inherited_from = 'gemini',

                    model = vim.g.IDE_CFG_LLM_GEMINI_MODEL,
                    disable_tools = true,

                    temperature = 0,
                    max_tokens = 1000000 - token_reserve,
                },
                -- for second google account
                google_gemini_2 = {
                    __inherited_from = 'gemini',
                    api_key_name = 'GEMINI_API_KEY_2',

                    model = vim.g.IDE_CFG_LLM_GEMINI_MODEL,
                    disable_tools = true,

                    temperature = 0,
                    max_tokens = 1000000 - token_reserve,
                },
                -- OpenWRT --
                openwrt = {
                    __inherited_from = 'openai',
                    endpoint = vim.g.IDE_CFG_LLM_OPENWRT_URL,
                    api_key_name = 'OPENROUTER_API_KEY',

                    -- for compatiable, disable tool
                    disable_tools = true,
                    -- enable_cursor_planning_mode = true,

                    model = vim.g.IDE_CFG_LLM_OPENWRT_MODEL,
                    -- max_tokens = 1000000 - token_reserve,
                },
                -- NOTE. If use openwrt, please export this on shell, export OPENROUTER_API_KEY=""
                -- max_completion_tokens => set to max_tokens - 10,000
                paid_ort_google_gemini_25_flash_preview = {
                    __inherited_from = 'openai',
                    endpoint = vim.g.IDE_CFG_LLM_OPENWRT_URL,
                    api_key_name = 'OPENROUTER_API_KEY',

                    disable_tools = true,
                    -- enable_cursor_planning_mode = true,

                    model = 'google/gemini-2.5-flash-preview',
                    max_tokens = 1048576 - token_reserve,
                },
                ort_google_gemini_20_flash = {
                    __inherited_from = 'openai',
                    endpoint = vim.g.IDE_CFG_LLM_OPENWRT_URL,
                    api_key_name = 'OPENROUTER_API_KEY',

                    disable_tools = true,
                    -- enable_cursor_planning_mode = true,

                    model = 'google/gemini-2.0-flash-exp:free',
                    max_tokens = 1048576 - token_reserve,
                    -- max_completion_tokens = 120000,
                },
                ort_deepseek_v3 = {
                    __inherited_from = 'openai',
                    endpoint = vim.g.IDE_CFG_LLM_OPENWRT_URL,
                    api_key_name = 'OPENROUTER_API_KEY',

                    disable_tools = true,
                    -- enable_cursor_planning_mode = true,

                    model = 'deepseek/deepseek-chat-v3-0324:free',
                    max_completion_tokens = 131072 - token_reserve,
                    -- max_completion_tokens = 120000,
                },
                ort_deepseek_r1 = {
                    __inherited_from = 'openai',
                    endpoint = vim.g.IDE_CFG_LLM_OPENWRT_URL,
                    api_key_name = 'OPENROUTER_API_KEY',

                    disable_tools = true,
                    -- enable_cursor_planning_mode = true,

                    -- model = 'deepseek/deepseek-r1:free',
                    model = 'deepseek/deepseek-r1-0528:free',
                    max_completion_tokens = 163840 - token_reserve,
                    -- max_completion_tokens = 150000,
                },
                -- use-less
                ort_qwen3_235b_a22b = {
                    __inherited_from = 'openai',
                    endpoint = 'https://openrouter.ai/api/v1',
                    api_key_name = 'OPENROUTER_API_KEY',

                    disable_tools = true,
                    -- enable_cursor_planning_mode = true,

                    model = 'qwen/qwen3-235b-a22b:free',
                    max_completion_tokens = 40960 - token_reserve,
                },
                -- Ollama --
                ollama_qwen25_coder_14b_q6 = {
                    __inherited_from = 'ollama',

                    -- disable_tools = true,
                    enable_cursor_planning_mode = true,
                    model = "qwen2.5-coder:14b-instruct-q6_K",
                },
            },
        },
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = "make",
        -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            --- The below dependencies are optional,
            "echasnovski/mini.pick", -- for file_selector provider mini.pick
            "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
            "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
            "ibhagwan/fzf-lua", -- for file_selector provider fzf
            "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
            "zbirenbaum/copilot.lua", -- for providers='copilot'
            {
                -- support for image pasting
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    -- recommended settings
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        -- required for Windows users
                        use_absolute_path = true,
                    },
                },
            },
            {
                -- Make sure to set this up properly if you have lazy=true
                'MeanderingProgrammer/render-markdown.nvim',
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
    }
end
function get_gen()
    -- LLM config
    local vim_plugin_path='~/.vim/plugins/'
    return {
        "gen.nvim", dir = vim_plugin_path .. "gen.nvim", lazy = true, cmd = "Gen",
        opts = {
            model = vim.g.IDE_CFG_LLM_MODEL, -- The default model to use.
            quit_map = "q", -- set keymap for close the response window
            retry_map = "<c-r>", -- set keymap to re-send the current prompt
            accept_map = "<c-cr>", -- set keymap to replace the previous selection with the last result
            host = vim.g.IDE_CFG_LLM_SERVER, -- The host running the Ollama service.
            port = vim.g.IDE_CFG_LLM_SERVER_PORT, -- The port on which the Ollama service is listening.
            display_mode = "horizontal-split", -- The display mode. Can be "float" or "split" or "horizontal-split".
            show_prompt = true, -- Shows the prompt submitted to Ollama.
            show_model = true, -- Displays which model you are using at the beginning of your chat session.
            no_auto_close = false, -- Never closes the window automatically.
            hidden = false, -- Hide the generation window (if true, will implicitly set `prompt.replace = true`), requires Neovim >= 0.10
            init = function(options) pcall(io.popen, "ollama serve > /dev/null 2>&1 &") end,
            -- Function to initialize Ollama
            command = function(options)
                local body = {model = options.model, stream = true}
                return "curl --silent --no-buffer -X POST http://" .. options.host .. ":" .. options.port .. "/api/chat -d $body"
            end,
            -- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
            -- This can also be a command string.
            -- The executed command must return a JSON object with { response, context }
            -- (context property is optional).
            -- list_models = '<omitted lua function>', -- Retrieves a list of model names
            debug = false -- Prints errors and the command which is run.
        }
    }
end

function LLM.get_impl(impl)
    if impl == "avante" then
        -- Old, but stable
        -- return get_avante_v0023()
        -- New, but buggy
        return get_avante_v0024()
    else
        return get_gen()
    end
end

return LLM
