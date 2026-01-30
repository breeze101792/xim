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
-- 定義當 LSP 連結到 Buffer 時要做的事
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

local lspclangd = function(opts)
    local lspconfig = require 'lspconfig'

    if vim.fn.executable('clangd') == false then
        -- print("clangd not exist.")
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

local lspccls = function(opts)
    local lspconfig = require 'lspconfig'

    if vim.fn.executable('ccls') == false then
        -- print("ccls exist.")
        return
    end

    lspconfig.ccls.setup {
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
    }
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
                    lspclangd()
                else
                    -- FIXME, it's still not woring
                    lspccls()
                end
                --[[
                elseif has_value({ "c", "cpp", "objc", "objcpp", "cuda", "proto" }, vim.bo.filetype) then
                print("Fit list.")
                --]]
            end
        end,
    })
end

function LSPM.get_impl(impl)
    local vim_plugin_path = options.plugin_path
    return {
        {
            "nvim-lspconfig" ,
            dir = vim_plugin_path .. "nvim-lspconfig" ,
            ft = {"sh" , "cpp" , "c"},
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
