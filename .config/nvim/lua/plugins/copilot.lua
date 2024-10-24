return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  -- dependencies = {
  --   "zbirenbaum/copilot-cmp"
  -- },
  config = function()
    require("copilot").setup {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-f>",
        },
      },
      panel = { enabled = false },
      -- add your filetypes here
      filetypes = { lua = true, python = true },
    }
  end,
}
