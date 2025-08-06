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
}
