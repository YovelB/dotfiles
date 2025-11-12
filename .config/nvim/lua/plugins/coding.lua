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
  -- for splitting and joining code blocks
  {
    "Wansmer/treesj",
    keys = {
      { "<C-j>", "<cmd>TSJToggle<cr>", desc = "Join Toggle" },
    },
    opts = { use_default_keymaps = false, max_join_length = 150 },
  },
}
