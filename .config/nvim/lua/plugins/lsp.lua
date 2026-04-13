-- mason (downloads server binaries, linters, and formatters)
vim.pack.add({ "https://github.com/williamboman/mason.nvim" }, { confirm = false })
-- clangd extensions
vim.pack.add({ "https://github.com/p00f/clangd_extensions.nvim" }, { confirm = false })
-- friendly snippets - basic snippets
vim.pack.add({ "https://github.com/rafamadriz/friendly-snippets" }, { confirm = false })
-- lazydev - lua language server autocompletion
vim.pack.add({ "https://github.com/folke/lazydev.nvim" }, { confirm = false })
-- conform - light formatting engine
vim.pack.add({ "https://github.com/stevearc/conform.nvim" }, { confirm = false })
-- nvim-lint - async liner
vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" }, { confirm = false })
-- blink - autocompletion engine
vim.pack.add({ "https://github.com/saghen/blink.cmp" }, { confirm = false })

local ok_mason, mason = pcall(require, "mason")
if not ok_mason then
  return
end

mason.setup()

-- tools to install
local tools = {
  -- lsps
  "lua-language-server",
  "clangd",
  "pyright",
  "neocmakelsp",
  "marksman",
  -- "matlab-language-server",
  -- "json-lsp",
  "tinymist",

  -- debug adapters
  "codelldb", -- c/c++ and rust
  "debugpy", -- python

  -- linters
  "ruff", -- python
  "shellcheck", --shell
  "markdownlint-cli2",

  -- formatters
  "stylua", -- lua
  "shfmt", -- shell
  "typstyle",

  -- additional tools
  "markdown-toc",
  -- "texlab",
}

-- install tools
local registry = require("mason-registry")
registry.refresh(function()
  for _, tool in ipairs(tools) do
    local pkg = registry.get_package(tool)
    if not pkg:is_installed() then
      pkg:install()
    end
  end
end)

-- clangd extensions setup
local ok_ce, clangd_ext = pcall(require, "clangd_extensions")
if ok_ce then
  clangd_ext.setup({
    inlay_hints = { inline = false },
    ast = {
      role_icons = {
        type = "",
        declaration = "",
        expression = "",
        specifier = "",
        statement = "",
        ["template argument"] = "",
      },
      kind_icons = {
        Compound = "",
        Recovery = "",
        TranslationUnit = "",
        PackExpansion = "",
        TemplateTypeParm = "",
        TemplateTemplateParm = "",
        TemplateParamObject = "",
      },
    },
  })
end

-- capabilities (fixes clangd)
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_bl, blink = pcall(require, "blink.cmp")
if ok_bl then
  capabilities = blink.get_lsp_capabilities(capabilities)
end
capabilities.offsetEncoding = { "utf-16" }

-- lsp config
-- lua
vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
    ".git",
  },
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      diagnostics = { globals = { "vim" } },
    },
  },
})

-- clangd (c/c++ with stm32cubeide overrides)
vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
    "--query-driver=/opt/stm32cubeide/plugins/*/tools/bin/arm-none-eabi-gcc",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_markers = {
    "compile_commands.json",
    "compile_flags.txt",
    "configure.ac",
    "Makefile",
    "configure.in",
    "config.h.in",
    "meson.build",
    "meson_options.txt",
    "build.ninja",
    ".clangd",
    ".clang-tidy",
    ".clang-format",
    ".git",
  },
  capabilities = capabilities,
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
})

-- tinymist (typst)
vim.lsp.config("tinymist", {
  capabilities = capabilities,
  cmd = { "tinymist" },
  filetypes = { "typst" },
  root_markers = { "typst.toml", ".git" },
  settings = {
    exportPdf = "onSave",
  },
})

-- enable the servers natively
vim.lsp.enable("lua_ls")
vim.lsp.enable("clangd")
vim.lsp.enable("tinymist")

-- keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "lsp: " .. desc })
    end

    -- standard mappings
    map("gd", function()
      require("snacks").picker.lsp_definitions()
    end, "goto definition")
    map("gr", function()
      require("snacks").picker.lsp_references()
    end, "goto references")
    map("gI", function()
      require("snacks").picker.lsp_implementations()
    end, "goto implementation")
    map("gy", function()
      require("snacks").picker.lsp_type_definitions()
    end, "goto type definition")
    map("gD", vim.lsp.buf.declaration, "goto declaration")
    map("K", vim.lsp.buf.hover, "hover")
    map("<leader>ca", vim.lsp.buf.code_action, "code action")
    map("<leader>cr", vim.lsp.buf.rename, "rename symbol")
    map("<leader>cR", function()
      require("snacks").rename.rename_file()
    end, "rename file")

    -- clangd specific mappings
    if client and client.name == "clangd" then
      map("<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", "switch source/header")
    end

    -- tinymist specific mappings
    if client and client.name == "tinymist" then
      map("\\c", function()
        local file = vim.fn.expand("%")
        -- native neovim replacement for LazyVim.root.get()
        local root = vim.fs.root(bufnr, { "typst.toml", ".git" }) or vim.fn.getcwd()

        vim.fn.jobstart({ "typst", "compile", file, "--root", root }, {
          on_exit = function(_, code)
            if code == 0 then
              local pdf = vim.fn.expand("%:r") .. ".pdf"
              if vim.fn.filereadable(pdf) == 1 then
                vim.fn.jobstart({ "xdg-open", pdf }, { detach = true })
              end
            else
              vim.notify("compilation failed", vim.log.levels.ERROR)
            end
          end,
        })
      end, "typst compile")
    end
  end,
})

