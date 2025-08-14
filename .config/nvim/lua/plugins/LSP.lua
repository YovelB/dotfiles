return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- lsps
        "bash-language-server", -- bash
        "lua-language-server", -- lua
        "clangd", -- c/c++
        "pyright", -- python
        "neocmakelsp", -- cmake

        "marksman", -- markdown
        "json-lsp", -- json
        "taplo", -- toml

        -- debug adapters
        "codelldb", -- c/c++ and rust
        "debugpy", -- python

        -- linters
        "ruff", -- python
        "shellcheck", -- shell
        "cmakelint", -- cmake

        -- formatters
        "stylua", -- lua
        "shfmt", -- shell

        -- additional tools
        "markdown-toc", -- markdown toc generator
        "markdownlint-cli2", -- markdown linter
        "texlab", -- latex
      },
    },
  },
  -- use global config for markdownlint-cli2 linter
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = { "markdownlint-cli2" },
      },
      linters = {
        ["markdownlint-cli2"] = {
          args = {
            "--config",
            vim.fn.stdpath("config") .. "/lua/plugins/cfg_linters/global.markdownlint-cli2.jsonc",
            "--",
          },
        },
      },
    },
  },
}
