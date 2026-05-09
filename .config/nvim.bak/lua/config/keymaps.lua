-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
local map = vim.keymap.set

-- removing default commands
-- general
vim.keymap.del("n", "<leader>L") -- lazy changelog
vim.keymap.del("n", "<leader>`") -- switch buffer
vim.keymap.del("n", "<leader>?") -- buffer keymaps (which-key)
vim.keymap.del("n", "<leader>.") -- toggle stratch buffer
vim.keymap.del("n", "<leader>S") -- select stratch buffer
vim.keymap.del("n", "<leader>K") -- keywordprg
-- buffers
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
vim.keymap.del("n", "<leader>ui") -- inspect pos
vim.keymap.del("n", "<leader>uI") -- inspect tree
vim.keymap.del("n", "<leader>ft") -- toggle terminal (root dir)
vim.keymap.del("n", "<leader>fT") -- toggle terminal (cwd)
if pcall(require, "gitsigns") then
  pcall(vim.keymap.del, "n", "<leader>uG") -- disable git signs
end
-- overriding problematic keymaps
vim.keymap.del("x", "a") -- around
vim.keymap.del("x", "an") -- next
vim.keymap.del("x", "al") -- last
vim.keymap.del("x", "ai") -- indent

vim.keymap.del("o", "an") -- next
vim.keymap.del("o", "al") -- last
vim.keymap.del("o", "ai") -- indent

vim.keymap.del("x", "in") -- next
vim.keymap.del("x", "il") -- last
vim.keymap.del("x", "ii") -- indent

vim.keymap.del("o", "in") -- next
vim.keymap.del("o", "il") -- last
vim.keymap.del("o", "ii") -- indent

vim.keymap.del("n", "gc") -- toggle comment
vim.keymap.del("n", "gra") -- LSP code action
vim.keymap.del("n", "grn") -- LSP rename
vim.keymap.del("n", "grt") -- LSP definition
vim.keymap.del("n", "gri") -- LSP implementation
vim.keymap.del("n", "grr") -- LSP references

-- adding custom keymaps
map("i", "jk", "<ESC>", { desc = "enter mode exit" })
map("i", "חל", function()
  vim.cmd("stopinsert")
  vim.fn.jobstart({ "setxkbmap", "us" })
end, { desc = "enter mode exit and switch to english" })
map("n", ";", ":", { desc = "enter command mode" })
map("n", "<M-a>", "ggVG", { desc = "selection select all" })
map("i", "<C-l>", "<C-o>A", { desc = "jump to end of line" })

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

-- Hebrew/RTL utilities
-- map("n", "<leader>uhr", ":set rightleft!<CR>", { desc = "Toggle RTL display" })

-- STM32CubeMX projects building
map("n", "<leader>cb", function()
  require("snacks").terminal("cmake --preset Debug && cmake --build --preset Debug -j16", {
    cwd = vim.fn.getcwd(),
    interactive = false, -- close automatically if successful (optional)
  })
end, { desc = "code: build project (cmake)" })
