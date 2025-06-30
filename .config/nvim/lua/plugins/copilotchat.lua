return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
    opts = {
      file_types = { "markdown", "copilot-chat" },
    },
    ft = { "markdown", "copilot-chat" },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    cmd = {
      "CopilotChat",
      "CopilotChatToggle",
      "CopilotChatReset",
      "CopilotChatFix",
      "CopilotChatExplain",
      "CopilotChatTests",
      "CopilotChatReview",
      "CopilotChatRefactor",
      "CopilotChatModels",
      "CopilotChatSave",
      "CopilotChatLoad",
    },
    opts = {
      -- model = "claude-sonnet-4",
      highlight_headers = false,
      separator = "---",
      error_header = "> [!ERROR] Error",
    },
  },
}
