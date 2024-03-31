vim.uv = vim.uv or vim.loop

local M = {}

---@param opts? nvimide.config
function M.setup(opts)
    -- print("nvimide setup")
    require("nvimide.core").setup(opts)
    require("nvimide.plugin").setup(opts)
    require("nvimide.util").setup(opts)
end

return M
