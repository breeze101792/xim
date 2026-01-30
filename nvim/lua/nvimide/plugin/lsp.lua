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

local lspui = function(opts)
    local _border = "single"

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, {
            border = _border
        }
    )

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, {
            border = _border
        }
    )

    vim.diagnostic.config{
        float={border=_border}
    }
end

-- Define after LSP attach to a Buffer
local on_attach = function(client, bufnr)
    -- Activate signature display
    require("lsp_signature").on_attach({
        bind = true,
        handler_opts = { border = "rounded" },
    }, bufnr)

    -- Key settings
    --[[
    local opts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    --]]
end

local lsp_clangd = function(opts)
    local lspconfig = require 'lspconfig'

    if vim.fn.executable('clangd') ~= 1 then
        lsp_notify("clangd")
        return
    end

    lspconfig.clangd.setup({
        filetypes={ "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        on_attach = on_attach,
        cmd = { "clangd", "--background-index" },
        -- single_file_support = false,
        -- Only found compile_commands for running
        root_dir = function(fname)
            return require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(fname)
            -- or require("lspconfig.util").find_git_ancestor(fname)
        end,

    })
end

local lsp_ccls = function(opts)
    local lspconfig = require 'lspconfig'

    if vim.fn.executable('ccls') ~= 1 then
        lsp_notify("ccls")
        return
    end

    lspconfig.ccls.setup({
        filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
        on_attach = on_attach,
        -- single_file_support = false,
        init_options = {
            compilationDatabaseDirectory = "build";
            index = {
                threads = 0;
            };
            clang = {
                excludeArgs = { "-frounding-math"} ;
            };
        },
        root_dir = function(fname)
            return require("lspconfig.util").root_pattern("compile_commands.json", ".ccls")(fname)
            -- or require("lspconfig.util").find_git_ancestor(fname)
        end,
    })
end
local lsp_pyright = function(opts)
    local lspconfig = require 'lspconfig'

    if vim.fn.executable('basedpyright') ~= 1 then
        lsp_notify("basedpyright")
        return
    end

    lspconfig.basedpyright.setup({
        filetypes = { 'python' },
        on_attach = on_attach,
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
        root_dir = function(fname)
            return require("lspconfig.util").root_pattern(".venv", ".git")(fname)
        end,
    })

end
local lsp_lua = function(opts)
    local lspconfig = require 'lspconfig'

    if vim.fn.executable('lua-language-server') ~= 1 then
        lsp_notify("lua-language-server")
        return
    end

    lspconfig.lua_ls.setup({
        filetypes = { "lua"},
        on_attach = on_attach,
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
        root_dir = function(fname)
            return require("lspconfig.util").root_pattern(".git")(fname)
        end,
    })
end
local lsp_bashls = function(opts)
    local lspconfig = require 'lspconfig'

    if vim.fn.executable('bash-language-server') ~= 1 then
        lsp_notify("bash-language-server")
        return
    end

    lspconfig.bashls.setup({
        filetypes = { "sh", "bash" },
        on_attach = on_attach,
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
        root_dir = function(fname)
            return require("lspconfig.util").root_pattern(".git")(fname)
        end,
    })
end
local lsp_rust = function(opts)
    local lspconfig = require 'lspconfig'

    if vim.fn.executable('rust_analyzer') ~= 1 then
        lsp_notify("rust_analyzer")
        return
    end

    lspconfig.rust_analyzer.setup({
        filetypes = { "rust", "rs" },
        on_attach = on_attach,
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
            }
        },
        root_dir = function(fname)
            -- Cargo.toml ??
            return require("lspconfig.util").root_pattern(".git")(fname)
        end,
    })
end

----------------------------------------------------------------
----    Plugin
----------------------------------------------------------------
local lspconfig = function()
    local lspgroup = vim.api.nvim_create_augroup('lspconfig', { clear = false })
    vim.api.nvim_create_autocmd('BufReadPost', {
        once = true,
        group = lspgroup,
        callback = function(args)
            local file_type=vim.fn.expand("%")
            if has_value({ "c", "cpp", "objc", "objcpp", "cuda", "proto" }, vim.bo.filetype) then
                lspui()
                -- Default use ccls
                local flag_clangd = true
                if flag_clangd then
                    lsp_clangd()
                else
                    -- FIXME, it's still not working
                    lsp_ccls()
                end
            elseif has_value({ "py", "python" }, vim.bo.filetype) then
                -- Install basedpyright, ruff
                lspui()
                lsp_pyright()
            elseif has_value({ "lua"}, vim.bo.filetype) then
                -- Install lua-language-server
                lspui()
                lsp_lua()
            elseif has_value({ "bash", "sh"}, vim.bo.filetype) then
                -- Install bash-language-server(npm)
                lspui()
                lsp_bashls()
            elseif has_value({ "rs", "rust"}, vim.bo.filetype) then
                -- TODO, need more test.
                -- Install rust-analyzer
                lspui()
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
