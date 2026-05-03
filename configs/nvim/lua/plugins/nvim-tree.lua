return {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
        { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorador de archivos" },
    },
    opts = {
        filters = { dotfiles = false },
        renderer = {
            group_empty = true,
            icons = {
                glyphs = {
                    git = {
                        unstaged  = "",
                        staged    = "",
                        unmerged  = "",
                        renamed   = "➜",
                        untracked = "",
                        deleted   = "",
                        ignored   = "◌",
                    },
                },
            },
        },
        git = { enable = true },
    },
}
