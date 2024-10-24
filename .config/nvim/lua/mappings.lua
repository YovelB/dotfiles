require "nvchad.mappings"

local map = vim.keymap.set

map("n", "<A-q>", "<ESC>:qa<CR>", { desc = "general Quit vim", nowait = true })
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<C-a>", 'ggVG"+y<ESC>', { desc = "selection Select all" })

map("n", "<leader>lt", function()
  if next(vim.lsp.get_clients()) ~= nil then
    vim.cmd "LspStop"
    vim.notify "LSP stopped"
  else
    vim.cmd "LspStart"
    vim.notify "LSP started"
  end
end, { desc = "Toggle LSP" })

-- Copilot mappings
-- helper method to toggle copilot suggestions
local function toggle_copilot_suggestions()
  if vim.b.copilot_suggestion_auto_trigger then
    vim.b.copilot_suggestion_auto_trigger = false
    require("copilot.suggestion").dismiss()
    vim.notify "Copilot suggestions disabled"
  else
    vim.b.copilot_suggestion_auto_trigger = true
    vim.notify "Copilot suggestions enabled"
  end
end

-- Toggle Copilot suggestions with toggle_copilot_suggestions helper method
map("n", "<M-c>", toggle_copilot_suggestions, { desc = "Toggle Copilot suggestions" })
map("i", "<M-c>", function()
  toggle_copilot_suggestions()
  -- Return empty string to not insert anything in insert mode
  return ""
end, { desc = "Toggle Copilot suggestions", expr = true })

-- CopilotChat mappings
-- Quick chat with buffer context
map("n", "<leader>cq", function()
  local input = vim.fn.input "Quick Chat: "
  if input ~= "" then
    require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
  end
end, { desc = "CopilotChat - Quick chat" })

-- Show help actions using telescope
map("n", "<leader>ch", function()
  local actions = require "CopilotChat.actions"
  require("CopilotChat.integrations.telescope").pick(actions.help_actions())
end, { desc = "CopilotChat - Help actions with telescope" })

-- Show prompts actions using telescope
map("n", "<leader>cp", function()
  local actions = require "CopilotChat.actions"
  require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
end, { desc = "CopilotChat - Prompt actions with telescope" })

-- Common actions (normal mode)
map("n", "<leader>cs", "<cmd>CopilotChatToggle<cr>", { desc = "CopilotChat - Toggle split" })
map("n", "<leader>cf", "<cmd>CopilotChatFix<cr>", { desc = "CopilotChat - Fix issue" })
map("n", "<leader>ce", "<cmd>CopilotChatExplain<cr>", { desc = "CopilotChat - Explain code" })
map("n", "<leader>ct", "<cmd>CopilotChatTests<cr>", { desc = "CopilotChat - Generate tests" })
map("n", "<leader>cr", "<cmd>CopilotChatReview<cr>", { desc = "CopilotChat - Review code" })

-- Visual mode mappings
map("v", "<leader>cq", ":CopilotChatVisual ", { desc = "CopilotChat - Quick chat with selection" })
map("v", "<leader>cr", ":CopilotChatRefactor<cr>", { desc = "CopilotChat - Refactor selection" })
map("v", "<leader>ce", ":CopilotChatExplain<cr>", { desc = "CopilotChat - Explain selection" })
