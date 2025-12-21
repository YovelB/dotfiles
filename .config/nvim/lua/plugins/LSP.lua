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
        "harper-ls", -- grammer and style checker
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
        harper_ls = {
          filetypes = { "typst", "tex", "bib" },
          settings = {
            ["harper-ls"] = {
              userDictPath = vim.fn.stdpath("config") .. "/spell/harper_dict.txt",
              linters = {
                SentenceCapitalization = false,
                SpellCheck = false,
                -- LongSentences = false,
              },
              -- isolateEnglish = true,
              -- ignores checking in [here] and [[here (links)]]
              markdown = { IgnoreLinkTitle = true },
            },
          },
        },
        tinymist = {
          single_file_support = true,
          keys = {
            {
              "\\w",
              function()
                local state = _G.TypstWatch or {}
                _G.TypstWatch = state

                -- Stop existing watch
                if state.job_id then
                  pcall(vim.fn.jobstop, state.job_id)
                  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
                    vim.api.nvim_buf_delete(state.buf, { force = true })
                  end
                  if state.autocmd then
                    pcall(vim.api.nvim_del_autocmd, state.autocmd)
                  end
                  if state.exit_autocmd then
                    pcall(vim.api.nvim_del_autocmd, state.exit_autocmd)
                  end
                  if state.ns then
                    vim.on_key(nil, state.ns)
                  end
                  _G.TypstWatch = {}
                  vim.notify("Typst watch stopped", vim.log.levels.INFO)
                  return
                end

                -- Start new watch
                local file = vim.fn.expand("%")
                vim.cmd("botright 10split")
                vim.cmd("term typst watch " .. vim.fn.shellescape(file))
                local buf = vim.api.nvim_get_current_buf()
                state.job_id = vim.b.terminal_job_id
                state.buf = buf
                state.ns = vim.api.nvim_create_namespace("typst_autohide")

                vim.bo[buf].buflisted = false
                vim.keymap.set("n", "q", ":close<CR>", { buffer = buf, silent = true })
                vim.cmd("wincmd p") -- focus back

                -- auto hide logic
                local function arm_autohide()
                  local limit = vim.g.typst_watch_autoclose_after_keystrokes or 2
                  local keystrokes = 0
                  vim.on_key(nil, state.ns)
                  vim.on_key(function()
                    vim.schedule(function()
                      if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
                        return
                      end
                      -- reset counter if focused on watch window (allows Ctrl+w w)
                      if vim.api.nvim_get_current_buf() == state.buf then
                        keystrokes = 0
                        return
                      end
                      keystrokes = keystrokes + 1
                      if keystrokes >= limit then
                        local win = vim.fn.bufwinnr(state.buf)
                        if win ~= -1 then
                          vim.cmd(win .. "close")
                        end
                        vim.on_key(nil, state.ns)
                      end
                    end)
                  end, state.ns)
                end
                arm_autohide()

                -- reopen watch window on save
                state.autocmd = vim.api.nvim_create_autocmd("BufWritePost", {
                  buffer = vim.api.nvim_get_current_buf(),
                  callback = function()
                    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
                      if vim.fn.bufwinnr(state.buf) == -1 then
                        vim.cmd("botright 10split")
                        vim.api.nvim_win_set_buf(0, state.buf)
                        vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(state.buf), 0 })
                        vim.cmd("wincmd p")
                        arm_autohide()
                      end
                    end
                  end,
                })

                -- clean exit (fixes :wqa)
                state.exit_autocmd = vim.api.nvim_create_autocmd("QuitPre", {
                  callback = function()
                    if state.job_id then
                      vim.fn.jobstop(state.job_id)
                    end
                    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
                      vim.api.nvim_buf_delete(state.buf, { force = true })
                    end
                  end,
                })

                -- try to open pdf
                vim.defer_fn(function()
                  local pdf = vim.fn.expand("%:r") .. ".pdf"
                  if vim.fn.filereadable(pdf) == 1 then
                    vim.fn.jobstart({ "xdg-open", pdf }, { detach = true })
                  else
                    vim.notify("pdf not ready yet", vim.log.levels.WARN)
                  end
                end, 100) -- delay to open (problematic only on big files and first compilation)
              end,
              desc = "typst watch toggle",
            },
            -- regular compile
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
              desc = "typst compile",
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
