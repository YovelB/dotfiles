vim.pack.add({ "https://github.com/folke/snacks.nvim" }, { confirm = false })

local ok, snacks = pcall(require, "snacks")
if not ok then
  return
end

snacks.setup({
  bigfile = { enabled = true },
  quickfile = { enabled = true },
  explorer = { enabled = true },
  words = { enabled = true },
  indent = { enabled = true, animate = { enabled = false } },
  scope = { enabled = true },
  styles = { zen = { minimal = true, width = 0 } },
  dim = { animate = { enabled = false } },
  image = {
    enabled = vim.env.WEZTERM_PANE == nil,
    doc = { inline = false, float = true },
    math = { latex = { font_size = "small" } },
  },

  picker = {
    ui_select = true,
    -- toggle between cwd and git root
    win = {
      input = {
        keys = {
          ["<a-c>"] = { "toggle_cwd", mode = { "n", "i" } },
        },
      },
    },
    actions = {
      toggle_cwd = function(p)
        local cwd = vim.fn.getcwd()
        -- try to find git root natively
        local root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
        if vim.v.shell_error ~= 0 or root == "" then
          root = cwd
        end
        local current = p:cwd()
        p:set_cwd(current == root and cwd or root)
        p:find()
      end,
    },
    sources = {
      projects = {
        finder = "recent_projects",
        recent = true,
        max_depth = 2,
        patterns = {
          ".git",
          "Makefile",
          "CMakeLists.txt",
          "meson.build",
          "configure.ac",
          "compile_commands.json", -- c/c++
          "*.ioc",
          ".project",
          ".cproject", -- stm32
          "pyproject.toml",
          "setup.cfg",
          "setup.py",
          "requirements.txt", -- python
          "*.kicad_pro", -- kicad
        },
        dev = {
          "~/",
          "~/UserWorkspace/KiCad/projects/",
          "~/UserWorkspace/STM32/projects/",
          "~/UserWorkspace/zephyr-workspace/projects/",
        },
      },
      todo_comments = {
        exclude = {
          "Documents/",
          "STM32Cube/",
          "UserWorkspace/STM32/",
          "UserWorkspace/KiCad/ngspice/",
          "UserWorkspace/KiCad/exercises/",
          "UserWorkspace/KiCad/custom-libraries/",
          "UserWorkspace/KiCad/projects/Archive/",
          "UserWorkspace/zephyr-workspace/zephyr/",
          "UserWorkspace/zephyr-workspace/modules/",
        },
      },
    },
  },
  dashboard = {
    preset = {
      header = [[
                                                                   
      ████ ██████           █████      ██                 btw
     ███████████             █████                            
     █████████ ███████████████████ ███   ███████████  
    █████████  ███    █████████████ █████ ██████████████  
   █████████ ██████████ █████████ █████ █████ ████ █████  
 ███████████ ███    ███ █████████ █████ █████ ████ █████ 
██████  █████████████████████ ████ █████ █████ ████ ██████
      ]],
      keys = {
        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
        {
          icon = " ",
          key = "c",
          desc = "Config",
          action = ":lua Snacks.picker.files({cwd = vim.fn.stdpath('config')})",
        },
        { icon = " ", key = "s", desc = "Restore Session", action = ":lua require('persistence').load()" },
        { icon = "󰒲 ", key = "m", desc = "Mason (Tools)", action = ":Mason" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
      function()
        local ms = vim.g.start_time and math.floor((vim.uv.hrtime() - vim.g.start_time) / 1e6 + 0.5)
          or math.floor(vim.fn.reltimefloat(vim.fn.reltime()) * 1000 + 0.5)
        local plugins = #vim.fn.globpath(vim.fn.stdpath("data") .. "/site/pack/core/opt", "*", false, true)

        return {
          align = "center",
          text = {
            { "⚡ Neovim loaded ", hl = "Comment" },
            { tostring(plugins), hl = "Special" },
            { " plugins in ", hl = "Comment" },
            { tostring(ms) .. " ms", hl = "Special" },
          },
        }
      end,
    },
  },
})

-- hidden shortcuts for the dashboard
vim.api.nvim_create_autocmd("FileType", {
  pattern = "snacks_dashboard",
  callback = function()
    vim.schedule(function()
      vim.keymap.set("n", "q", "<cmd>qa<cr>", { buffer = true, nowait = true, silent = true, desc = "Quit" })
    end)
  end,
})

-- keymaps
local map = vim.keymap.set

-- UI toggles
map("n", "<leader>e", function()
  snacks.explorer()
end, { desc = "file explorer" })
-- scratch buffer
map("n", "<leader>bs", function()
  snacks.scratch()
end, { desc = "scratch buffer" })
map("n", "<leader>bS", function()
  snacks.scratch.select()
end, { desc = "select scratch buffer" })

snacks.toggle.option("spell", { name = "spelling" }):map("<leader>us")
-- snacks.toggle.option("wrap", { name = "wrap" }):map("<leader>uw")
snacks.toggle.option("showtabline", { off = 0, on = 2, name = "Bufferline" }):map("<leader>ub")
snacks.toggle.zen():map("<leader>uz")
snacks.toggle.diagnostics():map("<leader>ud")

-- find
-- map("n", "<leader>,", function()
-- 	snacks.picker.buffers()
-- end, { desc = "buffers" })
map("n", "<leader><space>", function()
  snacks.picker.files()
end, { desc = "find files" })
map("n", "<leader>fb", function()
  snacks.picker.buffers()
end, { desc = "buffers" })
map("n", "<leader>fB", function()
  snacks.picker.buffers({ hidden = true, nofile = true })
end, { desc = "buffers (all)" })
map("n", "<leader>fc", function()
  snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "find config file" })
map("n", "<leader>ff", function()
  snacks.picker.files()
end, { desc = "find files" })
map("n", "<leader>fg", function()
  snacks.picker.git_files()
end, { desc = "find files (git)" })
map("n", "<leader>fr", function()
  snacks.picker.recent()
end, { desc = "recent files" })
map("n", "<leader>fp", function()
  snacks.picker.projects()
end, { desc = "projects" })

-- git
map("n", "<leader>gg", function()
  snacks.lazygit()
end, { desc = "lazygit" })
map("n", "<leader>gG", function()
  snacks.lazygit.log()
end, { desc = "lazygit log (commits)" })
map({ "n", "x" }, "<leader>gB", function()
  snacks.gitbrowse()
end, { desc = "git browse (open)" })
-- map("n", "<leader>gd", function()
-- 	snacks.picker.git_diff()
-- end, { desc = "git diff (hunks)" })
-- map("n", "<leader>gs", function()
-- 	snacks.picker.git_status()
-- end, { desc = "git status" })
-- map("n", "<leader>gS", function()
-- 	snacks.picker.git_stash()
-- end, { desc = "git stash" })
-- map("n", "<leader>gl", function()
-- 	snacks.picker.git_log()
-- end, { desc = "git log" })

-- search / grep
map("n", "<leader>/", function()
  snacks.picker.grep()
end, { desc = "grep" })
map("n", "<leader>sb", function()
  snacks.picker.lines()
end, { desc = "buffer lines" })
map("n", "<leader>sB", function()
  snacks.picker.grep_buffers()
end, { desc = "grep open buffers" })
map("n", "<leader>sg", function()
  snacks.picker.grep()
end, { desc = "grep workspace" })
map({ "n", "x" }, "<leader>sw", function()
  snacks.picker.grep_word()
end, { desc = "search visual selection/word" })
map("n", "<leader>s/", function()
  snacks.picker.search_history()
end, { desc = "search history" })

-- utilities
-- map("n", '<leader>s"', function()
-- 	snacks.picker.registers()
-- end, { desc = "registers" })
map("n", "<leader>sa", function()
  snacks.picker.autocmds()
end, { desc = "autocmds" })
map("n", "<leader>sc", function()
  snacks.picker.command_history()
end, { desc = "command history" })
map("n", "<leader>sC", function()
  snacks.picker.commands()
end, { desc = "commands" })
map("n", "<leader>sd", function()
  snacks.picker.diagnostics()
end, { desc = "diagnostics" })
map("n", "<leader>sD", function()
  snacks.picker.diagnostics_buffer()
end, { desc = "buffer diagnostics" })
map("n", "<leader>sh", function()
  snacks.picker.help()
end, { desc = "help pages" })
-- map("n", "<leader>sH", function()
-- 	snacks.picker.highlights()
-- end, { desc = "highlights" })
map("n", "<leader>sj", function()
  snacks.picker.jumps()
end, { desc = "jumps" })
map("n", "<leader>sk", function()
  snacks.picker.keymaps()
end, { desc = "keymaps" })
map("n", "<leader>sm", function()
  snacks.picker.marks()
end, { desc = "marks" })
map("n", "<leader>st", "<cmd>TodoTrouble<cr>", { desc = "search todos (trouble)" })
map("n", "<leader>sT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", { desc = "search todos (todo/fix)" })
map("n", "<leader>ss", function()
  snacks.picker.lsp_symbols()
end, { desc = "document symbols" })
map("n", "<leader>sS", function()
  snacks.picker.lsp_workspace_symbols()
end, { desc = "workspace symbols" })
map("n", "<leader>sq", function()
  snacks.picker.qflist()
end, { desc = "quickfix list" })
map("n", "<leader>su", function()
  snacks.picker.undo()
end, { desc = "undotree" })
-- map("n", "<leader>uC", function()
-- 	snacks.picker.colorschemes()
-- end, { desc = "colorschemes" })
