-- Neovim editor options and behavior configuration
-- Extends NvChad defaults with custom UI and editor settings

require "nvchad.options"

-- Additional UI enhancements
local o = vim.o

-- Whitespace Visualization
o.list = true -- Enable special characters display
o.listchars = "space:·,tab:→ ,trail:·,nbsp:·,extends:»,precedes:«"

-- Editor Behavior
o.splitkeep = "screen" -- Maintain window layout when splitting
o.cursorlineopt = "both" -- Highlight line number and text
o.relativenumber = true -- Show relative line numbers
o.number = true -- Show absolute line number for current line
o.virtualedit = "block"

-- Indentation Settings
o.shiftwidth = 2 -- Size of indent (spaces)
o.tabstop = 2 -- Number of spaces per tab
o.softtabstop = 2 -- Number of spaces for <Tab> in insert mode
o.expandtab = true -- Convert tabs to spaces
o.smartindent = true -- Auto-indent new lines

-- Clipboard Integration
o.clipboard = "unnamedplus" -- Sync with system clipboard (requires +clipboard)

-- Debugging (DAP)
local dap_sign = vim.fn.sign_define
dap_sign("DapBreakpoint", { text = "", texthl = "DapBreakpointColor", linehl = "", numhl = "" })
dap_sign("DapStopped", { text = "", texthl = "DapStoppedColor", linehl = "CursorLine", numhl = "" })
dap_sign("DapBreakpointRejected", { text = "", texthl = "DapRejectedColor", linehl = "", numhl = "" })
dap_sign("DapBreakpointCondition", { text = "", texthl = "DapConditionColor", linehl = "", numhl = "" })

local dap_hl = vim.api.nvim_set_hl
dap_hl(0, "DapBreakpointColor", { fg = "#FF0000", bold = true })
dap_hl(0, "DapStoppedColor", { fg = "#00FF00", bold = true })
dap_hl(0, "DapRejectedColor", { fg = "#FFA500", bold = true })
dap_hl(0, "DapConditionColor", { fg = "#00FFFF", bold = true })
