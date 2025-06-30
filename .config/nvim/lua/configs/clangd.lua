-- lua/configs/clangd.lua
local M = {}

local function is_zephyr_project()
  local zephyr_indicators = {
    "zephyr/kernel",
    "CMakeLists.txt",
    "prj.conf",
  }

  for _, file in ipairs(zephyr_indicators) do
    if vim.fn.findfile(file, ".;") ~= "" then
      return true
    end
  end
  return false
end

M.setup = function()
  local nvlsp = require "nvchad.configs.lspconfig"
  local lspconfig = require "lspconfig"
  local mason_lspconfig = require "mason-lspconfig"

  -- Ensure clangd is installed through mason first
  mason_lspconfig.setup {
    ensure_installed = { "clangd" },
  }

  -- Add custom capabilities for clangd
  local capabilities = vim.deepcopy(nvlsp.capabilities)
  capabilities.offsetEncoding = { "utf-16" } -- Fixes offset encoding issues

  -- Base clangd configuration with shared settings
  local base_clangd_config = {
    on_attach = function(client, bufnr)
      -- Call default NvChad attachments first
      nvlsp.on_attach(client, bufnr)

      -- Clangd specific keymaps
      local opts = { buffer = bufnr, silent = true }

      -- Switch between header/source
      vim.keymap.set("n", "<leader>h", "<cmd>ClangdSwitchSourceHeader<cr>", opts)

    end,
    on_init = nvlsp.on_init,
    capabilities = capabilities,
    cmd = {
      "clangd",
      "--background-index", -- Index project in background
      "--clang-tidy", -- Enable static analysis
      "--completion-style=detailed", -- Detailed completion items
      "--function-arg-placeholders", -- Show argument placeholders
      "--fallback-style=llvm", -- Default code style
      "--pch-storage=memory", -- Store precompiled headers in memory
      "--enable-config", -- Enable reading .clangd config file
      "--all-scopes-completion", -- Show completions from all scopes
      "--ranking-model=heuristics", -- Use heuristics for completion ranking
      "-j=17", -- Number of workers (adjust to CPU cores)
      "--pretty", -- Pretty print JSON
    },
    init_options = {
      -- Enable features that require extra memory/CPU
      usePlaceholders = true, -- Show function parameter hints
      completeUnimported = true, -- Show completion items for not-yet-imported symbols
      clangdFileStatus = true, -- Report file status for diagnostics
    },
    -- Find project root directory
    root_dir = function(fname)
      return lspconfig.util.root_pattern(
        "compile_commands.json", -- CMake/Build system
        "compile_flags.txt", -- Clang compilation flags
        "configure.ac", -- Autoconf projects
        ".git" -- Git repository
      )(fname) or vim.fn.getcwd()
    end,
    single_file_support = true, -- Enable support for single file mode
  }

  -- Default specific settings for regular C/C++ development
  local default_specific = {
    -- "--header-insertion=iwyu", -- Include-what-you-use style includes
    "--header-insertion=never", -- Don't auto-insert headers
    "--header-insertion-decorators", -- Add scope to inserted headers
  }

  -- Zephyr specific settings for embedded development
  local zephyr_specific = {
    "--header-insertion=never", -- Don't auto-insert headers
    "--query-driver=/home/yourusername/.local/share/zephyr/tools/zephyr-sdk-0.17.0/arm-zephyr-eabi/bin/arm-zephyr-eabi-gcc",
    "--compile-commands-dir=build", -- Where to find compile_commands.json
  }

  -- Additional features that could be added:
  -- 1. Add clang-tidy configuration integration
  -- 2. Add compile_commands.json generation helpers
  -- 3. Add custom clangd configuration file (.clangd) handling
  -- 4. Add project-specific include paths
  -- 5. Add custom compiler flags support
  -- 6. Add compilation database management
  -- 7. Add cross-compilation support
  -- 8. Add different optimization level supports

  -- Merge base config with specific settings
  local function merge_config(base, specific)
    local config = vim.deepcopy(base)
    for _, v in ipairs(specific) do
      table.insert(config.cmd, v)
    end
    return config
  end

  -- Set up clangd based on project type
  if is_zephyr_project() then
    lspconfig.clangd.setup(merge_config(base_clangd_config, zephyr_specific))
  else
    lspconfig.clangd.setup(merge_config(base_clangd_config, default_specific))
  end
end

return M