-- diagnostics
vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  virtual_text = { spacing = 4, source = "if_many", prefix = "●" },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.HINT] = " ",
      [vim.diagnostic.severity.INFO] = " ",
    },
  },
})

-- friendly snippets - basic snippets
-- lazydev - lua language server autocompletion
local ok_ldev, lazydev = pcall(require, "lazydev")
if ok_ldev then
  lazydev.setup({
    library = {
      { path = "luvit-meta/library", words = { "vim%.uv" } },
    },
  })
end

-- conform - light formatting engine
local ok_conform, conform = pcall(require, "conform")
if not ok_conform then
  return
end

conform.setup({
  -- map filetypes to their formatters
  formatters_by_ft = {
    lua = { "stylua" },
    sh = { "shfmt" },
    typst = { "typstyle" },
    python = { "ruff" },
  },

  -- configure automatic formatting on save
  format_on_save = {
    timeout_ms = 3000,
    async = false,
    -- if a file doesnt have a specific formatter listed above, it asks the active lsp (like clangd) to format it instead
    lsp_format = "fallback",
  },

  -- customize specific formatters (optional)
  formatters = {
    shfmt = {
      prepend_args = { "-i", "2", "-ci" },
    },
  },
})

-- manual formatting keymap
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  conform.format({
    lsp_format = "fallback",
    timeout_ms = 3000,
  })
end, { desc = "format buffer" })

-- nvim-lint - async liner
local ok_lint, lint = pcall(require, "lint")
if not ok_lint then
  return
end

-- map filetypes to linters (installed via mason in lsp.lua)
lint.linters_by_ft = {
  python = { "ruff" },
  sh = { "shellcheck" },
  markdown = { "markdownlint-cli2" },
}

-- override markdownlint-cli2 to use your global config file
local markdownlint = lint.linters["markdownlint-cli2"]
markdownlint.args = {
  "--config",
  vim.env.HOME .. "/.config/nvim/.markdownlint-cli2.jsonc",
  "--",
  unpack(markdownlint.args),
}

local lint_augroup = vim.api.nvim_create_augroup("nvim-lint", { clear = true })

-- debounce timer to prevent lag when leaving insert mode rapidly
-- wrap it in assert() because of the nil check warnings
local timer = assert(vim.uv.new_timer(), "failed to create timer")
local function debounce_lint()
  timer:stop()
  timer:start(100, 0, function()
    timer:stop()
    vim.schedule(function()
      lint.try_lint()
    end)
  end)
end

-- trigger linting on file open, save, and when leaving insert mode
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  group = lint_augroup,
  callback = debounce_lint,
})

-- blink - autocompletion engine
local ok_bl, blink = pcall(require, "blink.cmp")
if not ok_bl then
  return
end

blink.setup({
  snippets = {
    preset = "default",
  },
  appearance = {
    use_nvim_cmp_as_default = false,
    nerd_font_variant = "mono",
  },

  completion = {
    accept = {
      auto_brackets = { enabled = true },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
    ghost_text = {
      enabled = false,
    },
    menu = {
      draw = { treesitter = { "lsp" } },
    },
  },

  signature = { enabled = true },

  sources = {
    default = { "lazydev", "lsp", "path", "snippets", "buffer" },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      },
      snippets = {
        opts = {
          search_paths = { vim.fn.stdpath("config") .. "/snippets" },
        },
      },
    },
  },

  -- command line completion (pressing ':' or '/')
  cmdline = {
    enabled = true,
    keymap = { preset = "cmdline" },
    completion = {
      menu = { auto_show = true },
      ghost_text = { enabled = true },
    },
  },

  keymap = {
    ["<C-n>"] = { "select_next", "fallback_to_mappings" },
    ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
    ["<C-y>"] = { "select_and_accept", "fallback" },
    ["<C-e>"] = { "cancel", "fallback" },

    ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
    ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
    ["<CR>"] = { "select_and_accept", "fallback" },
    ["<Esc>"] = { "cancel", "hide_documentation", "fallback" },

    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
  },
})
