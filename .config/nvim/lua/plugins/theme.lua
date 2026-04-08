vim.pack.add({ "https://github.com/folke/tokyonight.nvim" }, { confirm = false })

local ok, tokyonight = pcall(require, "tokyonight")

if ok then
  tokyonight.setup({
    style = "night",                -- preferred style ("storm", "moon", "night", "day")
    transparent = false,            -- true for transparent background
    terminal_colors = true,
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      functions = {},
      variables = {},
    },
  })

else
  vim.notify("Tokyonight is still downloading.", vim.log.levels.WARN)
end

  -- apply theme
  local theme_ok, _ = pcall(vim.cmd.colorscheme, "tokyonight")
  if not theme_ok then
    vim.cmd.colorscheme("default")
end
