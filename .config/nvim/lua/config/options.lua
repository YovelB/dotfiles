local opt = vim.opt
local g = vim.g

-- ===============================
-- globals
-- ===============================
g.markdown_recommended_style = 0 -- fix markdown indentation settings
g.trouble_lualine = true -- show trouble diagnostics in lualine
g.loaded_ruby_provider = 0 -- disable unused providers
g.loaded_perl_provider = 0
g.loaded_python3_provider = 0

-- plugin overrides
g.vimtex_quickfix_autoclose_after_keystrokes = 2
g.typst_watch_autoclose_after_keystrokes = 2

-- ===============================
-- appearance and UI
-- ===============================
opt.termguicolors = true
opt.sessionoptions = { "buffers", "curdir", "winsize", "help", "globals", "skiprtp", "folds" }
opt.showtabline = 0 -- hide the tabline
opt.number = true
opt.relativenumber = true
opt.showmode = false -- dont show mode since we have a statusline
opt.signcolumn = "yes" -- always show signcolumn to prevent text shifting
opt.cursorline = true -- highlight the current line
opt.laststatus = 3 -- global statusline (for lualine)
opt.cmdheight = 1 -- keep at 1 for noice.nvim to work properly
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ", -- hides the '~' at the end of buffers
}
-- fix STM32CubeIDE modeline parsing errors
opt.modeline = false
opt.modelines = 0

-- ===============================
-- behavior
-- ===============================
opt.mouse = "a" -- enable mouse mode
-- smart clipboard: only use system clipboard if not connected via SSH
opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"
opt.undofile = true -- save undo history
opt.undolevels = 10000 -- massive undo history
opt.updatetime = 200 -- decrease update time
opt.timeoutlen = 300 -- time to wait for a mapped sequence to complete
opt.confirm = true -- confirm to save changes before exiting modified buffer
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- ===============================
-- windows and splits
-- ===============================
opt.splitright = true -- put new windows right of current
opt.splitbelow = true -- put new windows below current
opt.splitkeep = "screen" -- keep text from jumping when opening a split
opt.winminwidth = 5 -- min window width
opt.winminheight = 0 -- allow windows to squash vertically

-- ===============================
-- search and moving
-- ===============================
opt.ignorecase = true -- ignore case
opt.smartcase = true -- don't ignore case with capitals
opt.inccommand = "split" -- preview incremental substitutions in a split
opt.hlsearch = true -- highlight search results
opt.scrolloff = 4 -- lines of context above/below cursor
opt.sidescrolloff = 8 -- columns of context to the left/right
opt.jumpoptions = "view" -- preserve view while jumping
opt.smoothscroll = true -- native smooth scrolling
opt.virtualedit = "block" -- allow cursor to move where there is no text in visual block mode

-- ===============================
-- formatting and indentation
-- ===============================
opt.wrap = false -- disable line wrap
opt.linebreak = true -- wrap lines at convenient points (if wrap is enabled)
opt.breakindent = true -- enable break indent
opt.tabstop = 2 -- number of spaces tabs count for
opt.shiftwidth = 2 -- size of an indent
opt.shiftround = true -- round indent
opt.expandtab = true -- use spaces instead of tabs
opt.smartindent = true -- insert indents automatically
opt.formatoptions = "jcroqlnt" -- native text formatting behavior

-- ===============================
-- autocomplete and grep
-- ===============================
opt.completeopt = "menu,menuone,noselect"
opt.pumblend = 10 -- popup menu transparency
opt.pumheight = 10 -- maximum number of entries in a popup
opt.wildmode = "longest:full,full" -- command line completion mode
opt.grepprg = "rg --vimgrep" -- use ripgrep natively
opt.grepformat = "%f:%l:%c:%m"

-- ===============================
-- folds and conceal
-- ===============================
opt.foldlevel = 99 -- set highest foldlevel
opt.foldlevelstart = 99 -- start with all folds open
opt.foldenable = false -- disabled to prevent auto-folding on paste
opt.foldmethod = "indent" -- fallback fold method
opt.conceallevel = 2 -- hide markdown/typst markup (like **bold**)

-- hebrew RTL support
opt.termbidi = true -- enable bidirectional text support
opt.keymap = "hebrew" -- set internal nvim keymap to hebrew
opt.iminsert = 0 -- default to english in insert mode
opt.imsearch = 0 -- default to english in search mode
