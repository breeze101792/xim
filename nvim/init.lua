
----------------------------------------------------------------
----    Initialize
----------------------------------------------------------------
local init_base = function()
    -- Lua script
    if vim.fn.filereadable("~/.vim/ConfigCustomize.vim") then
        vim.cmd("so ~/.vim/ConfigCustomize.vim")
    end

    vim.cmd("so ~/.vim/vim-ide/core/Config.vim")
    vim.cmd("so ~/.vim/vim-ide/core/Environment.vim")
    vim.cmd("so ~/.vim/vim-ide/core/Settings.vim")
    vim.cmd("so ~/.vim/vim-ide/core/Autocmd.vim")
    vim.cmd("so ~/.vim/vim-ide/core/KeyMaps.vim")

    -- Adaptation layer
    vim.cmd("so ~/.vim/vim-ide/adaptation/Adaptation.vim")

    -- utility function related
    vim.cmd("so ~/.vim/vim-ide/utility/Library.vim")
    vim.cmd("so ~/.vim/vim-ide/utility/Functions.vim")
    vim.cmd("so ~/.vim/vim-ide/utility/CodeEnhance.vim")
    vim.cmd("so ~/.vim/vim-ide/utility/Lab.vim")
    vim.cmd("so ~/.vim/vim-ide/utility/Template.vim")
end
local init_plug = function()

    vim.cmd("so ~/.vim/vim-ide/plugin/PluginPreConfig.vim")

    if vim.g.IDE_CFG_PLUGIN_ENABLE == "y" then

        -- TODO, Default off, since it's no fast then the original one.
        if false and jit and jit.version then
            -- TODO, Add support for lazy.nvim loading
            print("Experiment Plugin loading system!!!.")
            -- It's for compatibility
            vim.api.nvim_exec([[
                function! IDE_PlugInDealyLoading()
                    " :GitGutterEnable
                    " FIXME, It's just a temp fix for nvim cscope
                    execute 'lua require("cscope_maps").setup()'
                    " Tag setup
                    " -------------------------------------------
                    call TagSetup()
                endfunction
            ]], false)
            local vim_plugin_path='~/.vim/plugins/'

            vim.opt.runtimepath:prepend(vim_plugin_path .. "lazy.nvim")

            -- Example using a list of specs with the default options
            vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
            vim.g.maplocalleader = "\\" -- Same for `maplocalleader`
            local lazy_plugin = {
                { "vim-ide", dir = vim_plugin_path .. "vim-ide" ,                  lazy = false, module = false } ,
                { "lightline.vim", dir = vim_plugin_path .. "lightline.vim" ,      lazy = false } ,
                { "cscope_maps.nvim", dir = vim_plugin_path .. "cscope_maps.nvim", lazy = false, module = false } ,

                -- Command plugins
                { "nerdtree", dir = vim_plugin_path .. "nerdtree",           cmd = "NERDTreeToggle" },
                { "Colorizer", dir = vim_plugin_path .. "Colorizer",         cmd = {"ColorToggle"} },
                { "cctree", dir = vim_plugin_path .. "cctree",               cmd = {"CCTreeWindowToggle", "CCTreeLoadDB", "CCTreeLoadXRefDB", "CCTreeLoadBufferUsingTag", "CCTreeTraceForward", "CCTreeTraceReverse"} },
                { "ctrlp", dir = vim_plugin_path .. "ctrlp",                 cmd = {"CtrlP"} },
                { "srcexpl", dir = vim_plugin_path .. "srcexpl",             cmd = {"SrcExplRefresh", "SrcExplToggle"} },
                { "tabular", dir = vim_plugin_path .. "tabular",             cmd = {"Tabularize"} },
                { "vim-bookmarks", dir = vim_plugin_path .. "vim-bookmarks", cmd = {"BookmarkToggle"} },
                { "tcomment", dir = vim_plugin_path .. "tcomment",           cmd = {"TComment", "TCommentBlock"} },
                { "vim-easygrep", dir = vim_plugin_path .. "vim-easygrep",   cmd = "Grep" },
                -- { "vim-mark", dir = vim_plugin_path .. "/vim-mark", cmd = {"<Plug>MarkSet"} },
                -- { "gitgutter", dir = vim_plugin_path .. "gitgutter", cmd = {"GitGutterEnable"} },

                -- filetype load
                { "OmniCppComplete", dir = vim_plugin_path .. "OmniCppComplete",                      ft = {"cpp", "c"} },
                { "ale", dir = vim_plugin_path .. "ale",                                              ft = {"sh", "cpp", "c"}, cmd = "ALEEnable" },
                { "vim-cpp-enhanced-highlight",dir = vim_plugin_path .. "vim-cpp-enhanced-highlight", ft = {"cpp", "c"} },
                { "vim-python-pep8-indent", dir = vim_plugin_path .. "vim-python-pep8-indent",        ft = {"python"} },
                { "nvim-lspconfig", dir = vim_plugin_path .. "nvim-lspconfig",                        ft = {"sh", "cpp", "c"} } ,

                -- direct load
                { "vim-ingo-library" , dir = vim_plugin_path .. "vim-ingo-library" } ,
                { "tagbar" , dir = vim_plugin_path .. "tagbar" , event = LazyVimStarted} ,
                { "supertab" , dir = vim_plugin_path .. "supertab" , event = LazyVimStarted} ,
                { "vim-visual-multi" , dir = vim_plugin_path .. "vim-visual-multi" , event = LazyVimStarted} ,
                { "vim-surround" , dir = vim_plugin_path .. "vim-surround" , event = LazyVimStarted} ,
                { "QFEnter" , dir = vim_plugin_path .. "QFEnter" , event = LazyVimStarted} ,
                { "bufexplorer", dir = vim_plugin_path .. "bufexplorer" , event = LazyVimStarted} ,
                { "vim-mark", dir = vim_plugin_path .. "vim-mark", event = LazyVimStarted},
                { "gitgutter", dir = vim_plugin_path .. "gitgutter", event = LazyVimStarted},
            }

            require("lazy").setup(lazy_plugin)

        else
            vim.cmd("so ~/.vim/vim-ide/plugin/Plugins.vim")
        end
    end
    vim.cmd("so ~/.vim/vim-ide/plugin/PluginPostConfig.vim")

    --  After source
    vim.cmd("luafile ~/.config/nvim/lua/nvimide.lua")
