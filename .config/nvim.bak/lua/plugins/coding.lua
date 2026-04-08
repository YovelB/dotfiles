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
        custom_languages = { typst = { icon = "𝐭", name = "Typst" } },
        ignore_ft = { "conf" }, -- tex is another option
      })
    end,
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
      { "<leader>j", "<cmd>TSJToggle<cr>", desc = "Join Toggle" },
    },
    opts = { use_default_keymaps = false, max_join_length = 150 },
  },
  -- showing the diff whenever recovering a file
  {
    { "chrisbra/recover.vim" },
  },
}
