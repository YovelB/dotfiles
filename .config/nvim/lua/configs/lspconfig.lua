-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

-- configure these lsp (manually needs to be installed)
local servers = {
  "cmake",
  "clangd",
  "pyright",
  "matlab_ls",
}

-- Setup mason first
require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = servers, -- Uses the same server list
}

local nvlsp = require "nvchad.configs.lspconfig"

-- lsps with default config
for _, lsp in ipairs(servers) do
  if lsp ~= "clangd" then
    lspconfig[lsp].setup {
      on_attach = nvlsp.on_attach,
      on_init = nvlsp.on_init,
      capabilities = nvlsp.capabilities,
    }
  end
end

-- Clangd setup
lspconfig.clangd.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  cmd = {
    "clangd",
    -- helps with embedded toolchains
    "--query-driver=/home/yovelb/.local/share/zephyr/tools/zephyr-sdk-0.17.0/arm-zephyr-eabi/bin/arm-zephyr-eabi-gcc",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--offset-encoding=utf-16",
    "--enable-config",
    "--fallback-style=file:" .. os.getenv "HOME" .. "/.config/nvim/lua/configs/format/.clang-format",
  },
  init_options = {
    compilationDatabaseDirectory = "build", -- if you use cmake
  },
}
