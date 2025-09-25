-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- disable autocmd resize splis if window gets resized
vim.api.nvim_del_augroup_by_name("lazyvim_resize_splits")

-- disable spell checking for markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = false
  end,
})

-- save and remove trailing whitespace on save (except on ui.lua and markdown files)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype
    local fname = vim.api.nvim_buf_get_name(0)
    if ft ~= "markdown" and not fname:match("ui.lua$") then
      vim.cmd([[%s/\s\+$//e]])
    end
  end,
})
