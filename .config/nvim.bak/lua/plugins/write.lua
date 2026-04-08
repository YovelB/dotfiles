return {
  -- add ltex_extra plugin
  -- {
  --   "barreiroleo/ltex_extra.nvim",
  --   ft = { "markdown", "text", "tex", "gitcommit" },
  -- },
  -- configure ltex LSP
  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = function(_, opts)
  --     opts.servers = opts.servers or {}
  --     opts.servers.ltex = {
  --       on_attach = function(_, bufnr)
  --         require("ltex_extra").setup({
  --           path = vim.fn.expand("~") .. "/.config/nvim/ltex",
  --           load_langs = { "en-US" },
  --         })
  --
  --         -- keymaps for ltex (only in buffers with ltex active)
  --         local map = vim.keymap.set
  --         map(
  --           "n",
  --           "<leader>wwd",
  --           "<cmd>LtexLangAddToDictionary<cr>",
  --           { buffer = bufnr, desc = "Add word to dictionary" }
  --         )
  --         map("n", "<leader>wwr", "<cmd>LtexLangDisableRule<cr>", { buffer = bufnr, desc = "Disable ltex rule" })
  --       end,
  --       settings = {
  --         ltex = {
  --           language = "en-US",
  --           additionalRules = {
  --             enablePickyRules = true,
  --           },
  --         },
  --       },
  --       filetypes = { "markdown", "text", "tex", "gitcommit" },
  --       flags = {
  --         debounce_text_changes = 300,
  --       },
  --     }
  --   end,
  -- },
  -- sentence text objects
  {
    "preservim/vim-textobj-sentence",
    dependencies = { "kana/vim-textobj-user" },
    ft = { "markdown", "text", "gitcommit", "tex" },
  },

  -- wordy (highlights weak writing)
  {
    "preservim/vim-wordy",
    ft = { "markdown", "text", "gitcommit", "tex" },
    keys = {
      { "<leader>www", "<cmd>Wordy weak<cr>", desc = "Check weak words" },
      { "<leader>wwp", "<cmd>Wordy passive-voice<cr>", desc = "Check passive voice" },
      { "<leader>wwW", "<cmd>Wordy weasel<cr>", desc = "Check weasel words" },
      { "<leader>wwo", "<cmd>NoWordy<cr>", desc = "Turn off wordy" },
    },
  },
  -- more spelling words added to dict
  {
    "psliwka/vim-dirtytalk",
    build = ":DirtytalkUpdate",
    config = function()
      vim.opt.spelllang = { "en", "programming" }
    end,
  },
  {
    "ficcdaf/academic.nvim",
    build = ":AcademicBuild",
  },
}
