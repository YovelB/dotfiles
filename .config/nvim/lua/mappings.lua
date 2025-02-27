require "nvchad.mappings"

local map = vim.keymap.set

map("n", "<A-q>", "<ESC>:qa<CR>", { desc = "general Quit vim", nowait = true })
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<C-a>", "ggVG", { desc = "selection Select all" })

-- Nvim hide/show statusline
local function toggle_statusline()
  local current_status = vim.o.laststatus
  if current_status == 0 then
    vim.o.laststatus = 2
    vim.notify "Statusline shown"
  else
    vim.o.laststatus = 0
    vim.notify "Statusline hidden"
  end
end

map("n", "<leader>ts", toggle_statusline, { desc = "Toggle statusline" })

-- LSP hide/show diagnostics
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
local enabled = true
local function toggle_copilot()
  require("copilot.suggestion").dismiss()
  require("copilot.suggestion").toggle_auto_trigger()
  enabled = not enabled
  if enabled then
    vim.notify("Copilot enabled", vim.log.levels.INFO)
  else
    vim.notify("Copilot disabled", vim.log.levels.INFO)
  end
  return ""
end

-- Toggle Copilot suggestions
map("n", "<M-c>", toggle_copilot, { desc = "Toggle Copilot suggestions" })
map("i", "<M-c>", toggle_copilot, { desc = "Toggle Copilot suggestions", expr = true })

-- CopilotChat mappings
-- Chat operations
map("n", "<leader>cs", "<cmd>CopilotChatToggle<cr>", { desc = "Toggle Chat" })
map("n", "<leader>cf", "<cmd>CopilotChatToggle<cr><C-w>|", { desc = "Chat Fullscreen" })

-- Quick chat with context
map("n", "<leader>cq", function()
  local input = vim.fn.input "Quick Chat: "
  if input ~= "" then
    require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
  end
end, { desc = "Quick Chat" })

-- Actions (ca = copilot actions)
map("n", "<leader>ccf", "<cmd>CopilotChatFix<cr>", { desc = "Fix Code" })
map("n", "<leader>cct", "<cmd>CopilotChatTests<cr>", { desc = "Generate Tests" })
map("n", "<leader>ccr", "<cmd>CopilotChatReview<cr>", { desc = "Review Code" })
map("n", "<leader>cce", "<cmd>CopilotChatExplain<cr>", { desc = "Explain Code" })
map("n", "<leader>cm", "<cmd>CopilotChatModels<cr>", { desc = "Switch Chat Model" })

-- Save and Load chats
map("n", "<leader>cS", function()
  local name = vim.fn.input "Chat name: "
  if name ~= "" then
    vim.cmd("CopilotChatSave " .. name)
  end
end, { desc = "Save Chat" })
map("n", "<leader>cL", "<cmd>CopilotChatLoad<cr>", { desc = "Load Chat" })

-- Help and prompts
map("n", "<leader>ch", function()
  local actions = require "CopilotChat.actions"
  require("CopilotChat.integrations.telescope").pick(actions.help_actions())
end, { desc = "Help Actions" })

-- Visual mode mappings
map("v", "<leader>cr", "<cmd>CopilotChatRefactor<cr>", { desc = "Refactor Selection" })
map("v", "<leader>ce", "<cmd>CopilotChatExplain<cr>", { desc = "Explain Selection" })
