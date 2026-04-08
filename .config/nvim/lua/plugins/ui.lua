-- mini.icons - icon provider
vim.pack.add({ "https://github.com/echasnovski/mini.icons" }, { confirm = false })

local ok_icons, mini_icons = pcall(require, "mini.icons")
if ok_icons then
	mini_icons.setup()
	mini_icons.mock_nvim_web_devicons() -- tells older plugins to use mini.icons
end

-- bufferline - fancy tabs
vim.pack.add({ "https://github.com/akinsho/bufferline.nvim" }, { confirm = false })

local ok_bl, bufferline = pcall(require, "bufferline")
if ok_bl then
	bufferline.setup({
		options = {
			diagnostics = "nvim_lsp",
			always_show_bufferline = false,
			offsets = {
				{ filetype = "neo-tree", text = "File Explorer", highlight = "Directory", text_align = "left" },
			},
		},
	})

	-- keymaps
	local map = vim.keymap.set
	map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "prev buffer" })
	map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "next buffer" })
	map("n", "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", { desc = "toggle pin" })
	map("n", "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", { desc = "delete non-pinned buffers" })
end

-- noice - replaces UI for messages, cmdline and popmenus
vim.pack.add({ "https://github.com/MunifTanjim/nui.nvim", "https://github.com/folke/noice.nvim" }, { confirm = false })
local ok_noice, noice = pcall(require, "noice")
if ok_noice then
	noice.setup({
		lsp = {
			-- override markdown rendering so that cmp and other plugins use Treesitter
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
			},
		},
		routes = {
			{
				filter = {
					event = "msg_show",
					any = {
						{ find = "%d+L, %d+B" },
						{ find = "; after #%d+" },
						{ find = "; before #%d+" },
					},
				},
				view = "mini", -- sends "File Saved" messages to a tiny corner popup
			},
		},
		presets = {
			bottom_search = true, -- use a classic bottom cmdline for search (/)
			command_palette = true, -- centers your command line (:)
			long_message_to_split = true, -- long messages will be sent to a split
			inc_rename = false, -- enables an input dialog for inc rename.nvim
			lsp_doc_border = false, -- add a border to hover docs and signature help
		},
	})

	local map = vim.keymap.set
	-- map("c", "<S-Enter>", function()
	-- 	noice.redirect(vim.fn.getcmdline())
	-- end, { desc = "Redirect Cmdline" })
	-- map("n", "<leader>snl", function()
	-- 	noice.cmd("last")
	-- end, { desc = "Noice Last Message" })
	map("n", "<leader>snh", function()
		noice.cmd("history")
	end, { desc = "Noice History" })
	map("n", "<leader>sna", function()
		noice.cmd("all")
	end, { desc = "Noice All" })
	map("n", "<leader>snd", function()
		noice.cmd("dismiss")
	end, { desc = "Dismiss All" })
end

-- presistance
vim.pack.add({ "https://github.com/folke/persistence.nvim" }, { confirm = false })

local ok_p, persistence = pcall(require, "persistence")
if ok_p then
	persistence.setup({})

	local map = vim.keymap.set
	map("n", "<leader>qs", persistence.load, { desc = "Restore Session" })
	map("n", "<leader>qS", persistence.select, { desc = "Select Session" })
	map("n", "<leader>ql", function()
		persistence.load({ last = true })
	end, { desc = "Restore Last Session" })
	map("n", "<leader>qd", persistence.stop, { desc = "Don't Save Current Session" })
end

-- dashboard
vim.pack.add({ "https://github.com/nvimdev/dashboard-nvim" }, { confirm = false })

local ok_d, dashboard = pcall(require, "dashboard")
if not ok_d then
	return
end
local locked_time = nil

local logo = {
	[[                                                                   ]],
	[[      ████ ██████           █████      ██                    ]],
	[[     ███████████             █████                            ]],
	[[     █████████ ███████████████████ ███   ███████████  ]],
	[[    █████████  ███    █████████████ █████ ██████████████  ]],
	[[   █████████ ██████████ █████████ █████ █████ ████ █████  ]],
	[[ ███████████ ███    ███ █████████ █████ █████ ████ █████ ]],
	[[██████  █████████████████████ ████ █████ █████ ████ ██████]],
}
local header = {}
-- empty lines above and below logo
for _ = 1, 4 do
	table.insert(header, "")
end
for _, line in ipairs(logo) do
	table.insert(header, line)
end
for _ = 1, 5 do
	table.insert(header, "")
end

