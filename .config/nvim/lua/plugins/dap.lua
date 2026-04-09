-- nvim-dap - debug adapter protocol client allows debug, break points and inspecting state of apps
vim.pack.add({ "https://github.com/mfussenegger/nvim-dap" }, { confirm = false })

local ok, dap = pcall(require, "dap")
if not ok then
  return
end

-- configure codelldb for c/c++ and rust
if not dap.adapters["codelldb"] then
  dap.adapters["codelldb"] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = {
      command = "codelldb",
      args = { "--port", "${port}" },
    },
  }
end

-- assign the adapter to c and cpp filetypes
for _, lang in ipairs({ "c", "cpp" }) do
  dap.configurations[lang] = {
    {
      type = "codelldb",
      request = "launch",
      name = "launch file",
      program = function()
        return vim.fn.input("path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
    },
    {
      type = "codelldb",
      request = "attach",
      name = "attach to process",
      pid = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
    },
  }
end

local map = vim.keymap.set
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "debug: toggle breakpoint" })
map("n", "<leader>dc", dap.continue, { desc = "debug: continue" })
map("n", "<leader>di", dap.step_into, { desc = "debug: step into" })
map("n", "<leader>do", dap.step_over, { desc = "debug: step over" })
map("n", "<leader>dO", dap.step_out, { desc = "debug: step out" })
map("n", "<leader>dt", dap.terminate, { desc = "debug: terminate" })
