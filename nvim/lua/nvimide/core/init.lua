

---@class nvimide.core: nvimide.core
local M = {}

M.version = "0.1"

---@class NvimideOptions
local defaults = {
}

---@type NvimideOptions
local options

----    Local Functions
----------------------------------------------------------------
local nvim_options = function(opts)
    -- Starting clipboard is slow, so disable it for now.
    vim.g.loaded_clipboard_provider = 0
end

----    Module Functions
----------------------------------------------------------------
---@param opts? NvimideOptions
function M.setup(opts)
    options = vim.tbl_deep_extend("force", defaults, opts or {})

    -- TODO, seperate settings output of this files.
    nvim_options()

    -- Setup keymap
    local keymap = require('nvimide.core.keymap')
    keymap.setup({});
end

return M
