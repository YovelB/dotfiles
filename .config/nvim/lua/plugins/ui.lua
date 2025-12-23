return {
  -- change color scheme
  {
    "folke/tokyonight.nvim",
    opts = { style = "night" },
  },
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.debug = false
      opts.routes = opts.routes or {}
      -- never focus Noice windows
      opts.views = vim.tbl_deep_extend("force", opts.views or {}, {
        cmdline_popup = { enter = false },
        popup = { enter = false },
        hover = { enter = false },
        notify = { enter = false },
        split = { enter = false },
      })
      -- skip noisy message
      table.insert(opts.routes, {
        filter = { event = "notify", find = "No information available" },
        opts = { skip = true },
      })
      return opts
    end,
  },
  -- customize snacks
  {
    "folke/snacks.nvim",
    opts = {
      -- enable snacks image
      image = {
        enabled = vim.env.WEZTERM_PANE == nil,
        doc = {
          inline = false,
          float = true,
        },
        math = { latex = { font_size = "small" } },
      },
      -- customize zen and zoom modes
      styles = {
        zen = { minimal = true },
      },
      picker = {
        sources = {
          -- snacks picker projects
          projects = {
            finder = "recent_projects",
            -- format = "file",
            -- 'dev' and 'patterns' are removed from here
            -- confirm = "load_session",
            recent = true,
            max_depth = 2,
            patterns = {
              ".git",
              -- c/c++
              "Makefile",
              "CMakeLists.txt",
              "meson.build",
              "configure.ac",
              "compile_commands.json",
              -- stm32
              "*.ioc",
              ".project",
              ".cproject",
              -- python
              "pyproject.toml",
              "setup.cfg",
              "setup.py",
              "requirements.txt",
              -- KiCad
              "*.kicad_pro",
            },
            -- dev is a dir just above root
            dev = {
              "~/",
              "~/UserWorkspace/KiCad/projects/",
              "~/UserWorkspace/STM32/projects/",
              "~/UserWorkspace/zephyr-workspace/projects/",
            },
          },
          -- hide unrelated comments (todo-comments plugin)
          todo_comments = {
            exclude = {
              -- general
              "Documents/",
              -- stm32
              "STM32Cube/",
              "UserWorkspace/STM32/",
              -- kicad
              "UserWorkspace/KiCad/ngspice/",
              "UserWorkspace/KiCad/exercises/",
              "UserWorkspace/KiCad/custom-libraries/",
              "UserWorkspace/KiCad/projects/Archive/",
              "UserWorkspace/KiCad/projects/Precision_Scope_Test/",
              "UserWorkspace/KiCad/projects/Precision_Scope/hardware/",
              "UserWorkspace/KiCad/projects/Precision_Scope/firmware/",
              "UserWorkspace/KiCad/projects/Precision_Scope/manufacturing/",
              "UserWorkspace/KiCad/projects/Power_Supply_Analyzer/",
              -- zephyr
              "UserWorkspace/zephyr-workspace/zephyr/",
              "UserWorkspace/zephyr-workspace/modules/",
            },
          },
        },
      },
    },
  },
  -- dashboard config
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      dashboard = {
        pane_gap = 0,
        preset = {
          pick = function(cmd, opts)
            return LazyVim.pick(cmd, opts)()
          end,
          header = [[
                                                                   
      ████ ██████           █████      ██                    
     ███████████             █████                            
     █████████ ███████████████████ ███   ███████████  
    █████████  ███    █████████████ █████ ██████████████  
   █████████ ██████████ █████████ █████ █████ ████ █████  
 ███████████ ███    ███ █████████ █████ █████ ████ █████ 
██████  █████████████████████ ████ █████ █████ ████ ██████
        ]],
        },
      },
    },
  },
  -- update statusline
  {
    "nvim-lualine/lualine.nvim",
    opts = function()
      local lualine_require = require("lualine_require")
      lualine_require.require = require
      local icons = LazyVim.config.icons
      vim.o.laststatus = vim.g.lualine_laststatus

      local opts = {
        options = {
          theme = "auto",
          globalstatus = vim.o.laststatus == 3,
          disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            function()
              -- cache git root to avoid repeated system calls
              if not vim.b._git_root_cache then
                local git_root = vim.fn
                  .system("git -C " .. vim.fn.expand("%:p:h") .. " rev-parse --show-toplevel 2>/dev/null")
                  :gsub("\n", "")
                if vim.v.shell_error == 0 and git_root ~= "" then
                  vim.b._git_root_cache = " " .. vim.fn.fnamemodify(git_root, ":t")
                else
                  -- fallback to cwd if not in git repo
                  vim.b._git_root_cache = " " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
                end
              end
              return vim.b._git_root_cache
            end,
          },

          lualine_c = {
            { LazyVim.lualine.pretty_path({ length = 4 }) },
          },
          lualine_x = {
            -- command status
            -- stylua: ignore
            {
              ---@diagnostic disable-next-line: undefined-field
              function() return require("noice").api.status.command.get() end,
              ---@diagnostic disable-next-line: undefined-field
              cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
              color = function() return { fg = Snacks.util.color("Statement") } end,
            },
            Snacks.profiler.status(),
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
            -- mode status color
            -- stylua: ignore
            {
              ---@diagnostic disable-next-line: undefined-field
              function() return require("noice").api.status.mode.get() end,
              ---@diagnostic disable-next-line: undefined-field
              cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
              color = function() return { fg = Snacks.util.color("Constant") } end,
            },
            -- dap status
            -- stylua: ignore
            {
              function() return "  " .. require("dap").status() end,
              cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
              color = function() return { fg = Snacks.util.color("Debug") } end,
            },
            -- lazy updates
            -- stylua: ignore
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = function() return { fg = Snacks.util.color("Special") } end,
            },
            {
              "diff",
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed,
                  }
                end
              end,
            },
            function()
              return require("triforce.lualine").level({
                bar = { chars = { filled = "◆", empty = "◇" }, length = 5 },
              })
            end,
          },
          lualine_y = { "filetype" },
          lualine_z = {
            { "progress", separator = " ", padding = { left = 1, right = 1 } },
            { "branch", padding = { right = 1 } },
          },
        },
        extensions = { "neo-tree", "lazy", "fzf" },
      }

      -- do not add trouble symbols if aerial is enabled
      -- And allow it to be overriden for some buffer types (see autocmds)
      if vim.g.trouble_lualine and LazyVim.has("trouble.nvim") then
        local trouble = require("trouble")
        local symbols = trouble.statusline({
          mode = "symbols",
          groups = {},
          title = false,
          filter = { range = true },
          format = "{kind_icon}{symbol.name:Normal}",
          hl_group = "lualine_c_normal",
        })
        table.insert(opts.sections.lualine_c, {
          symbols and symbols.get,
          cond = function()
            if vim.b.trouble_lualine == false or not symbols.has() then
              return false
            end
            local symbol_text = symbols.get()
            if not symbol_text then
              return false
            end
            -- check if the symbol text is not too long
            local max_width = 120
            return #symbol_text <= max_width
          end,
        })
      end
      -- change section and component separators
      opts.options.section_separators = { left = "", right = "" }
      opts.options.component_separators = { left = "╱", right = "╱" }
      return opts
    end,
  },
}
