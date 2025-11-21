return {
  -- fun coding stats and achievements
  {
    "gisketch/triforce.nvim",
    dependencies = {
      "nvzone/volt",
    },
    config = function()
      require("triforce").setup({
        keymap = {
          show_profile = "<leader>tp",
        },
      })
    end,
  },
  {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
    keys = {
      { "<leader>ht", "<cmd>Hardtime toggle<cr>", desc = "Hardtime toggle" },
      { "<leader>hr", "<cmd>Hardtime report<cr>", desc = "Hardtime report" },
    },
  },
  -- nice UI for showing key strokes
  {
    "nvzone/showkeys",
    cmd = "ShowkeysToggle",
    opts = { position = "top-right" },
    keys = {
      { "<leader>uk", "<cmd>ShowkeysToggle<cr>", desc = "Showkeys toggle" },
    },
  },
  -- for splitting and joining code blocks
  {
    "Wansmer/treesj",
    keys = {
      { "<C-j>", "<cmd>TSJToggle<cr>", desc = "Join Toggle" },
    },
    opts = { use_default_keymaps = false, max_join_length = 150 },
  },
  -- showing the diff whenever recovering a file
  {
    { "chrisbra/recover.vim" },
  },
}
