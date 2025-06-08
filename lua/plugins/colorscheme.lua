return {
    {
        "catppuccin/nvim",
        priority = 1000,
        name = "catppuccin",
        config = function()
            require("catppuccin").setup({
                flavour = "macchiato", -- latte, frappe, macchiato, mocha
                background = {         -- :h background
                    light = "latte",
                    dark = "macchiato",
                },
                italic = false,
                style = {
                    comments = "none",
                    strings = "bold",
                    keyword_return = "bold",
                }
            })
            vim.cmd.colorscheme 'catppuccin'
        end
    },
}
