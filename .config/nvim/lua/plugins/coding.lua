return {
  -- fun coding stats and achievements
  {
    "gisketch/triforce.nvim",
    dependencies = {
      "nvzone/volt",
    },
    config = function()
      require("triforce").setup({
        -- Optional: Add your configuration here
        keymap = {
          show_profile = "<leader>tp", -- Open profile with <leader>tp
        },
      })
    end,
  },
  -- nice UI for showing key strokes
  {
    "nvzone/showkeys",
    cmd = "ShowkeysToggle",
    opts = { position = "top-right" },
    keys = {
      { "<leader>uk", "<cmd>ShowkeysToggle<cr>", desc = "Toggle Showkeys" },
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
