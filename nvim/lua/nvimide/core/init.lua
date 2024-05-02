

---@class nvimide.core: nvimide.core
local M = {}

M.version = "0.1"

---@class NvimideOptions
local defaults = {
}


---@type NvimideOptions
local options

function option_patch(opts)
    -- Starting clipboard is slow, so disable it for now.
    vim.g.loaded_clipboard_provider = 0
end

---@param opts? NvimideOptions
function M.setup(opts)
    -- print("nvimide core setup")
    -- require("nvimide.plugins").setup(opts)
    -- let g:loaded_clipboard_provider = 1
    option_patch()
end

return M
