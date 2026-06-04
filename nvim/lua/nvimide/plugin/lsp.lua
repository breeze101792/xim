---@class nvimide.core: nvimide.plugin
local LSPM= {}

---@class NvimideOptions
local defaults = {
    plugin_path = "~/.vim/plugins/",
}

---@type NvimideOptions
local options = defaults

----    Lsp configs
----------------------------------------------------------------

-- Save default handlers before any overrides (avoids deprecated vim.lsp.handlers.hover / .signature_help)
local _default_hover = vim.lsp.handlers["textDocument/hover"]
local _default_signature = vim.lsp.handlers["textDocument/signatureHelp"]

local lspui = function(opts)
    local _border = "single"

    vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
        config = vim.tbl_deep_extend("force", config or {}, { border = _border })
        return _default_hover(err, result, ctx, config)
    end

    vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
        config = vim.tbl_deep_extend("force", config or {}, { border = _border })
        return _default_signature(err, result, ctx, config)
    end

    -- config neovim diagnostic
    vim.diagnostic.config({
        float={border=_border},
        -- virtual_text = false, -- Turn off trailing text
        virtual_text = true, -- Turn off trailing text
        signs = true,        -- Keep left red/yellow dots
        underline = true,    -- Keep error underlines
        update_in_insert = false, -- Do not update while typing to avoid interference
    })
end

----------------------------------------------------------------
----    Lsp server configs (vim.lsp.config / vim.lsp.enable)
----------------------------------------------------------------
-- Configure LSP servers using the Neovim 0.11+ built-in API.
-- See :help lspconfig-nvim-0.11 for migration details.

local lsp_clangd = function()
    if vim.fn.executable('clangd') ~= 1 then
        return
    end

    vim.lsp.config('clangd', {
        cmd = { "clangd", "--background-index" },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        root_markers = { "compile_commands.json", "compile_flags.txt" },
    })
    vim.lsp.enable('clangd')
end

local lsp_ccls = function()
    if vim.fn.executable('ccls') ~= 1 then
        return
    end

    vim.lsp.config('ccls', {
        cmd = { "ccls" },
        filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
        init_options = {
            compilationDatabaseDirectory = "build",
            index = {
                threads = 0,
            },
            clang = {
                excludeArgs = { "-frounding-math" },
            },
        },
        root_markers = { "compile_commands.json", ".ccls" },
    })
    vim.lsp.enable('ccls')
end

local lsp_pyright = function()
    if vim.fn.executable('basedpyright') ~= 1 then
        return
    end

    vim.lsp.config('basedpyright', {
        cmd = { "basedpyright-langserver", "--stdio" },
        filetypes = { 'python' },
        settings = {
            basedpyright = {
                analysis = {
                    autoSearchPaths = true,
                    diagnosticMode = "openFilesOnly",
                    useLibraryCodeForTypes = true,
                    typeCheckingMode = "basic", -- If it's too heavy, set to "off"
                },
            },
        },
        root_markers = { ".venv", ".git" },
    })
    vim.lsp.enable('basedpyright')
end

local lsp_lua = function()
    if vim.fn.executable('lua-language-server') ~= 1 then
        return
    end

    vim.lsp.config('lua_ls', {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        settings = {
            Lua = {
                runtime = {
                    -- tell LSP that you use LuaJIT (Neovim build-in)
                    version = 'LuaJIT',
                },
                diagnostics = {
                    -- Core: Let LSP recognize "vim" global variable to avoid errors
                    globals = { 'vim' },
                },
                workspace = {
                    -- Allow LSP to read Neovim's runtime files for API completion
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false, -- Disable annoying third-party checks
                },
                telemetry = {
                    enable = false, -- Disable telemetry for privacy reasons
                },
            },
        },
        root_markers = { ".luarc.json", ".git" },
    })
    vim.lsp.enable('lua_ls')
end

