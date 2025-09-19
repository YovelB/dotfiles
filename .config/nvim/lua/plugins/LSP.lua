return {
  -- configure treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "latex" })
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- lsps
        "lua-language-server", -- lua
        "clangd", -- c/c++
        "neocmakelsp", -- cmake
        "matlab-language-server", -- matlab

        "marksman", -- markdown
        "json-lsp", -- json

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
  -- cmake tools
  {
    "Civitasv/cmake-tools.nvim",
    opts = {},
  },
}
