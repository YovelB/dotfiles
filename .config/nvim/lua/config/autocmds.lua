-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- disable autocmd resize splits if window gets resized
vim.api.nvim_del_augroup_by_name("lazyvim_resize_splits")

-- disable spell checking for markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "typst", "tex" },
  callback = function()
    vim.opt_local.spell = false
  end,
})

-- save and remove trailing whitespace on save (except on ui.lua and markdown files)
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*",
--   callback = function()
--     local ft = vim.bo.filetype
--     local fname = vim.api.nvim_buf_get_name(0)
--     if ft ~= "markdown" and not fname:match("ui.lua$") then
--       vim.cmd([[%s/\s\+$//e]])
--     end
--   end,
-- })

-- disable auto comment continuation
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})

-- fix python tab spacing to 2 from 4
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- typst global vars
_G.TypstWatchBuf = nil
_G.TypstJobId = nil

-- global function to safely kill the process and delete the buffer
_G.TypstKill = function()
  if _G.TypstJobId then
    -- 1. Stop the job
    vim.fn.jobstop(_G.TypstJobId)
    _G.TypstJobId = nil
  end
  if _G.TypstWatchBuf and vim.api.nvim_buf_is_valid(_G.TypstWatchBuf) then
    -- 2. Force delete the buffer (ignoring unsaved changes warning for term)
    vim.api.nvim_buf_delete(_G.TypstWatchBuf, { force = true })
    _G.TypstWatchBuf = nil
  end
end

-- typst: handle exit safely
-- Use ExitPre to kill the job before Neovim tries to close windows/buffers
vim.api.nvim_create_autocmd("ExitPre", {
  callback = function()
    _G.TypstKill()
  end,
  desc = "Kill Typst watch job before exiting Neovim",
})

-- typst: open watch widnow on save + setup for auto hide
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.typ",
  callback = function()
    -- check if watch process is running
    if _G.TypstJobId and _G.TypstWatchBuf and vim.api.nvim_buf_is_valid(_G.TypstWatchBuf) then
      local win = vim.fn.bufwinnr(_G.TypstWatchBuf)

      -- if hidden, show it
      if win == -1 then
        vim.cmd("botright 10split")
        vim.api.nvim_win_set_buf(0, _G.TypstWatchBuf)
        vim.cmd("normal! G") -- scroll to bottom
        vim.cmd("wincmd p") -- switch back to editor
      end

      -- setup auto-hide triggers (typing or entering insert mode)
      vim.api.nvim_create_autocmd({ "InsertEnter", "TextChanged" }, {
        buffer = 0, -- current typst buffer
        once = true, -- run only once
        callback = function()
          local watch_win = vim.fn.bufwinnr(_G.TypstWatchBuf)
          if watch_win ~= -1 then
            vim.cmd(watch_win .. "close")
          end
        end,
      })
    end
  end,
  desc = "Typst: Open watch window on save & auto-hide",
})
