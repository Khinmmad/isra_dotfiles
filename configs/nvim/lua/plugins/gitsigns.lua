return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        signs = {
            add          = { text = "▎" },
            change       = { text = "▎" },
            delete       = { text = "" },
            topdelete    = { text = "" },
            changedelete = { text = "▎" },
            untracked    = { text = "▎" },
        },
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns
            local map = function(mode, l, r, desc)
                vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
            end
            map("n", "]h", gs.next_hunk,        "Siguiente hunk")
            map("n", "[h", gs.prev_hunk,        "Hunk anterior")
            map("n", "<leader>hs", gs.stage_hunk,   "Stage hunk")
            map("n", "<leader>hr", gs.reset_hunk,   "Reset hunk")
            map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
            map("n", "<leader>hb", gs.blame_line,   "Blame línea")
        end,
    },
}