end
local nvimreload = function()
    print("Neovim Reloaded.")
    init_base()
    init_plug()
end




----------------------------------------------------------------
----    Setup function
----------------------------------------------------------------
local initialize = function()
    -- print("Neovim Init.")

    -- Setup env for legacy vim settings
    vim.opt.runtimepath:append('~/.vim')
    -- vim.opt.runtimepath:append("/mnt/data/tools/vim-ide/plugins/lzay.nvim")
    -- vim.opt.runtimepath:append('~/.vim/after')
    --[[
    print(vim.inspect(vim.opt.packpath))
    vim.opt.packpath = vim.g.runtimepath
    print(vim.inspect(vim.opt.packpath))
    --]]

    if false then
        -- Vim script
        -- Don't use vim script for start up
        vim.cmd('source ~/.vimrc')
    else
        -- Lua script
        -- Init function
        init_base()
        init_plug()

        -- Reload function
        vim.api.nvim_create_user_command("Reload", nvimreload, {})
    end
end

-- Do function
initialize()

----------------------------------------------------------------
----    Call from vim
----------------------------------------------------------------
--[[
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc

luafile ~/.config/nvim/lua/nvimide.lua
--]]


--[[
command! LuaReload call LuaReload()

func! LuaReload()
    luafile ~/.config/nvim/lua/nvimide.lua
endfunc
--]]
