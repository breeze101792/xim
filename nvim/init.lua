----------------------------------------------------------------
----    Initialize
----------------------------------------------------------------
local init_base = function()
    local config_path="~/.config/nvim"
    -- Lua script
    -- FIXME, Still use vim config scripts
    if vim.fn.filereadable("~/.vim/ConfigCustomize.vim") then
        vim.cmd("source ~/.vim/ConfigCustomize.vim")
    end

    vim.cmd("source " .. config_path .."/scripts/core/Config.vim")
    vim.cmd("source " .. config_path .."/scripts/core/Environment.vim")
    vim.cmd("source " .. config_path .."/scripts/core/Settings.vim")
    vim.cmd("source " .. config_path .."/scripts/core/KeyMaps.vim")

    if vim.g.IDE_CFG_AUTOCMD_ENABLE == "y" then
        vim.cmd("source " .. config_path .."/scripts/core/Autocmd.vim")
    end

    -- Adaptation layer
    vim.cmd("source " .. config_path .."/scripts/adaptation/Adaptation.vim")

    -- utility function related
    vim.cmd("source " .. config_path .."/scripts//utility/Utility.vim")
end
local init_nvimide = function()
    -- print("Experiment lazy load.")
    require("nvimide").setup({})

end
local init_plug = function()
    local flag_lazy=true
    -- flag_lazy=false

    if vim.g.IDE_CFG_PLUGIN_ENABLE ~= "y" then
        -- If it's not plugin enable, do early return.
        vim.api.nvim_exec([[
            function! IDE_PlugInDealyLoading()
            endfunction
        ]], false)
        vim.cmd("source " .. vim.g.IDE_ENV_ROOT_PATH .."/scripts/plugin/PluginNone.vim")
        return
    else
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
    -- flag_lazy = false

    -- TODO, Default off, since it's no fast then the original one.
    if flag_lazy and jit and jit.version then
        -- print("lazy".. jit .. jit.version)

        vim.cmd("source " .. vim.g.IDE_ENV_ROOT_PATH .."/scripts/plugin/PluginPreConfig.vim")
        init_nvimide()
    else
        -- print("lagacy plugin")

        require("nvimide").reload({})
        vim.g.IDE_ENV_ROOT_PATH = "~/.vim"

        vim.opt.runtimepath:append('~/.vim')
        vim.opt.runtimepath:append('~/.vim/after')

        vim.cmd("source " .. vim.g.IDE_ENV_ROOT_PATH .."/scripts/plugin/PluginPreConfig.vim")
        vim.cmd("source " .. vim.g.IDE_ENV_ROOT_PATH .."/scripts/plugin/Plugin.vim")

        -- FIXME, Need to use IDE_ENV_ROOT_PATH
        vim.cmd("luafile ~/.config/nvim/lua/vimlegacy.lua")
    end

    --  After source
    vim.cmd("source " .. vim.g.IDE_ENV_ROOT_PATH .."/scripts/plugin/PluginPostConfig.vim")
end

local nvimreload = function()
    init_base()
    require("nvimide").reload({})
    if vim.g.IDE_CFG_PLUGIN_ENABLE == "y" then
        --  Plugin settings
        vim.cmd("source " .. vim.g.IDE_ENV_ROOT_PATH .."/scripts/plugin/PluginPreConfig.vim")
        vim.cmd("source " .. vim.g.IDE_ENV_ROOT_PATH .."/scripts/plugin/PluginPostConfig.vim")
    end
    print("Neovim Reloaded.")
end

----------------------------------------------------------------
----    Setup function
----------------------------------------------------------------
local initialize = function()
    local flag_lagacy=false
    -- print("Neovim Init.")

    if flag_lagacy then
        -- Vim script
        -- Don't use vim script for start up
        -- vim.opt.packpath = vim.g.runtimepath
        vim.opt.runtimepath:append('~/.vim')
        vim.opt.runtimepath:append('~/.vim/after')

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
