return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "modern",
        spec = {
            { "<leader>f", group = "Telescope" },
            { "<leader>h", group = "Git hunks" },
            { "<leader>e", desc  = "Explorador" },
        },
    },
    config = function(_, opts)
        vim.g.mapleader = " "
        require("which-key").setup(opts)
    end,
}
