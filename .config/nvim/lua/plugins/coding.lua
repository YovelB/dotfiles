return {
  -- devdocs for extended docs
  {
    "maskudo/devdocs.nvim",
    lazy = false,
    dependencies = {
      "folke/snacks.nvim",
    },
    cmd = { "DevDocs" },
    keys = {
      {
        "<leader>ho",
        mode = "n",
        "<cmd>DevDocs get<cr>",
        desc = "Get Devdocs",
      },
      {
        "<leader>hi",
        mode = "n",
        "<cmd>DevDocs install<cr>",
        desc = "Install Devdocs",
      },
      {
        "<leader>hv",
        mode = "n",
        function()
          local devdocs = require("devdocs")
          local installedDocs = devdocs.GetInstalledDocs()
          vim.ui.select(installedDocs, {}, function(selected)
            if not selected then
              return
            end
            local docDir = devdocs.GetDocDir(selected)
            -- prettify the filename as you wish
            Snacks.picker.files({ cwd = docDir })
          end)
        end,
        desc = "Get Devdocs",
      },
      {
        "<leader>hd",
        mode = "n",
        "<cmd>DevDocs delete<cr>",
        desc = "Delete Devdoc",
      },
    },
    opts = {
      ensure_installed = {
        -- some docs such as lua require version number along with the language name
        -- check `DevDocs install` to view the actual names of the docs
        "lua~5.4",
        "c",
        "cpp",
        "cmake",
        "latex",
        "zsh",
      },
    },
  },
  -- fun coding stats and achievements
  {
    "gisketch/triforce.nvim",
    dependencies = {
      "nvzone/volt",
    },
    config = function()
      require("triforce").setup({
        keymap = {
          show_profile = "<leader>otp",
        },
      })
    end,
  },
  -- training the right movement in vim
  {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
    keys = {
      { "<leader>oht", "<cmd>Hardtime toggle<cr>", desc = "Hardtime toggle" },
      { "<leader>ohr", "<cmd>Hardtime report<cr>", desc = "Hardtime report" },
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
