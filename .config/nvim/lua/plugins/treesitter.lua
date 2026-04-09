-- treesitter - syntex engine
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" }, { confirm = false })
-- textobjects extension - select, move, swap, and peak support
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" }, { confirm = false })

local ok_ts, configs = pcall(require, "nvim-treesitter.configs")
if not ok_ts then
  return
end

configs.setup({
  ensure_installed = {
    "c",
    "cpp",
    "cmake",
    "devicetree",
    "make",
    "kconfig",
    "ini",
    "asm",
    "python",
    "matlab",
    "bash",
    "json",
    "yaml",
    "gitcommit",
    "gitignore",
    "markdown",
    "latex",
    "typst",
    "regex",
    "lua",
    "vim",
    "vimdoc",
  },
  -- automatically install missing parsers when entering a buffer
  auto_install = true,

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },

  indent = {
    enable = true,
    disable = { "python", "yaml", "markdown" },
  },

  -- textobjects configuration
  textobjects = {
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
  },
})

-- disable the built in ftplugin mappings
vim.g.no_plugin_maps = true

-- enable treesitter folding globally
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

local ok_to, to_move = pcall(require, "nvim-treesitter-textobjects.move")
local ok_sel, to_select = pcall(require, "nvim-treesitter-textobjects.select")

if ok_to and ok_sel then
  local map = vim.keymap.set

  -- Lazyvim selection
  map({ "x", "o" }, "af", function()
    to_select.select_textobject("@function.outer", "textobjects")
  end)
  map({ "x", "o" }, "if", function()
    to_select.select_textobject("@function.inner", "textobjects")
  end)
  map({ "x", "o" }, "ac", function()
    to_select.select_textobject("@class.outer", "textobjects")
  end)
  map({ "x", "o" }, "ic", function()
    to_select.select_textobject("@class.inner", "textobjects")
  end)
  map({ "x", "o" }, "aa", function()
    to_select.select_textobject("@parameter.outer", "textobjects")
  end)
  map({ "x", "o" }, "ia", function()
    to_select.select_textobject("@parameter.inner", "textobjects")
  end)

  -- Lazyvim movement
  map({ "n", "x", "o" }, "]f", function()
    to_move.goto_next_start("@function.outer", "textobjects")
  end)
  map({ "n", "x", "o" }, "[f", function()
    to_move.goto_previous_start("@function.outer", "textobjects")
  end)
  map({ "n", "x", "o" }, "]a", function()
    to_move.goto_next_start("@parameter.inner", "textobjects")
  end)
  map({ "n", "x", "o" }, "[a", function()
    to_move.goto_previous_start("@parameter.inner", "textobjects")
  end)

  -- class movements with git diff fallback
  map({ "n", "x", "o" }, "]c", function()
    if vim.wo.diff then
      vim.cmd("normal! ]c")
    else
      to_move.goto_next_start("@class.outer", "textobjects")
    end
  end)
  map({ "n", "x", "o" }, "[c", function()
    if vim.wo.diff then
      vim.cmd("normal! [c")
    else
      to_move.goto_previous_start("@class.outer", "textobjects")
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
