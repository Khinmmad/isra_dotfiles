return {
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        opts = { ui = { border = "rounded" } },
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = {
                "lua_ls", "pyright", "ts_ls",
                "html", "cssls", "jsonls", "bashls",
            },
            automatic_installation = true,
        },
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local lspconfig   = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            local on_attach = function(_, bufnr)
                local map = function(keys, func, desc)
                    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
                end
                map("gd",         vim.lsp.buf.definition,      "Ir a definición")
                map("gr",         vim.lsp.buf.references,      "Referencias")
                map("K",          vim.lsp.buf.hover,           "Hover docs")
                map("<leader>rn", vim.lsp.buf.rename,          "Renombrar")
                map("<leader>ca", vim.lsp.buf.code_action,     "Code action")
                map("<leader>d",  vim.diagnostic.open_float,   "Diagnóstico")
                map("[d",         vim.diagnostic.goto_prev,    "Diagnóstico anterior")
                map("]d",         vim.diagnostic.goto_next,    "Diagnóstico siguiente")
            end

            local servers = { "lua_ls", "pyright", "ts_ls", "html", "cssls", "jsonls", "bashls" }
            for _, server in ipairs(servers) do
                lspconfig[server].setup({ capabilities = capabilities, on_attach = on_attach })
            end

            -- Diagnósticos con iconos
            vim.diagnostic.config({
                virtual_text = { prefix = "●" },
                signs        = true,
                underline    = true,
                update_in_insert = false,
            })
        end,
    },
}
