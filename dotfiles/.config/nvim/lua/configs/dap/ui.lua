local dap = require "dap"
local dapui = require "dapui"

-- Initialize DAP UI
dapui.setup {
  icons = { expanded = "▾", collapsed = "▸" },
}

-- Auto-open DAP UI on debug start
dap.listeners.after.event_initialized["dapui_config"] = function()
  require("nvim-tree.api").tree.close()
  require("nvim-dap-virtual-text").refresh()
  dapui.open()

  local config = dap.session().config
  local message = string.format("🚀 Debugging started with config:\nName: %s", config.name)
  vim.notify(message, vim.log.levels.INFO, {
    title = "DAP Config",
    timeout = 2000,
  })
end

dap.listeners.before.event_terminated["dapui_config"] = function()
  -- dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
  -- dapui.close()
end

-- Virtual text setup
require("nvim-dap-virtual-text").setup {
  enabled = true,
  enabled_commands = true,
  highlight_changed_variables = true,
  highlight_new_as_changed = false,
  show_stop_reason = true,
  commented = false,
  virt_text_pos = "inline",
}

return {}
