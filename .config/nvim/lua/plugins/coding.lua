return {
  -- fun coding stats and achievements
  {
    "grzegorzszczepanek/gamify.nvim",
    lazy = false,
    config = function()
      require("gamify")
    end,
  },
  -- overrides the delete operations to actually just delete and not affect the current yank.
  {
    "gbprod/cutlass.nvim",
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