local lsp_bashls = function()
    if vim.fn.executable('bash-language-server') ~= 1 then
        return
    end

    vim.lsp.config('bashls', {
        cmd = { "bash-language-server", "start" },
        filetypes = { "sh", "bash" },
        --[[
        settings = {
            bashIde = {
                shellcheckArguments = table.concat({
                    "-e", "SC2154", -- Variable not declared (e.g., from external source)
                    "-e", "SC2034", -- Variable defined but not used
                    "-e", "SC2086", -- Double quote to prevent globbing and word splitting
                    "-e", "SC1091", -- Can't follow non-constant source
                    "-e", "SC2181", -- Check exit code directly (common but discouraged)
                    "-e", "SC2046", -- Quote to prevent word splitting
                }, " ")
            },
        },
        --]]
        root_markers = { ".git" },
    })
    vim.lsp.enable('bashls')
end

local lsp_rust = function()
    if vim.fn.executable('rust_analyzer') ~= 1 then
        return
    end

    vim.lsp.config('rust_analyzer', {
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
        settings = {
            ["rust-analyzer"] = {
                checkOnSave = true,
                check = {
                    -- change default cargo check to clippy
                    command = "clippy",
                },
                imports = {
                    granularity = {
                        group = "module",
                    },
                    prefix = "self",
                },
                cargo = {
                    buildScripts = {
                        enable = true, -- Handle code completion generated by build.rs
                    },
                },
                procMacro = {
                    enable = true, -- Handle macro expansions like #[derive(Serialize)]
                },
                -- Enhance Inlay Hints
                inlayHints = {
                    bindingModeHints = { enable = true },
                    chainingHints = { enable = true },
                    closingBraceHints = { enable = true },
                    parameterHints = { enable = true },
                    typeHints = { enable = true },
                },
            },
        },
        root_markers = { "Cargo.toml", ".git" },
    })
    vim.lsp.enable('rust_analyzer')
end

----------------------------------------------------------------
----    Plugin
----------------------------------------------------------------
-- List of all LSP server executables referenced in this file
local lsp_tools = {
    { name = "clangd",                ft = { "c", "cpp", "objc", "objcpp", "cuda", "proto" } },
    { name = "ccls",                  ft = { "c", "cpp", "objc", "objcpp", "cuda" } },
    { name = "basedpyright",          ft = { "python" } },
    { name = "lua-language-server",   ft = { "lua" } },
    { name = "bash-language-server",  ft = { "sh", "bash" } },
    { name = "rust_analyzer",         ft = { "rust" } },
}

-- Look up the filetypes served by a named lsp_tools entry.
local function fts_for(tool_name)
    for _, tool in ipairs(lsp_tools) do
        if tool.name == tool_name then
            return tool.ft
        end
    end
    return {}
end

-- Match the existing call shape: has_value(haystack, needle)
local has_value = function(list, value)
    for _, v in ipairs(list) do
        if v == value then return true end
    end
    return false
end

---Check which LSP tools are available in PATH
---@return table[] results  list of {name, found, path, filetypes}
local lsp_toolcheck = function()
    local results = {}
    local missing = 0

    -- Header
    vim.notify("LSP Tool Check:", vim.log.levels.INFO)

    for _, tool in ipairs(lsp_tools) do
        local found = vim.fn.executable(tool.name) == 1
        local path = found and vim.fn.exepath(tool.name) or nil
        local fts = table.concat(tool.ft, ", ")

        if found then
            vim.notify(("  [✓] %-22s %s  (filetypes: %s)")
                :format(tool.name, path, fts), vim.log.levels.INFO)
        else
            missing = missing + 1
            vim.notify(("  [✗] %-22s NOT FOUND          (filetypes: %s)")
                :format(tool.name, fts), vim.log.levels.WARN)
        end

        table.insert(results, {
            name      = tool.name,
            found     = found,
            path      = path,
            filetypes = tool.ft,
        })
    end

    if missing == 0 then
        vim.notify("All LSP tools are installed.", vim.log.levels.INFO)
    else
        vim.notify(("%d LSP tool(s) missing. See :checkhealth lsp for details."):format(missing),
            vim.log.levels.WARN)
    end

    return results
