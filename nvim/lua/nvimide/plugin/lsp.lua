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
local lsp_notify = function(executable)
    vim.notify("LSP Warning: " .. executable .. " not found in PATH", vim.log.levels.WARN)
end

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
        lsp_notify("clangd")
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
        lsp_notify("ccls")
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
        lsp_notify("basedpyright")
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
        lsp_notify("lua-language-server")
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
        lsp_notify("bash-language-server")
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
        lsp_notify("rust_analyzer")
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
            local ft = vim.bo[args.buf].filetype
            if has_value({ "c", "cpp", "objc", "objcpp", "cuda", "proto" }, ft) then
                -- Default use clangd
                local flag_clangd = true
                if flag_clangd then
                    lsp_clangd()
                else
                    -- FIXME, it's still not working
                    lsp_ccls()
                end
            elseif has_value({ "py", "python" }, ft) then
                -- Install basedpyright, ruff
                lsp_pyright()
            elseif has_value({ "lua" }, ft) then
                -- Install lua-language-server
                lsp_lua()
            elseif has_value({ "bash", "sh" }, ft) then
                -- Install bash-language-server(npm)
                lsp_bashls()
            elseif has_value({ "rs", "rust" }, ft) then
                -- TODO, need more test.
                -- Install rust-analyzer
                lsp_rust()
            end
        end,
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
    return LSPM
end

return LSPM
