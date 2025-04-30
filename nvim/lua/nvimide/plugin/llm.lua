---@class nvimide.core: nvimide.plugin
local LLM = {}

----------------------------------------------------------------
----    Plugin
----------------------------------------------------------------
function get_avante()
    token_reserve = 10000
    -- FIXME, <leader> just don't work on vim.keymap.set, so i workaround it.
    leader_key='\\'

    return {
        "yetone/avante.nvim",
        -- event = "VeryLazy",
        lazy = false,
        -- cmd = {"AvanteAsk", "AvanteToggle", "AvanteEdit"},
        version = false, -- Never set this value to "*"! Never!
        opts = {
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
                    close = { "<Esc>", "q" },
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
                endpoint = "http://" .. vim.g.IDE_CFG_LLM_SERVER .. ":" .. vim.g.IDE_CFG_LLM_SERVER_PORT .. "/",
                enable_cursor_planning_mode = true,
                model = vim.g.IDE_CFG_LLM_MODEL,
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
            provider = "google_gemini_25_pro",
            vendors = {
                ollama_qwen3_14b_q8 = {
                    __inherited_from = 'ollama',

                    model = "qwen3:14b-q8_0",
                },
                ollama_qwen3_14b = {
                    __inherited_from = 'ollama',

                    model = "qwen3:14b",
                },
                ollama_qwen3_7b_q8 = {
                    __inherited_from = 'ollama',

                    model = "qwen3:7b-q8_0",
                },
                google_gemini_25_pro = {
                    __inherited_from = 'gemini',

                    model = "gemini-2.5-pro-exp-03-25",
                    temperature = 0,
                    max_tokens = 1000000 - token_reserve,
                },
                -- for second google account
                google_gemini_25_pro_2 = {
                    __inherited_from = 'gemini',
                    api_key_name = 'GEMINI_API_KEY_2',

                    model = "gemini-2.5-pro-exp-03-25",
                    temperature = 0,
                    max_tokens = 1000000 - token_reserve,
                },
                -- NOTE. If use openwrt, please export this on shell, export OPENROUTER_API_KEY=""
                -- max_completion_tokens => set to max_tokens - 10,000
                ort_qwen3_235b_a22b = {
                    __inherited_from = 'openai',
                    endpoint = 'https://openrouter.ai/api/v1',
                    api_key_name = 'OPENROUTER_API_KEY',

                    disable_tools = true,
                    enable_cursor_planning_mode = true,

                    model = 'qwen/qwen3-235b-a22b:free',
                    max_completion_tokens = 40960 - token_reserve,
                },
                ort_deepseek_v3 = {
                    __inherited_from = 'openai',
                    endpoint = 'https://openrouter.ai/api/v1',
                    api_key_name = 'OPENROUTER_API_KEY',

                    disable_tools = true,
                    enable_cursor_planning_mode = true,

                    model = 'deepseek/deepseek-chat-v3-0324:free',
                    max_completion_tokens = 131072 - token_reserve,
                    -- max_completion_tokens = 120000,
                },
                ort_deepseek_r1 = {
                    __inherited_from = 'openai',
                    endpoint = 'https://openrouter.ai/api/v1',
                    api_key_name = 'OPENROUTER_API_KEY',

                    disable_tools = true,
                    enable_cursor_planning_mode = true,

                    model = 'deepseek/deepseek-r1:free',
                    max_completion_tokens = 163840 - token_reserve,
                    -- max_completion_tokens = 150000,
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
        return get_avante()
    else
        return get_gen()
    end
end

return LLM
