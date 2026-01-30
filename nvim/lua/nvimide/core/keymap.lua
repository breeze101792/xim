local KEYMAP= {}

---@class NvimideOptions
local defaults = {
    plugin_path = "~/.vim/plugins/",
}

---@type NvimideOptions
local options = defaults

local key_toggle_virtual_text = function()
    vim.keymap.set('n', '<leader>nt', function()
        -- Get the current global diagnostic configuration
        local config = vim.diagnostic.config()
        -- Check if virtual_text is enabled (check table or boolean)
        local is_on = config.virtual_text

        if is_on then
            vim.diagnostic.config({ virtual_text = false })
            print("Virtual Text: OFF")
        else
            vim.diagnostic.config({ virtual_text = true })
            print("Virtual Text: ON")
        end
    end, { desc = "Toggle Diagnostic Virtual Text" })
end

----    Module Functions
----------------------------------------------------------------
---@param opts? NvimideOptions
function KEYMAP.setup(opts)
    options = vim.tbl_deep_extend("force", defaults, opts or {})
    key_toggle_virtual_text()
    return KEYMAP
end

return KEYMAP
