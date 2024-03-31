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
local init_nvimide = function()
    -- print("Experiment lazy load.")
    require("nvimide").setup({})

    -- FIXME, remove this line. for neovim
    --[[
    vim.opt.runtimepath:append('~/.vim')
    vim.opt.runtimepath:append('~/.vim/after')
    --]]

    -- It's for compatibility
    vim.api.nvim_exec([[
    function! IDE_PlugInDealyLoading()
        " :GitGutterEnable
        " FIXME, It's just a temp fix for nvim cscope
        " execute 'lua require("cscope_maps").setup()'
        " Tag setup
        " -------------------------------------------
        call TagSetup()
    endfunction
    ]], false)
end
local init_plug = function()
    local flag_lazy=true
    -- flag_lazy=false

    if vim.g.IDE_CFG_PLUGIN_ENABLE ~= "y" then
        return
    end
    -- flag_lazy = false
    vim.cmd("so ~/.vim/vim-ide/plugin/PluginPreConfig.vim")

    -- TODO, Default off, since it's no fast then the original one.
    if flag_lazy and jit and jit.version then
        init_nvimide()
    else
        vim.cmd("so ~/.vim/vim-ide/plugin/Plugin.vim")
        vim.cmd("luafile ~/.config/nvim/lua/vimlegacy.lua")
    end

    --  After source
    vim.cmd("so ~/.vim/vim-ide/plugin/PluginPostConfig.vim")
end
local nvimreload = function()
    print("Neovim Reloaded.")
    init_base()
end

----------------------------------------------------------------
----    Setup function
----------------------------------------------------------------
local initialize = function()
    -- print("Neovim Init.")
    vim.opt.runtimepath:append('~/.vim')
    vim.opt.runtimepath:append('~/.vim/after')

    if false then
        -- Vim script
        -- Don't use vim script for start up
        -- vim.opt.packpath = vim.g.runtimepath
        vim.cmd('source ~/.vimrc')
    else
        init_base()
        init_plug()

        -- Reload function
        vim.api.nvim_create_user_command("Reload", nvimreload, {})
    end
end

-- Do function
initialize()
