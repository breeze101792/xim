---@class nvimide.core: nvimide.plugin
local M = {}

M.version = "0.1"

---@class NvimideOptions
local defaults = {
}


---@type NvimideOptions
local options

---@param opts? NvimideOptions
function M.setup(opts)
    -- print("nvimide util setup")
end

return M
