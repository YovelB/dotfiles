-- DEPENDENCIES:
-- this configuration assumes you have the following tools installed on your
-- system:
--    `git` - for vim builtin package manager. (see `:h vim.pack`)
--    `ripgrep` - for fuzzy finding
--    clipboard tool: xclip/xsel/win32yank - for clipboard sharing between OS and neovim (see `h: clipboard-tool`)
--    a nerdfont (ensure the terminal running neovim is using it)

vim.g.start_time = vim.uv.hrtime()

-- must happen before plugins are loaded
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- settings
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- plugins
require("plugins.theme") -- tokyo night
require("plugins.treesitter") -- syntax engine
require("plugins.ui") -- icons, lualine, bufferline, dashboard
require("plugins.snacks") -- explorer, picker, image
require("plugins.editor") -- pairs, surround, git, trouble
require("plugins.lsp") -- mason, LSPs, formatting, linting, blink
require("plugins.dap") -- debugger

-- uncomment to enable automatic plugin updates
-- vim.pack.update()
