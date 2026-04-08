-- offical nvim tree sitter
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" }, { confirm = false })
-- Textobjects extension - select, move, swap, and peak support
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" }, { confirm = false })

local parsers = {
	-- embedded
	"c",
	"cpp",
	"cmake",
	"devicetree",
	"make",
	"kconfig",
	"ini",
	"asm",
	-- scripting langs
	"python",
	"matlab",
	"bash",
	"json",
	"yaml",
	-- version control
	"gitcommit",
	"gitignore",
	-- docs
	"markdown",
	"latex",
	"typst",
	-- essential
	"regex",
	"lua",
	"vim",
	"vimdoc",
}

local ok_ts, treesitter = pcall(require, "nvim-treesitter")
if ok_ts then
	treesitter.setup({})
	-- check tree sitter CLI is availiable before installing the parsers
	if vim.fn.executable("tree-sitter") == 1 then
		treesitter.install(parsers)
	else
		vim.api.nvim_echo({
			{ "tree-sitter CLI not found. cant install parsers.", "ErrorMsg" },
		}, true, {})
	end
end

-- autocmd to handle highlighting, folding, and indents per buffer
local highlight = function(bufnr, lang)
	if not vim.treesitter.language.add(lang) then
		return vim.notify(string.format("Treesitter cannot load parser for language %s", lang), vim.log.levels.INFO)
	end
	vim.treesitter.start(bufnr)
end

vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		local ft, bt, buf = vim.bo.filetype, vim.bo.buftype, args.buf
		if bt ~= "" or not ok_ts then
			return
		end

		-- folds
		vim.opt_local.foldmethod = "expr"
		vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"

		vim.schedule(function()
			if vim.fn.mode() ~= "t" then
				vim.cmd("silent! normal! zR")
			end
		end)

		-- indents
		if not vim.tbl_contains({ "python", "yaml", "markdown" }, ft) then
			vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
		end

		-- parsers and highlighting
		if vim.fn.executable("tree-sitter") ~= 1 or not vim.treesitter.language.get_lang(ft) then
			return
		end
		if vim.list_contains(treesitter.get_installed(), ft) then
			highlight(buf, ft)
		elseif vim.list_contains(treesitter.get_available(), ft) then
			vim.cmd("TSInstall " .. ft)
		end
	end,
})

-- Textobjects config
-- disable the built in ftplugin mappings as recommended by the plugin documentation
vim.g.no_plugin_maps = true

local ok_to, _ = pcall(require, "nvim-treesitter-textobjects")
if ok_to then
	local to_move = require("nvim-treesitter-textobjects.move")
	local to_select = require("nvim-treesitter-textobjects.select")
	-- local to_swap = require("nvim-treesitter-textobjects.swap")

	-- Configuration for textobjects
	require("nvim-treesitter-textobjects").setup({
		select = {
			lookahead = true,
			selection_modes = {
				["@parameter.outer"] = "v", -- charwise
				["@function.outer"] = "V", -- linewise
			},
		},
		move = {
			set_jumps = true,
		},
	})

	-- Lazyvim selection
	vim.keymap.set({ "x", "o" }, "af", function()
		to_select.select_textobject("@function.outer", "textobjects")
	end)
	vim.keymap.set({ "x", "o" }, "if", function()
		to_select.select_textobject("@function.inner", "textobjects")
	end)
	vim.keymap.set({ "x", "o" }, "ac", function()
		to_select.select_textobject("@class.outer", "textobjects")
	end)
	vim.keymap.set({ "x", "o" }, "ic", function()
		to_select.select_textobject("@class.inner", "textobjects")
	end)
	vim.keymap.set({ "x", "o" }, "aa", function()
		to_select.select_textobject("@parameter.outer", "textobjects")
	end)
	vim.keymap.set({ "x", "o" }, "ia", function()
		to_select.select_textobject("@parameter.inner", "textobjects")
	end)

	-- Lazyvim movement
	vim.keymap.set({ "n", "x", "o" }, "]f", function()
		to_move.goto_next_start("@function.outer", "textobjects")
	end)
	vim.keymap.set({ "n", "x", "o" }, "]c", function()
		to_move.goto_next_start("@class.outer", "textobjects")
	end)
	vim.keymap.set({ "n", "x", "o" }, "]a", function()
		to_move.goto_next_start("@parameter.inner", "textobjects")
	end)
	vim.keymap.set({ "n", "x", "o" }, "]F", function()
		to_move.goto_next_end("@function.outer", "textobjects")
	end)
	vim.keymap.set({ "n", "x", "o" }, "]C", function()
		to_move.goto_next_end("@class.outer", "textobjects")
	end)
	vim.keymap.set({ "n", "x", "o" }, "]A", function()
		to_move.goto_next_end("@parameter.inner", "textobjects")
	end)

	vim.keymap.set({ "n", "x", "o" }, "[f", function()
		to_move.goto_previous_start("@function.outer", "textobjects")
	end)
	vim.keymap.set({ "n", "x", "o" }, "[c", function()
		to_move.goto_previous_start("@class.outer", "textobjects")
	end)
	vim.keymap.set({ "n", "x", "o" }, "[a", function()
		to_move.goto_previous_start("@parameter.inner", "textobjects")
	end)
	vim.keymap.set({ "n", "x", "o" }, "[F", function()
		to_move.goto_previous_end("@function.outer", "textobjects")
	end)
	vim.keymap.set({ "n", "x", "o" }, "[C", function()
		to_move.goto_previous_end("@class.outer", "textobjects")
	end)
	vim.keymap.set({ "n", "x", "o" }, "[A", function()
		to_move.goto_previous_end("@parameter.inner", "textobjects")
	end)

	-- class movements with git diff fallback
	vim.keymap.set({ "n", "x", "o" }, "]c", function()
		if vim.wo.diff then
			vim.cmd("normal! ]c")
		else
			to_move.goto_next_start("@class.outer", "textobjects")
		end
	end)
	vim.keymap.set({ "n", "x", "o" }, "]C", function()
		if vim.wo.diff then
			vim.cmd("normal! ]C")
		else
			to_move.goto_next_end("@class.outer", "textobjects")
		end
	end)
	vim.keymap.set({ "n", "x", "o" }, "[c", function()
		if vim.wo.diff then
			vim.cmd("normal! [c")
		else
			to_move.goto_previous_start("@class.outer", "textobjects")
		end
	end)
	vim.keymap.set({ "n", "x", "o" }, "[C", function()
		if vim.wo.diff then
			vim.cmd("normal! [C")
		else
			to_move.goto_previous_end("@class.outer", "textobjects")
		end
	end)

	-- Lazyvim swap
	-- vim.keymap.set("n", "<leader>a", function()
	-- 	to_swap.swap_next("@parameter.inner")
	-- end)
	-- vim.keymap.set("n", "<leader>A", function()
	-- 	to_swap.swap_previous("@parameter.outer")
	-- end)
end
