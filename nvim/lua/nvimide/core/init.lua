

---@class nvimide.core: nvimide.core
local M = {}

M.version = "0.1"

---@class NvimideOptions
local defaults = {
}


---@type NvimideOptions
local options

---@param opts? NvimideOptions
function M.setup(opts)
    -- print("nvimide core setup")
    -- require("nvimide.plugins").setup(opts)
end

return M
