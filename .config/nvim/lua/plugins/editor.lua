-- mini.pairs - inserts matching closing char ("", [], ())
vim.pack.add({ "https://github.com/echasnovski/mini.pairs" }, { confirm = false })

local ok_p, pairs = pcall(require, "mini.pairs")
if ok_p then
  pairs.setup({
    modes = { insert = true, command = true, terminal = false },
    skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
    skip_ts = { "string" },
    skip_unbalanced = true,
    markdown = true,
  })
end

-- mini surround - surround operations
vim.pack.add({ "https://github.com/echasnovski/mini.surround" }, { confirm = false })

local ok_s, surround = pcall(require, "mini.surround")
if ok_s then
  surround.setup({
    mappings = {
      add = "gsa",
      delete = "gsd",
      find = "gsf",
      find_left = "gsF",
      highlight = "gsh",
      replace = "gsr",
      update_n_lines = "gsn",
    },
  })
end

-- which key - popup of the active keybindings
vim.pack.add({ "https://github.com/folke/which-key.nvim" }, { confirm = false })

local ok_wk, wk = pcall(require, "which-key")
if ok_wk then
  wk.setup({
    preset = "helix",
  })
  wk.add({
    mode = { "n", "x" },
    -- { "<leader><tab>", group = "tabs", icon = "󰓩 " },
    {
      "<leader>b",
      group = "buffer",
      icon = "󰓩 ",
      expand = function()
        return require("which-key.extras").expand.buf()
      end,
    },
    { "<leader>c", group = "code", icon = " " },
    { "<leader>d", group = "debug", icon = " " },
    -- { "<leader>dp", group = "profiler", icon = "󰄖 " },
    { "<leader>f", group = "file/find", icon = " " },
    { "<leader>g", group = "git", icon = " " },
    { "<leader>q", group = "quit/session", icon = " " },
    { "<leader>s", group = "search", icon = " " },
    { "<leader>t", group = "triforce/stats", icon = "󰓫 " },
    { "<leader>u", group = "ui/toggles", icon = " " },
    -- { "<leader>w", group = "windows", icon = " ", proxy = "<c-w>", expand = function() return require("which-key.extras").expand.win() end, },
    { "<leader>x", group = "diagnostics", icon = "󰒡 " },
    -- { "[", group = "prev" },
    -- { "]", group = "next" },
    -- { "g", group = "goto" },
    { "gs", group = "surround" },
    { "z", group = "fold" },
    { "gx", desc = "open with system app" },
  })
end

-- flash - easier navigation
vim.pack.add({ "https://github.com/folke/flash.nvim" }, { confirm = false })

local ok_flash, flash = pcall(require, "flash")
if ok_flash then
  flash.setup({
    vscode = true,
  })

  local map = vim.keymap.set
  map({ "n", "x", "o" }, "s", function()
    flash.jump()
  end, { desc = "flash" })
  map({ "n", "x", "o" }, "S", function()
    flash.treesitter()
  end, { desc = "flash treesitter" })
  map("o", "r", function()
    flash.remote()
  end, { desc = "remote flash" })
  map({ "o", "x" }, "R", function()
    flash.treesitter_search()
  end, { desc = "treesitter search" })
  map("c", "<c-s>", function()
    flash.toggle()
  end, { desc = "toggle flash search" })

  -- treesitter incremental selection
  map({ "n", "o", "x" }, "<c-space>", function()
    flash.treesitter({ actions = { ["<c-space>"] = "next", ["<bs>"] = "prev" } })
  end, { desc = "treesitter incremental selection" })
end

-- git signs - highlight text that changed since the last git commit
vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" }, { confirm = false })

local ok_git, gitsigns = pcall(require, "gitsigns")
if ok_git then
  gitsigns.setup({
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    -- on_attach = function(buffer)
    -- 	local map = function(mode, l, r, desc)
    -- 		vim.keymap.set(mode, l, r, { buffer = buffer, desc = "git: " .. desc })
    -- 	end
    --
    -- 	-- git hunk navigation (with fallback to native diff)
    -- 	map("n", "]h", function()
    -- 		if vim.wo.diff then
    -- 			vim.cmd.normal({ "]c", bang = true })
    -- 		else
    -- 			gitsigns.nav_hunk("next")
    -- 		end
    -- 	end, "next hunk")
    --
    -- 	map("n", "[h", function()
    -- 		if vim.wo.diff then
    -- 			vim.cmd.normal({ "[c", bang = true })
    -- 		else
    -- 			gitsigns.nav_hunk("prev")
    -- 		end
    -- 	end, "prev hunk")
    --
    -- 	-- git Actions
    -- 	map("n", "<leader>ghs", gitsigns.stage_hunk, "stage hunk")
    -- 	map("n", "<leader>ghr", gitsigns.reset_hunk, "reset hunk")
    -- 	map("n", "<leader>ghp", gitsigns.preview_hunk_inline, "preview hunk")
    -- 	map("n", "<leader>ghb", function()
    -- 		gitsigns.blame_line({ full = true })
    -- 	end, "blame line")
    -- end,
  })
end

-- trouble - better diagnostics list and error list
vim.pack.add({ "https://github.com/folke/trouble.nvim" }, { confirm = false })

local ok_tr, trouble = pcall(require, "trouble")
if ok_tr then
  trouble.setup({
    modes = {
      lsp = { win = { position = "right" } },
    },
  })

  local map = vim.keymap.set
  map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "diagnostics (trouble)" })
  map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "buffer diagnostics (trouble)" })
  map("n", "<leader>cs", "<cmd>Trouble symbols toggle<cr>", { desc = "document symbols (trouble)" })
end

-- todo comments -- list of all TODO, HACK, BUG, WARN, INFO
vim.pack.add({ "https://github.com/folke/todo-comments.nvim" }, { confirm = false })

local ok_todo, todo = pcall(require, "todo-comments")
if ok_todo then
  todo.setup({})

  local map = vim.keymap.set
  map("n", "]t", todo.jump_next, { desc = "next todo comment" })
  map("n", "[t", todo.jump_prev, { desc = "prev todo comment" })
  map("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", { desc = "project todos (trouble)" })
end
