-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt
opt.relativenumber = false
opt.smoothscroll = false
opt.winminwidth = 0
opt.winminheight = 0

vim.g.snacks_animate = false

-- for latex editing
vim.g.vimtex_quickfix_autoclose_after_keystrokes = 2

-- disable not needed providers
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
