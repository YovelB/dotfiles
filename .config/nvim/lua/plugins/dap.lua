-- nvim-dap - debug adapter protocol client for debugging
vim.pack.add({ "https://github.com/mfussenegger/nvim-dap" }, { confirm = false })
-- nvim-nio - dependency for nvim-dap-ui
vim.pack.add({ "https://github.com/nvim-neotest/nvim-nio" }, { confirm = false })
-- nvim-dap-ui - UI for the debugger
vim.pack.add({ "https://github.com/rcarriga/nvim-dap-ui" }, { confirm = false })
-- cortex-debug extension for nvim-dap
vim.pack.add({ "https://github.com/jedrzejboczar/nvim-dap-cortex-debug" }, { confirm = false })

local ok, dap = pcall(require, "dap")
if not ok then
  return
end

-- setup dap-ui
local ok_ui, dapui = pcall(require, "dapui")
if ok_ui then
  dapui.setup()
  -- auto open/close UI
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
end

-- setup cortex-debug adapter
local ok_cortex, dap_cortex = pcall(require, "dap-cortex-debug")
if ok_cortex then
  dap_cortex.setup({
    debug = false,
    extension_path = vim.fn.stdpath("data") .. "/mason/packages/cortex-debug/extension",
    -- this helps the adapter find the node executable within the extension
    lib_extension_path = vim.fn.stdpath("data") .. "/mason/packages/cortex-debug/extension/dist/debugadapter.js",
  })
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

    {
      type = "cortex-debug",
      request = "launch",
      name = "STM32 Debug (OpenOCD)",
      cwd = "${workspaceFolder}",
      executable = function()
        return vim.fn.input("Path to ELF: ", vim.fn.getcwd() .. "/build/Debug/", "file")
      end,
      servertype = "openocd",
      device = "STM32H753VI", -- specific to your chip
      -- OpenOCD interface and target configs (adjust interface if using J-Link)
      configFiles = { "interface/stlink.cfg", "target/stm32h7x.cfg" },
      -- GDB executable path if its not in global PATH
      gdbPath = "arm-none-eabi-gdb",
      showDevDebugOutput = false,
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

map("n", "<leader>du", function()
  require("dapui").toggle()
end, { desc = "debug: toggle ui" })
map({ "n", "v" }, "<leader>de", function()
  require("dapui").eval()
end, { desc = "debug: eval" })
map("n", "<leader>dw", function()
  local var = vim.fn.expand("<cexpr>")
  require("dapui").elements.watches.add(var)
  vim.notify("Added to watch: " .. var)
end, { desc = "debug: add variable to watch" })
map("n", "<leader>ds", function()
  dapui.float_element("watches", { enter = true })
end, { desc = "debug: show/manage watches" })

-- print backtrace and hardware fault registers
map("n", "<leader>dk", function()
  dap.repl.execute("bt")
  dap.repl.execute("monitor mdw 0xE000ED28 1") -- CFSR (Configurable Fault Status Register)
  dap.repl.execute("monitor mdw 0xE000ED2C 1") -- HFSR (HardFault Status Register)
  dap.repl.open() -- ensure the console is open to see the output
  vim.notify("Crash analysis triggered. Check the GDB console.")
end, { desc = "debug: crash analysis (bt + fault regs)" })