dashboard.setup({
	theme = "doom",
	-- change_to_vcs_root = true,

	config = {
		header = header,
		center = {
			{
				action = "lua Snacks.picker.files()",
				desc = " Find File",
				icon = " ",
				key = "f",
			},
			{
				action = "ene | startinsert",
				desc = " New File",
				icon = " ",
				key = "n",
			},
			{
				action = "lua Snacks.picker.grep()",
				desc = " Find Text",
				icon = " ",
				key = "g",
			},
			{
				action = "lua Snacks.picker.recent()",
				desc = " Recent Files",
				icon = " ",
				key = "r",
			},
			{
				action = "lua Snacks.picker.projects()",
				desc = " Projects",
				icon = "󰉋 ",
				key = "p",
			},
			{
				action = 'lua require("persistence").load()',
				desc = " Restore Session",
				icon = " ",
				key = "s",
			},
			{
				action = 'lua Snacks.picker.files({cwd = vim.fn.stdpath("config")})',
				desc = " Config",
				icon = " ",
				key = "c",
			},
		},
		footer = function()
			if not locked_time then
				locked_time = math.floor((vim.uv.hrtime() - vim.g.start_time) / 1e6 + 0.5)
			end
			local v = vim.version()
			local version_str = string.format("v%d.%d.%d", v.major, v.minor, v.patch)
			return { "", "⚡Neovim " .. version_str .. " loaded in " .. locked_time .. " ms" }
		end,
	},
})

-- format buttons to be evenly spaced
local opts = require("dashboard.theme.doom")
if opts and opts.center then
	for _, button in ipairs(opts.center) do
		button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
		button.key_format = "  %s"
	end
end

-- hidden shortcuts
vim.api.nvim_create_autocmd("FileType", {
	pattern = "dashboard",
	callback = function()
		vim.keymap.set("n", "q", "<cmd>qa<cr>", { buffer = true, silent = true, desc = "Quit" })
	end,
})

-- lualine - status bar at the bottom
vim.pack.add({ "https://github.com/nvim-lualine/lualine.nvim" }, { confirm = false })

local ok_ll, lualine = pcall(require, "lualine")
if ok_ll then
	-- hardcoded icons to replace LazyVim.config.icons
	local icons = {
		diagnostics = { Error = " ", Warn = " ", Info = " ", Hint = " " },
		git = { added = " ", modified = " ", removed = " " },
	}

	local opts_l = {
		options = {
			theme = "tokyonight",
			globalstatus = true,
			disabled_filetypes = { statusline = { "dashboard", "alpha", "snacks_dashboard" } },
			-- Your custom angular separators!
			section_separators = { left = "", right = "" },
			component_separators = { left = "╱", right = "╱" },
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = {
				function()
					-- cache git root to avoid repeated system calls
					if not vim.b._git_root_cache then
						local git_root = vim.fn
							.system("git -C " .. vim.fn.expand("%:p:h") .. " rev-parse --show-toplevel 2>/dev/null")
							:gsub("\n", "")
						if vim.v.shell_error == 0 and git_root ~= "" then
							vim.b._git_root_cache = " " .. vim.fn.fnamemodify(git_root, ":t")
						else
							vim.b._git_root_cache = " " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
						end
					end
					return vim.b._git_root_cache
				end,
			},
			lualine_c = {
				-- built in lualine path formatter (1 = relative path, 2 = absolute, 3 = absolute with ~)
				{ "filename", path = 1 },
			},
			lualine_x = {
				{
					"diagnostics",
					symbols = {
						error = icons.diagnostics.Error,
						warn = icons.diagnostics.Warn,
						info = icons.diagnostics.Info,
						hint = icons.diagnostics.Hint,
					},
				},
				{
					"diff",
					symbols = {
						added = icons.git.added,
						modified = icons.git.modified,
						removed = icons.git.removed,
					},
					source = function()
						local gitsigns = vim.b.gitsigns_status_dict
						if gitsigns then
							return { added = gitsigns.added, modified = gitsigns.changed, removed = gitsigns.removed }
						end
					end,
				},
				-- Triforce icons
				function()
					local ok_tri, triforce = pcall(require, "triforce.lualine")
					if ok_tri then
						return triforce.level({ bar = { chars = { filled = "◆", empty = "◇" }, length = 5 } })
					end
					return ""
				end,
			},
			lualine_y = { "filetype" },
			lualine_z = {
				{ "progress", separator = " ", padding = { left = 1, right = 1 } },
				{ "branch", padding = { right = 1 } },
			},
		},
		extensions = { "neo-tree", "fzf" },
	}

	-- trouble symbols
	local ok_trouble, trouble = pcall(require, "trouble")
	if ok_trouble then
		local symbols = trouble.statusline({
			mode = "symbols",
			groups = {},
			title = false,
			filter = { range = true },
			format = "{kind_icon}{symbol.name:Normal}",
			hl_group = "lualine_c_normal",
		})
		table.insert(opts_l.sections.lualine_c, {
			symbols and symbols.get,
			cond = function()
				if vim.b.trouble_lualine == false or not symbols.has() then
					return false
				end
				local symbol_text = symbols.get()
				if not symbol_text then
					return false
				end
				return #symbol_text <= 120
			end,
		})
	end

	lualine.setup(opts_l)
end
