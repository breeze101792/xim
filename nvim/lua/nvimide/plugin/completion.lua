---@class nvimide.core: nvimide.plugin
local COMP= {}

---@class NvimideOptions
local defaults = {
    plugin_path = "~/.vim/plugins/",
}

---@type NvimideOptions
local options = defaults

----------------------------------------------------------------
----    Plugin
----------------------------------------------------------------
function get_supertab()
    local vim_plugin_path='~/.vim/plugins/'
    return { "supertab"     , dir = vim_plugin_path .. "supertab"  ,
    keys = {
        { "<tab>", "<Plug>SuperTabForward", desc = "SuperTabForward", mode = {"i"} },
    },}
end

function get_coc()
    local vim_plugin_path='~/.vim/plugins/'
    return { "coc"     , dir = vim_plugin_path .. "coc.nvim" , event = "VeryLazy"}
end

function get_ncmp()
    return {
        -- [Completion Engine]
        {
            "hrsh7th/nvim-cmp",
            event = "InsertEnter",
            dependencies = {
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-path",
                "saadparwaiz1/cmp_luasnip", -- Link Snippet and completion menu
            },
            config = function()
                local cmp = require("cmp")
                local luasnip = require("luasnip")
                cmp.setup({
                    snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
                    mapping = cmp.mapping.preset.insert({
                        ["<CR>"] = cmp.mapping.confirm({ select = true }),
                        ["<Tab>"] = cmp.mapping(function(fallback)
                            if cmp.visible() then cmp.select_next_item()
                            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
                            else fallback() end
                        end, { "i", "s" }),
                        -- S-Tab select previous item or jump back to the previous snippet node
                        ['<S-Tab>'] = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_prev_item()
                            elseif luasnip.jumpable(-1) then
                                luasnip.jump(-1)
                            else
                                fallback()
                            end
                        end, { 'i', 's' }),
                    }),
                    sources = cmp.config.sources({
                        { name = "nvim_lsp" },
                        { name = "luasnip" },
                    }, {
                        { name = "buffer" },
                    })
                })
            end
        },

        -- [Snippet Engine and Database]
        {
            "L3MON4D3/LuaSnip",
            event = "InsertEnter",
            dependencies = { "rafamadriz/friendly-snippets" },
            config = function()
                require("luasnip.loaders.from_vscode").lazy_load()
            end
        }
    }
end

function COMP.get_impl(impl)
    if impl == "coc" then
        return get_coc()
    elseif impl == "supertab" then
        return get_supertab()
    elseif impl == "ncmp" then
        return get_ncmp()
    else
        return nil
    end
end

---@param opts? NvimideOptions
function COMP.setup(opts)
    options = vim.tbl_deep_extend("force", defaults, opts or {})
    return COMP
end

return COMP
