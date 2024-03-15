#!/bin/lua

----------------------------------------------------------------
----    Utility map
----------------------------------------------------------------
function has_value(array, pattern)
    for _, value in pairs(array) do
        if value == pattern then 
            return true 
        end
    end
    return false 
end

----------------------------------------------------------------
----    Plugins
----------------------------------------------------------------

----    Cscope map
----------------------------------------------------------------

--[[
require("cscope_maps").setup({
    disable_maps = false,
    prefix = "<leader>s",
    -- cscope related defaults
    cscope = {
        -- location of cscope db file
        db_file = "./cscope.out",
        -- cscope executable
        exec = "gtags-cscope", -- "cscope" or "gtags-cscope"
        -- choose your fav picker
        picker = "quickfix", -- "telescope", "fzf-lua" or "quickfix"
        -- size of quickfix window
        qf_window_size = 5, -- any positive integer
        -- position of quickfix window
        qf_window_pos = "bottom", -- "bottom", "right", "left" or "top"
        -- "true" does not open picker for single result, just JUMP
        skip_picker_for_single_result = false, -- "false" or "true"
        -- these args are directly passed to "cscope -f <db_file> <args>"
        db_build_cmd_args = { "-bqkv" },
        -- statusline indicator, default is cscope executable
        statusline_indicator = nil,
        -- try to locate db_file in parent dir(s)
        project_rooter = {
            enable = false, -- "true" or "false"
            -- change cwd to where db_file is located
            change_cwd = false, -- "true" or "false"
        },
    }
})
--]]

----    Lsp configs
----------------------------------------------------------------
local lspsetup = function(opts)

    local win = require('lspconfig.ui.windows')
    local _default_opts = win.default_opts

    win.default_opts = function(options)
        local opts = _default_opts(options)
        opts.border = 'single'
        return opts
    end

end

local lspclangd = function(opts)
    local lspconfig = require 'lspconfig'

    if vim.fn.executable('clangd') == false then
        -- print("clangd not exist.")
        return
    end

    lspconfig.clangd.setup({
        filetypes={ "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        single_file_support = false,
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
        single_file_support = false,
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
----    Main
----------------------------------------------------------------
-- It's an early script for lua

local lspgroup = vim.api.nvim_create_augroup('lspsetup', { clear = false })
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
                lspccls()
            end
        --[[
        elseif has_value({ "c", "cpp", "objc", "objcpp", "cuda", "proto" }, vim.bo.filetype) then
            print("Fit list.")
        --]]
        end
    end,
})

