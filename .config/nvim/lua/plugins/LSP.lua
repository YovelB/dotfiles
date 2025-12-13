return {
  {
    -- treesitter with additional langs
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
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
        "typst",
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

        -- formatters
        "stylua", -- lua
        "shfmt", -- shell

        -- additional tools
        "markdown-toc", -- markdown toc generator
        "markdownlint-cli2", -- markdown linter
        "texlab", -- latex
        "tinymist", -- typst LSP
        "typstyle", -- typst formatter
        -- "harper-ls", -- grammer and style checker
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
            -- query the needed driver (use stm32cubeide option if not avialiable use system wide option)
            "--query-driver=/opt/stm32cubeide/plugins/*/tools/bin/arm-none-eabi-gcc",
            -- "--query-driver=/usr/bin/arm-none-eabi-gcc", -- newer version
          },
        },
        tinymist = {
          single_file_support = true,
          keys = {
            {
              "\\w",
              function()
                local file = vim.fn.expand("%")
                -- helper to auto-hide window on typing
                local function setup_autohide()
                  vim.api.nvim_create_autocmd({ "InsertEnter", "TextChanged" }, {
                    buffer = 0, -- attach to current code buffer
                    once = true,
                    callback = function()
                      if _G.TypstWatchBuf and vim.api.nvim_buf_is_valid(_G.TypstWatchBuf) then
                        local win = vim.fn.bufwinnr(_G.TypstWatchBuf)
                        if win ~= -1 then
                          vim.cmd(win .. "close")
                        end
                      end
                    end,
                  })
                end

                -- 1. if job exists, just toggle window
                if _G.TypstJobId then
                  if _G.TypstWatchBuf and vim.api.nvim_buf_is_valid(_G.TypstWatchBuf) then
                    local win = vim.fn.bufwinnr(_G.TypstWatchBuf)
                    if win ~= -1 then
                      vim.cmd(win .. "close") -- hide
                    else
                      vim.cmd("botright 10split") -- show
                      vim.api.nvim_win_set_buf(0, _G.TypstWatchBuf)
                      vim.cmd("normal! G")
                      vim.cmd("wincmd p")
                      setup_autohide()
                    end
                  end
                  return
                end

                -- 2. start new watch process
                vim.cmd("botright 10split")
                -- using jobstart inside term to get job_id easily
                vim.cmd("term typst watch " .. vim.fn.shellescape(file))
                _G.TypstWatchBuf = vim.api.nvim_get_current_buf()
                _G.TypstJobId = vim.b.terminal_job_id -- capture job id from terminal buffer

                -- configure buffer
                vim.bo[_G.TypstWatchBuf].buflisted = false
                vim.keymap.set("n", "q", ":close<CR>", { buffer = _G.TypstWatchBuf, silent = true })

                vim.cmd("wincmd p") -- focus back to code
                setup_autohide()

                -- 3. try to open pdf (with delay to allow generation)
                vim.defer_fn(function()
                  local pdf = vim.fn.expand("%:r") .. ".pdf"
                  if vim.fn.filereadable(pdf) == 1 then
                    vim.fn.jobstart({ "xdg-open", pdf }, { detach = true })
                  else
                    vim.notify("pdf not ready yet, change waiting time in config", vim.log.levels.WARN)
                  end
                end, 100) -- wait 100 ms
              end,
              desc = "typst watch toggle",
            },
            {
              "\\c",
              function()
                local file = vim.fn.expand("%")
                vim.notify("compiling typst...", vim.log.levels.INFO)
                vim.fn.jobstart({ "typst", "compile", file }, {
                  on_exit = function(_, code)
                    if code == 0 then
                      vim.notify("typst compiled successfully", vim.log.levels.INFO)
                      local pdf = vim.fn.expand("%:r") .. ".pdf"
                      if vim.fn.filereadable(pdf) == 1 then
                        vim.fn.jobstart({ "xdg-open", pdf }, { detach = true })
                      end
                    else
                      vim.notify("typst compilation failed", vim.log.levels.ERROR)
                    end
                  end,
                })
              end,
              desc = "Typst Compile (Async)",
            },
          },
        },
      },
    },
  },
  -- cmake tools (disabled until learned)
  -- {
  --   "Civitasv/cmake-tools.nvim",
  -- },
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
