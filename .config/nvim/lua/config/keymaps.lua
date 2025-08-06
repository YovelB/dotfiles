-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
local map = vim.keymap.set

-- removing default commands
-- general
vim.keymap.del("n", "<leader>L") -- lazy changelog vim.keymap.del("n", "<leader>`") -- switch buffer
vim.keymap.del("n", "<leader>?") -- buffer keymaps (which-key)
vim.keymap.del("n", "<leader>.") -- toggle stratch buffer
vim.keymap.del("n", "<leader>S") -- select stratch buffer
vim.keymap.del("n", "<leader>K") -- keywordprg
-- Buffers
vim.keymap.del("n", "<leader>bb") -- switch buffer
vim.keymap.del("n", "<leader>bD") -- delete buffer and windows
vim.keymap.del("n", "<leader>bl") -- delete buffers to the left
vim.keymap.del("n", "<leader>br") -- delete buffers to the right
-- UI
vim.keymap.del("n", "<leader>uL") -- enable relative line numbering
vim.keymap.del("n", "<leader>uS") -- enable smooth scroll
vim.keymap.del("n", "<leader>ua") -- enable animation
vim.keymap.del("n", "<leader>uw") -- enable wrap
vim.keymap.del("n", "<leader>uD") -- enable dimming
vim.keymap.del("n", "<leader>ub") -- disable dark background (to white)
vim.keymap.del("n", "<leader>ug") -- disable indent guides
vim.keymap.del("n", "<leader>uc") -- disable conceal level (conceal unneeded text like **bold** as bold)
vim.keymap.del("n", "<leader>uh") -- disable inlay hints (display var or param type info in gray as hints)
vim.keymap.del("n", "<leader>uT") -- disable treesitter highlighter
vim.keymap.del("n", "<leader>uf") -- disable auto format (Global)
vim.keymap.del("n", "<leader>uF") -- disable auto format (Buffer)
vim.keymap.del("n", "<leader>up") -- disable mini pairs
vim.keymap.del("n", "<leader>ui") -- inspect pos (not important)
vim.keymap.del("n", "<leader>uI") -- inspect tree (not important)
if pcall(require, "gitsigns") then
  pcall(vim.keymap.del, "n", "<leader>uG") -- disable git signs
end
-- File/Find
vim.keymap.del("n", "<leader>ft") -- terminal toggle (root dir)
vim.keymap.del("n", "<leader>fT") -- terminal toggle (cwd)

-- overriding default commands

-- adding custom keymaps
map("i", "jk", "<ESC>", { desc = "enter  mode exit" })
map("n", ";", ":", { desc = "enter command mode" })
map("n", "<M-a>", "ggVG", { desc = "selection select all" })

-- toggle statusline
local function toggle_statusline()
  local current_status = vim.o.laststatus
  if current_status == 0 then
    vim.o.laststatus = 2
    vim.notify("Statusline shown")
  else
    vim.o.laststatus = 0
    vim.notify("Statusline hidden")
  end
end
map("n", "<leader>ue", toggle_statusline, { desc = "Toggle statusline" })

-- LSP hide/show diagnostics
local lsp_hidden = false
map("n", "<leader>ct", function()
  lsp_hidden = not lsp_hidden
  if lsp_hidden then
    vim.diagnostic.config({
      virtual_text = false,
      signs = false,
      underline = false,
    })
    vim.notify("LSP diagnostics hidden")
  else
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
    })
    vim.notify("LSP diagnostics shown")
  end
end, { desc = "Toggle LSP diagnostics visibility" })

-- toggle Copilot suggestios
local enabled = false
local function toggle_copilot()
  require("copilot.suggestion").dismiss()
  enabled = not enabled
  if enabled then
    vim.cmd("silent! Copilot enable")
    require("copilot.suggestion").toggle_auto_trigger()
    vim.notify("Copilot enabled", vim.log.levels.INFO)
  else
    vim.cmd("silent! Copilot disable")
    vim.notify("Copilot disabled", vim.log.levels.INFO)
  end
  return ""
end
map("n", "<M-c>", toggle_copilot, { desc = "Toggle Copilot suggestions" })
map("i", "<M-c>", toggle_copilot, { desc = "Toggle Copilot suggestions", expr = true })
