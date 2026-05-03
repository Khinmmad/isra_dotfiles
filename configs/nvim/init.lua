-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Opciones básicas
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.termguicolors  = true
vim.opt.signcolumn     = "yes"
vim.opt.expandtab      = true
vim.opt.shiftwidth     = 4
vim.opt.tabstop        = 4
vim.opt.scrolloff      = 8
vim.opt.cursorline     = true
vim.opt.splitbelow     = true
vim.opt.splitright     = true

-- Plugins
require("lazy").setup("plugins")
