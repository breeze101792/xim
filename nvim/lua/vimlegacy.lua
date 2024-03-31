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
--[[
function dump_value(array)
    for key, value in pairs(array) do
        print("Key:" .. key .. ", value: " .. value)
    end
end
--]]

----------------------------------------------------------------
----    KeyMaps
----------------------------------------------------------------
-- vim.api.nvim_set_keymap("n", "<leader><CR>", ":luafile $MYVIMRC<CR>", opts)

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
if false then
    -- This file is automatically loaded by plugins.core
    vim.g.mapleader = " "
    vim.g.maplocalleader = "\\"

    -- Enable LazyVim auto format
    vim.g.autoformat = true

    -- LazyVim root dir detection
    -- Each entry can be:
    -- * the name of a detector function like `lsp` or `cwd`
    -- * a pattern or array of patterns like `.git` or `lua`.
    -- * a function with signature `function(buf) -> string|string[]`
    vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

    -- LazyVim automatically configures lazygit:
    --  * theme, based on the active colorscheme.
    --  * editorPreset to nvim-remote
    --  * enables nerd font icons
    -- Set to false to disable.
    vim.g.lazygit_config = true

    -- Optionally setup the terminal to use
    -- This sets `vim.o.shell` and does some additional configuration for:
    -- * pwsh
    -- * powershell
    -- LazyVim.terminal.setup("pwsh")

    local opt = vim.opt

    opt.autowrite = true -- Enable auto write

    if not vim.env.SSH_TTY then
        -- only set clipboard if not in ssh, to make sure the OSC 52
        -- integration works automatically. Requires Neovim >= 0.10.0
        opt.clipboard = "unnamedplus" -- Sync with system clipboard
    end

    opt.completeopt = "menu,menuone,noselect"
    opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
    opt.confirm = true -- Confirm to save changes before exiting modified buffer
    opt.cursorline = true -- Enable highlighting of the current line
    opt.expandtab = true -- Use spaces instead of tabs
    opt.formatoptions = "jcroqlnt" -- tcqj
    opt.grepformat = "%f:%l:%c:%m"
    opt.grepprg = "rg --vimgrep"
    opt.ignorecase = true -- Ignore case
    opt.inccommand = "nosplit" -- preview incremental substitute
    opt.laststatus = 3 -- global statusline
    opt.list = true -- Show some invisible characters (tabs...
    opt.mouse = "a" -- Enable mouse mode
    opt.number = true -- Print line number
    opt.pumblend = 10 -- Popup blend
    opt.pumheight = 10 -- Maximum number of entries in a popup
    opt.relativenumber = true -- Relative line numbers
    opt.scrolloff = 4 -- Lines of context
    opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
    opt.shiftround = true -- Round indent
    opt.shiftwidth = 2 -- Size of an indent
    opt.shortmess:append({ W = true, I = true, c = true, C = true })
    opt.showmode = false -- Dont show mode since we have a statusline
    opt.sidescrolloff = 8 -- Columns of context
    opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
    opt.smartcase = true -- Don't ignore case with capitals
    opt.smartindent = true -- Insert indents automatically
    opt.spelllang = { "en" }
    opt.splitbelow = true -- Put new windows below current
    opt.splitkeep = "screen"
    opt.splitright = true -- Put new windows right of current
    opt.tabstop = 2 -- Number of spaces tabs count for
    opt.termguicolors = true -- True color support
    if not vim.g.vscode then
        opt.timeoutlen = 300 -- Lower than default (1000) to quickly trigger which-key
    end
    opt.undofile = true
    opt.undolevels = 10000
    opt.updatetime = 200 -- Save swap file and trigger CursorHold
    opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
    opt.wildmode = "longest:full,full" -- Command-line completion mode
    opt.winminwidth = 5 -- Minimum window width
    opt.wrap = false -- Disable line wrap
    opt.fillchars = {
        foldopen = "",
        foldclose = "",
        fold = " ",
        foldsep = " ",
        diff = "╱",
        eob = " ",
    }

    if vim.fn.has("nvim-0.10") == 1 then
        opt.smoothscroll = true
    end

    -- Folding
    vim.opt.foldlevel = 99

end
