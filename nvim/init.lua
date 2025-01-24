----------------------------------------------------------------
----    Initialize
----------------------------------------------------------------
local init_lite = function()
    vim.cmd('source ' .. vim.g.IDE_ENV_ROOT_PATH .. '/scripts/core/Environment.vim')
    vim.cmd('source ' .. vim.g.IDE_ENV_ROOT_PATH .. '/scripts/core/Settings.vim')
    vim.cmd('source ' .. vim.g.IDE_ENV_ROOT_PATH .. '/scripts/core/KeyMaps.vim')
    vim.cmd('source ' .. vim.g.IDE_ENV_ROOT_PATH .. '/scripts/core/Autocmd.vim')

    vim.cmd('source ' .. vim.g.IDE_ENV_ROOT_PATH .. '/scripts/lite.vim')

    vim.cmd('source ' .. vim.g.IDE_ENV_ROOT_PATH .. '/scripts/adaptation/Adaptation.vim')
    vim.cmd('source ' .. vim.g.IDE_ENV_ROOT_PATH .. '/scripts/utility/Utility.vim')

    -- FIXME, Patch for neovim restore env.
    vim.g.IDE_MDOULE_STATUSLINE = "y"
    vim.g.IDE_MDOULE_HIGHLIGHTWORD = "y"
    vim.g.IDE_MDOULE_BOOKMARK = "y"
    vim.cmd('source ' .. vim.g.IDE_ENV_ROOT_PATH .. '/scripts/module/Module.vim')
end

local init_base = function()
    -- FIXME, Still use vim config scripts
    if vim.fn.filereadable("~/.vim/ConfigCustomize.vim") then
        vim.cmd("source ~/.vim/ConfigCustomize.vim")
    end

    vim.cmd("source " .. vim.g.IDE_ENV_ROOT_PATH .."/scripts/core/Core.vim")
    --[[
    vim.cmd("source " .. vim.g.IDE_ENV_ROOT_PATH .."/scripts/core/Config.vim")
    vim.cmd("source " .. vim.g.IDE_ENV_ROOT_PATH .."/scripts/core/Environment.vim")
    vim.cmd("source " .. vim.g.IDE_ENV_ROOT_PATH .."/scripts/core/Settings.vim")
    vim.cmd("source " .. vim.g.IDE_ENV_ROOT_PATH .."/scripts/core/KeyMaps.vim")

    if vim.g.IDE_CFG_AUTOCMD_ENABLE == "y" then
        vim.cmd("source " .. vim.g.IDE_ENV_ROOT_PATH .."/scripts/core/Autocmd.vim")
    end
    --]]

    -- Adaptation layer
    vim.cmd("source " .. vim.g.IDE_ENV_ROOT_PATH .."/scripts/adaptation/Adaptation.vim")

    -- utility function related
    vim.cmd("source " .. vim.g.IDE_ENV_ROOT_PATH .."/scripts//utility/Utility.vim")

    if vim.g.IDE_CFG_PLUGIN_ENABLE == "y" then
        vim.cmd('source ' .. vim.g.IDE_ENV_ROOT_PATH .. '/scripts/framework/Framework.vim')
    end
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
    local flag_lite=os.getenv("VIDE_SH_IDE_LITE")
    if flag_lite == 'y' then
        init_lite()
        vim.cmd('redraw')
        print("Neovim Lite Reloaded.")
    else
        init_base()
        require("nvimide").reload({})
        if vim.g.IDE_CFG_PLUGIN_ENABLE == "y" then
            --  Plugin settings
            vim.cmd("source " .. vim.g.IDE_ENV_ROOT_PATH .."/scripts/plugin/PluginPreConfig.vim")
            vim.cmd("source " .. vim.g.IDE_ENV_ROOT_PATH .."/scripts/plugin/PluginPostConfig.vim")
        end

        vim.cmd("source " .. vim.g.IDE_ENV_ROOT_PATH .."/scripts/module/Module.vim")

        if vim.g.IDE_CFG_PLUGIN_ENABLE ~= "n" then
            vim.cmd('source ' .. vim.g.IDE_ENV_ROOT_PATH .. '/scripts/framework/Framework.vim')
        end
        vim.cmd('redraw')
        print("Neovim Reloaded.")
    end
end

----------------------------------------------------------------
----    Setup function
----------------------------------------------------------------
local initialize = function()
    local flag_legacy=false
    local flag_lite=os.getenv("VIDE_SH_IDE_LITE")
    -- print("Neovim Init.")
    -- Note. disable session optons for fixing var restore.
    -- vim.opt.sessionoptions:remove('globals')

    vim.g.IDE_ENV_ROOT_PATH = "~/.config/nvim"

    if flag_legacy then
        -- Vim script
        -- Don't use vim script for start up
        -- vim.opt.packpath = vim.g.runtimepath
        vim.opt.runtimepath:append('~/.vim')
        vim.opt.runtimepath:append('~/.vim/after')

        vim.cmd('source ~/.vimrc')
    elseif flag_lite == 'y' then
        init_lite()

        -- Reload function
        vim.api.nvim_create_user_command("Reload", nvimreload, {})
    else
        init_base()
        init_plug()

        -- FIXME, find a place to insert it.
        vim.cmd("source " .. vim.g.IDE_ENV_ROOT_PATH .."/scripts/module/Module.vim")

        -- Reload function
        vim.api.nvim_create_user_command("Reload", nvimreload, {})
    end
end

-- Do function
initialize()