end
_G.lsp_toolcheck = lsp_toolcheck

local lspconfig = function()
    -- Set up LSP UI (borders, diagnostics)
    lspui()

    -- Set up lsp_signature via LspAttach autocmd (replaces on_attach)
    vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
            local bufnr = args.buf
            require("lsp_signature").on_attach({
                bind = true,
                handler_opts = { border = "rounded" },
            }, bufnr)
        end,
    })

    -- Only start servers when a matching filetype buffer is opened,
    -- so missing-server warnings only appear for the filetype you actually use.
    local lspgroup = vim.api.nvim_create_augroup('lspconfig', { clear = false })
    vim.api.nvim_create_autocmd('FileType', {
        group = lspgroup,
        callback = function(args)
            local file_type=vim.fn.expand("%")
            local ft = vim.bo.filetype
            if has_value(fts_for("clangd"), ft) or has_value(fts_for("ccls"), ft) then
                lspui()
                -- Default use ccls
                local flag_clangd = true
                if flag_clangd then
                    lsp_clangd()
                else
                    -- FIXME, it's still not working
                    lsp_ccls()
                end
            elseif has_value(fts_for("basedpyright"), ft) then
                -- Install basedpyright, ruff
                lsp_pyright()
            elseif has_value(fts_for("lua-language-server"), ft) then
                -- Install lua-language-server
                lsp_lua()
            elseif has_value(fts_for("bash-language-server"), ft) then
                -- Install bash-language-server(npm)
                lsp_bashls()
            elseif has_value(fts_for("rust_analyzer"), ft) then
                -- TODO, need more test.
                -- Install rust-analyzer
                lsp_rust()
            end
        end,
    })
end
local reg_commands = function()
    -- exporse tools check
    vim.api.nvim_create_user_command("LspToolCheck", function(opts)
        local results = lsp_toolcheck()
        if opts.bang then
            local missing = vim.tbl_filter(function(r) return not r.found end, results)
            if #missing == 0 then
                vim.notify("LspToolCheck: all installed", vim.log.levels.INFO)
            else
                for _, r in ipairs(missing) do
                    vim.notify("missing: " .. r.name, vim.log.levels.WARN)
                end
            end
        end
    end, {
        bang = true,
        desc = "Check which LSP server executables are available in PATH",
    })
end

function LSPM.get_impl(impl)
    local vim_plugin_path = options.plugin_path
    return {
        {
            "nvim-lspconfig" ,
            event = "VeryLazy", -- Lazy load to optimize startup speed
            dir = vim_plugin_path .. "nvim-lspconfig" ,
            ft = {"sh" ,"bash" , "cpp" , "c", "python", "lua", "rust"},
            config = lspconfig,
            dependencies = {
                "QFEnter",
                "ray-x/lsp_signature.nvim",
            },
        },
        -- 1. Automatically display function signature help
        {
            "ray-x/lsp_signature.nvim",
            event = "VeryLazy", -- Lazy load to optimize startup speed
            opts = {
                -- Your custom configuration goes here
                bind = true, -- Required, bind the plugin to the current Buffer
                handler_opts = {
                    border = "rounded" -- Make floating window borders rounded, visually closer to modern IDEs
                },
                floating_window = true, -- Automatically pop up window when typing
                hint_enable = true,     -- Whether to display virtual text hints at the end of the line
                hint_prefix = "💡 ",   -- Prefix for virtual hints
                padding = '',           -- Window padding
                transparency = nil,     -- Window transparency
                shadow_blend = 36,      -- Shadow blend level
                always_trigger = false, -- Whether to trigger in all cases
            },
            config = function(_, opts)
                require("lsp_signature").setup(opts)
            end,
        }
    }
end

---@param opts? NvimideOptions
function LSPM.setup(opts)
    options = vim.tbl_deep_extend("force", defaults, opts or {})
    reg_commands()
    return LSPM
end

return LSPM
