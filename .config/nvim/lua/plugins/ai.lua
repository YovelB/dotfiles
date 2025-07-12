return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "BufReadPost",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<M-f>",
            accept_word = "<M-w>",
            accept_line = "<M-l>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        panel = { enabled = false },
        logger = {
          -- or `OFF` instead of `ERROR` if you want to disable logging as a whole
          print_log_level = vim.log.levels.ERROR,
        },
      })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    build = "make tiktoken",
    opts = {
      model = "gpt-4o",
      auto_insert_mode = false,
      window = {
        width = 0.5,
      },
    },
    keys = {
      -- disable unused mapping
      { "<leader>aa", false, mode = { "n", "v" } },
      { "<leader>ax", false, mode = { "n", "v" } },
      -- adding new mappings
      {
        "<leader>as",
        function()
          return require("CopilotChat").toggle()
        end,
        desc = "Toggle (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>af",
        function()
          require("CopilotChat").toggle()
          vim.schedule(function()
            vim.cmd("wincmd |")
          end)
        end,
        desc = "Toggle (CopilotChat) fullscreen",
        mode = { "n", "v" },
      },
    },
    -- You can also add dependencies, event triggers, etc.
  },
}
