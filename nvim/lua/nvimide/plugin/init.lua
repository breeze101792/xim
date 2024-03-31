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
    -- print("nvimide plugin setup")
    require("nvimide.plugin.plugin").setup(opts)
end

return M
