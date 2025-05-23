-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

-- configure these lsp (manually needs to be installed)
local servers = {
  "cmake",
  -- "clangd",
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
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

require("configs.clangd").setup()
