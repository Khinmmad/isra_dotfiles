return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
        { "<leader>ff", "<cmd>Telescope find_files<cr>",  desc = "Buscar archivos" },
        { "<leader>fg", "<cmd>Telescope live_grep<cr>",   desc = "Buscar en texto" },
        { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "Buffers" },
        { "<leader>fh", "<cmd>Telescope help_tags<cr>",   desc = "Ayuda" },
        { "<leader>fr", "<cmd>Telescope oldfiles<cr>",    desc = "Archivos recientes" },
    },
    config = function()
        local telescope = require("telescope")
        telescope.setup({
            defaults = {
                prompt_prefix   = "  ",
                selection_caret = " ",
                layout_strategy = "horizontal",
                file_ignore_patterns = { "node_modules", ".git/", "%.lock" },
            },
        })
        telescope.load_extension("fzf")
    end,
}
