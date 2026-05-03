return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    main = "nvim-treesitter.configs",
    opts = {
        ensure_installed = {
            "lua", "python", "javascript", "typescript",
            "tsx", "html", "css", "json", "yaml", "bash",
            "markdown", "markdown_inline", "c", "cpp",
        },
        highlight    = { enable = true },
        indent       = { enable = true },
        auto_install = true,
    },
}
