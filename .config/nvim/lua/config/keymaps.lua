local map = vim.keymap.set

-- ===============================
-- personal
-- ===============================
map("n", "<esc>", "<cmd>nohlsearch<CR>", { desc = "clear search highlights" })
map("i", "jk", "<esc>", { desc = "enter normal mode" })
map("i", "<C-l>", "<C-o>A", { desc = "jump to end of line" })
map("n", ";", ":", { desc = "enter command mode" })
map("n", "<M-a>", "ggVG", { desc = "select all" })

-- hebrew specific exit mapping
map("i", "חל", function()
	vim.cmd("stopinsert")
	vim.fn.jobstart({ "setxkbmap", "us" })
end, { desc = "enter mode exit and switch to english" })

-- toggle statusline
local function toggle_statusline()
	local current_status = vim.o.laststatus
	if current_status == 0 then
		vim.o.laststatus = 3
		vim.notify("Statusline shown")
	else
		vim.o.laststatus = 0
		vim.notify("Statusline hidden")
	end
end
map("n", "<leader>ue", toggle_statusline, { desc = "Toggle statusline" })

-- toggle LSP diagnostics visibility
local lsp_hidden = false
map("n", "<leader>ct", function()
	lsp_hidden = not lsp_hidden
	if lsp_hidden then
		vim.diagnostic.config({ virtual_text = false, signs = false, underline = false })
		vim.notify("LSP diagnostics hidden")
	else
		vim.diagnostic.config({ virtual_text = true, signs = true, underline = true })
		vim.notify("LSP diagnostics shown")
	end
end, { desc = "Toggle lsp visibility" })

-- ===============================
-- movement and operation
-- ===============================
-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "down", expr = true, silent = true })
map({ "n", "x" }, "<down>", "v:count == 0 ? 'gj' : 'j'", { desc = "down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "up", expr = true, silent = true })
map({ "n", "x" }, "<up>", "v:count == 0 ? 'gk' : 'k'", { desc = "up", expr = true, silent = true })

-- move to window using the <ctrl> hjkl keys
map("n", "<c-h>", "<c-w>h", { desc = "go to left window", remap = true })
map("n", "<c-j>", "<c-w>j", { desc = "go to lower window", remap = true })
map("n", "<c-k>", "<c-w>k", { desc = "go to upper window", remap = true })
map("n", "<c-l>", "<c-w>l", { desc = "go to right window", remap = true })

-- resize window using <ctrl> arrow keys
map("n", "<c-up>", "<cmd>resize +2<cr>", { desc = "increase window height" })
map("n", "<c-down>", "<cmd>resize -2<cr>", { desc = "decrease window height" })
map("n", "<c-left>", "<cmd>vertical resize -2<cr>", { desc = "decrease window width" })
map("n", "<c-right>", "<cmd>vertical resize +2<cr>", { desc = "increase window width" })

-- move lines
map("n", "<a-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "move down" })
map("n", "<a-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "move up" })
map("i", "<a-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "move down" })
map("i", "<a-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "move up" })
map("v", "<a-j>", ":<c-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "move down" })
map("v", "<a-k>", ":<c-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "move up" })

-- add undo break points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- save file
map({ "i", "x", "n", "s" }, "<c-s>", "<cmd>w<cr><esc>", { desc = "save file" })

-- better indenting
map("x", "<", "<gv", { desc = "indent left" })
map("x", ">", ">gv", { desc = "indent right" })

-- commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "add comment below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "add comment above" })

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "quit all" })

-- ===============================
-- buffer and tabs
-- ===============================
map("n", "<s-h>", "<cmd>bprevious<cr>", { desc = "prev buffer" })
map("n", "<s-l>", "<cmd>bnext<cr>", { desc = "next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "prev buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "next buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "switch to other buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "switch to other buffer" })
map("n", "<leader>bd", function()
	require("snacks").bufdelete()
end, { desc = "delete buffer" })
map("n", "<leader>bo", function()
	require("snacks").bufdelete.other()
end, { desc = "delete other buffers" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "delete buffer and window" })

-- windows
map("n", "<leader>-", "<c-w>s", { desc = "split window below", remap = true })
map("n", "<leader>|", "<c-w>v", { desc = "split window right", remap = true })
-- map("n", "<leader>wd", "<c-w>c", { desc = "delete window", remap = true })

-- tabs
-- map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "last tab" })
-- map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "close other tabs" })
-- map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "first tab" })
-- map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "new tab" })
-- map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "next tab" })
-- map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "close tab" })
-- map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "previous tab" })

-- ===============================
-- search and diagnostics
-- ===============================
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "next search result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "next search result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "next search result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "prev search result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "prev search result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "prev search result" })

-- native formatting via conform.nvim
map({ "n", "x" }, "<leader>cf", function()
	require("conform").format({ lsp_fallback = true })
end, { desc = "format document" })

-- native diagnostic jumps
local diagnostic_goto = function(next, severity)
	return function()
		vim.diagnostic.jump({
			count = (next and 1 or -1) * vim.v.count1,
			severity = severity and vim.diagnostic.severity[severity] or nil,
			float = true,
		})
	end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "line diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "next diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "prev diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "next error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "prev error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "next warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "prev warning" })

-- loclist and quickfix
map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "location list" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "quickfix list" })
map("n", "[q", vim.cmd.cprev, { desc = "previous quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "next quickfix" })

-- ===============================
-- snacks integration
-- ===============================

local ok, snacks = pcall(require, "snacks")
if ok then
	-- ui toggles
	snacks.toggle.option("spell", { name = "spelling" }):map("<leader>us")
	snacks.toggle.option("wrap", { name = "wrap" }):map("<leader>uw")
	snacks.toggle.option("relativenumber", { name = "relative number" }):map("<leader>ul")
	snacks.toggle.diagnostics():map("<leader>ud")
	snacks.toggle.line_number():map("<leader>ul")
	snacks.toggle.treesitter():map("<leader>ut")
	-- snacks.toggle.option("background", { off = "light", on = "dark" , name = "dark background" }):map("<leader>ub")
	snacks.toggle.dim():map("<leader>ud")
	snacks.toggle.zen():map("<leader>uz")
	snacks.toggle.zoom():map("<leader>uz")

	-- git
	map("n", "<leader>gg", function()
		snacks.lazygit()
	end, { desc = "lazygit" })
	map("n", "<leader>gl", function()
		snacks.picker.git_log()
	end, { desc = "git log" })
	map("n", "<leader>gb", function()
		snacks.picker.git_log_line()
	end, { desc = "git blame line" })
	map("n", "<leader>gf", function()
		snacks.picker.git_log_file()
	end, { desc = "git file history" })
	map({ "n", "x" }, "<leader>gb", function()
		snacks.gitbrowse()
	end, { desc = "git browse (open)" })
end
