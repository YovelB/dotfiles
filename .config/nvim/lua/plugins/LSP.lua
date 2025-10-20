return {
  {
    -- treesitter with additional langs
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        -- editor support
        "lua",
        "vim",
        "vimdoc",
        "query",
        "regex",
        -- zephyr embedded
        "c",
        "cpp",
        "cmake",
        "devicetree",
        "make",
        "kconfig",
        "ini", -- for stm32cubeide .ioc files
        "asm", -- for assembly
        -- scripting langs
        "python",
        "matlab",
        "bash",
        "json",
        "yaml",
        -- version control
        "gitcommit",
        "gitignore",
        -- docs
        "markdown",
        "latex",
      },
    },
  },
  -- general log highlight
  { "fei6409/log-highlight.nvim", event = "BufRead *.log", opts = {} },
  -- mason lsp config
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
  -- clangd override:
  -- add --query-driver for STM32CubeIDE toolchain
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            -- adjust globs to your install locations as needed (use stm32cubeide option if not avialiable use system wide option)
            "--query-driver=/opt/stm32cubeide/**/tools/bin/arm-none-eabi-*,/usr/bin/arm-none-eabi-*",
          },
        },
      },
    },
  },
  -- cmake tools
  {
    "Civitasv/cmake-tools.nvim",
  },
  -- use global config for markdownlint-cli2 linter
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          args = { "--config", "~/.markdownlint-cli2.jsonc", "--" },
        },
      },
    },
  },
}
