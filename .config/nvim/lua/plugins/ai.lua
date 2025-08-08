local prompts = {
  -- code related prompts
  Explain = "Please explain how the following code works.",
  Review = "Please review the following code and provide suggestions for improvement.",
  Tests = "Please generate unit tests for the selected code.",
  Refactor = "Please refactor the following code to improve its clarity and readability.",
  FixCode = "Please fix the following code to make it work as intended.",
  FixError = "Please explain the error in the following text and provide a solution.",
  BetterNamings = "Please provide better names for the following variables and functions.",
  Documentation = "Please provide documentation for the following code.",
  -- text related prompts
  Summarize = "Please summarize the following text.",
  Spelling = "Please correct any grammar and spelling errors in the following text.",
  Wording = "Please improve the grammar and wording of the following text.",
  Concise = "Please rewrite the following text to make it more concise.",
}

return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = {
        keymap = {
          accept_word = "<M-w>",
          accept_line = "<M-l>",
        },
      },
    },
  },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    build = "make tiktoken",
    opts = {
      model = "gpt-5",
      auto_insert_mode = false,
      prompts = prompts,
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
      {
        "<leader>ap",
        function()
          require("CopilotChat").select_prompt({ context = { "buffers" } })
        end,
        desc = "Trigger prompt (CopilotChat)",
        mode = { "n", "v" },
      },
      -- Generate commit message based on the git diff
      {
        "<leader>am",
        "<cmd>CopilotChatCommit<cr>",
        desc = "CopilotChat - Generate commit message for all changes",
        mode = { "n", "v" },
      },
      -- fix the issue with diagnostic
      { "<leader>af", "<cmd>CopilotChatFixError<cr>", desc = "CopilotChat - Fix Diagnostic", mode = { "v" } },
      -- clear buffer and chat history
      { "<leader>al", "<cmd>CopilotChatReset<cr>", desc = "CopilotChat - Clear buffer and chat history" },
      -- copilot chat models
      { "<leader>a?", "<cmd>CopilotChatModels<cr>", desc = "CopilotChat - Select Models" },
      -- copilot chat agents
      { "<leader>aa", "<cmd>CopilotChatAgents<cr>", desc = "CopilotChat - Select Agents" },
    },
    -- You can also add dependencies, event triggers, etc.
  },
}
