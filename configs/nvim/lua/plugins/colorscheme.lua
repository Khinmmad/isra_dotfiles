return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
        flavour = "mocha",   -- latte | frappe | macchiato | mocha
        transparent_background = false,
        integrations = {
            cmp        = true,
            gitsigns   = true,
            nvimtree   = true,
            treesitter = true,
            telescope  = { enabled = true },
            which_key  = true,
        },
    },
    config = function(_, opts)
        require("catppuccin").setup(opts)
        vim.cmd.colorscheme("catppuccin")
    end,
}
