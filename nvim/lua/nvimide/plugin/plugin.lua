---@class nvimide.core: nvimide.plugin
local M = {}

M.version = "0.1"

---@class NvimideOptions
local defaults = {
}


---@type NvimideOptions
local options
----------------------------------------------------------------
----    Utility
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
----    Config
----------------------------------------------------------------

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

local lspsetup = function()
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
end

----------------------------------------------------------------
----    Setup
----------------------------------------------------------------
function M.init()
    -- TODO, Add support for lazy.nvim loading
    local vim_plugin_path='~/.vim/plugins/'

    -- vim.opt.runtimepath:prepend(vim_plugin_path .. "lazy.nvim")
    vim.opt.runtimepath:append(vim_plugin_path .. "lazy.nvim")

    -- Example using a list of specs with the default options
    vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
    vim.g.maplocalleader = "\\" -- Same for `maplocalleader`
    local lazy_plugin = {
        --[[
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        -- import any extras modules here
        -- { import = "lazyvim.plugins.extras.lang.typescript" },
        -- { import = "lazyvim.plugins.extras.lang.json" },
        -- { import = "lazyvim.plugins.extras.ui.mini-animate" },
        -- import/override with your plugins
        { import = "plugins" },
        --]]

        { "vim-ide"          , dir = vim_plugin_path .. "vim-ide"          , lazy = false   , module = false } ,
        { "lightline.vim"    , dir = vim_plugin_path .. "lightline.vim"    , lazy = false } ,

        -- Command plugins
        { "nerdtree"        , dir = vim_plugin_path .. "nerdtree"        , lazy = true , cmd = "NERDTreeToggle" }       ,
        { "Colorizer"       , dir = vim_plugin_path .. "Colorizer"       , lazy = true , cmd = {"ColorToggle"} }        ,
        { "cctree"          , dir = vim_plugin_path .. "cctree"          , lazy = true , cmd = {"CCTreeWindowToggle"    , "CCTreeLoadDB"     , "CCTreeLoadXRefDB" , "CCTreeLoadBufferUsingTag" , "CCTreeTraceForward" , "CCTreeTraceReverse"} } ,
        { "ctrlp"           , dir = vim_plugin_path .. "ctrlp"           , lazy = true , cmd = {"CtrlP"} }              ,
        -- { "srcexpl"         , dir = vim_plugin_path .. "srcexpl"         , lazy = true , cmd = {"SrcExplRefresh"        , "SrcExplToggle"} } ,
        { "tabular"         , dir = vim_plugin_path .. "tabular"         , lazy = true , cmd = {"Tabularize"} }         ,
        { "vim-bookmarks"   , dir = vim_plugin_path .. "vim-bookmarks"   , lazy = true , cmd = {"BookmarkToggle"        , "BookmarkLoad"     , "BookmarkSave"} }  ,
        { "tcomment"        , dir = vim_plugin_path .. "tcomment"        , lazy = true , cmd = {"TComment"              , "TCommentBlock"} } ,
        { "vim-easygrep"    , dir = vim_plugin_path .. "vim-easygrep"    , lazy = true , cmd = "Grep" }                 ,
        { "vim-easygrep"    , dir = vim_plugin_path .. "vim-startuptime" , lazy = true , cmd = "StartupTime" }          ,
        { "gitgutter"       , dir = vim_plugin_path .. "gitgutter"       , lazy = true , cmd = {"GitGutterEnable"} }    ,
        { "bufexplorer"     , dir = vim_plugin_path .. "bufexplorer"     , lazy = true , cmd = { "ToggleBufExplorer" }} ,
        { "vim-fugitive"    , dir = vim_plugin_path .. "vim-fugitive"    , lazy = true , cmd = {"Git"}}                 ,
        { "vim-highlighter" , dir = vim_plugin_path .. "vim-highlighter" , lazy = true , cmd = {"HI"}}                  ,

        -- With Event
        { "tagbar"           , dir = vim_plugin_path .. "tagbar"           , lazy = true , event = "BufEnter"      , cmd = {"TagbarToggle"}} ,
        -- With setup
        { "cscope_maps.nvim" , dir = vim_plugin_path .. "cscope_maps.nvim" , lazy = true , cmd = {"Cscope"             , "Cs"                  , "CCTreeLoadDB"     , "CCTreeLoadXRefDB"         , "CCTreeLoadBufferUsingTag"} , 
        config = function()
            require("cscope_maps").setup()
        end},

        -- filetype load
        { "OmniCppComplete"            , dir = vim_plugin_path .. "OmniCppComplete"            , lazy = true , ft = {"cpp"       , "c"} } ,
        { "ale"                        , dir = vim_plugin_path .. "ale"                        , lazy = true , ft = {"sh"        , "cpp"  , "c"}   , cmd = "ALEEnable" } ,
        { "vim-cpp-enhanced-highlight" , dir = vim_plugin_path .. "vim-cpp-enhanced-highlight" , lazy = true , ft = {"cpp"       , "c"} } ,
        { "vim-python-pep8-indent"     , dir = vim_plugin_path .. "vim-python-pep8-indent"     , lazy = true , ft = {"python"} } ,
        { "nvim-lspconfig"             , dir = vim_plugin_path .. "nvim-lspconfig"             , lazy = true , ft = {"sh"        , "cpp"  , "c"},
        config = function()
            lspsetup()
        end},

        -- with key
        { "vim-visual-multi" , dir = vim_plugin_path .. "vim-visual-multi"   , lazy = true , 
        keys = {
            { "<C-n>", "<Plug>(VM-Find-Under)", desc = "VM-Find-Under", mode = {"n"} },
            { "<C-n>", "<Plug>(VM-Find-Subword-Under)", desc = "VM-Find-Subword-Under", mode = {"v"} },
        },},

        -- direct load
        -- { "vim-ingo-library" , dir = vim_plugin_path .. "vim-ingo-library" } ,
        { "vim-surround"     , dir = vim_plugin_path .. "vim-surround"       , lazy = false , event = LazyVimStarted} ,
        { "QFEnter"          , dir = vim_plugin_path .. "QFEnter"            , lazy = false , event = LazyVimStarted} ,
        { "gitgutter"        , dir = vim_plugin_path .. "gitgutter"          , lazy = false , event = LazyVimStarted} ,

        -- This are not really compatiable with lazynvim
        { "supertab"         , dir = vim_plugin_path .. "supertab"           , lazy = false , event = "VeryLazy"} ,
        -- { "vim-mark"         , dir = vim_plugin_path .. "vim-mark"           , lazy = false , event = "VeryLazy"} ,
    }

    local lazy_opts = {
        defaults = {
            -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
            -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
            lazy = true,
            -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
            -- have outdated releases, which may break your Neovim install.
            version = false, -- always use the latest git commit
            -- version = "*", -- try installing the latest stable version for plugins that support semver
        },
        -- install = { colorscheme = { "tokyonight", "habamax" } },
        checker = { enabled = true }, -- automatically check for plugin updates
        performance = {
            cache = {
                enabled = true,
            },
            reset_packpath = true, -- reset the package path to improve startup time
			rtp = {
				reset = true, -- reset the runtime path to $VIMRUNTIME and your config directory
				---@type string[]
				paths = {}, -- add any custom paths here that you want to includes in the rtp
				---@type string[] list any plugins you want to disable here
				disabled_plugins = {
					"gzip",
					-- "matchit",
					-- "matchparen",
					-- "netrwPlugin",
					"tarPlugin",
					"tohtml",
					"tutor",
					"zipPlugin",
				},
			},
        },
    }

    -- print(vim.inspect(vim.opt.runtimepath))
    require("lazy").setup(lazy_plugin, lazy_opts)
    -- print(vim.inspect(vim.opt.runtimepath))
end

---@param opts? NvimideOptions
function M.setup(opts)
    -- print("nvimide plugin setup")
    M.init()
end

return M
