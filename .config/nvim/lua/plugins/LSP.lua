return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- LSPs
        "bash-language-server", -- Bash
        "clangd", -- C/C++
        "lua-language-server", -- Lua
        "pyright", -- Python
        "json-lsp", -- JSON
        "marksman", -- Markdown
        "neocmakelsp", -- CMake
        "taplo", -- TOML
        "texlab", -- LaTeX

        -- Debug Adapters
        "codelldb", -- C/C++ and Rust
        "debugpy", -- Python

        -- Linters
        "ruff", -- Python
        "shellcheck", -- Shell
        "cmakelint", -- CMake

        -- Formatters
        "stylua", -- Lua
        "shfmt", -- Shell
      },
    },
  },
}
