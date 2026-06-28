-- Editor options.
-- Replaces `require "nvchad.options"` with an explicit baseline plus the custom
-- UI/editor tweaks that used to live in lua/options.lua.

local o = vim.o
local g = vim.g

-- UI
o.termguicolors = true
o.number = true
o.relativenumber = true
o.numberwidth = 2
o.ruler = false
o.signcolumn = "yes"
o.cursorline = true
o.cursorlineopt = "both" -- highlight both number and text
o.scrolloff = 8
o.sidescrolloff = 8
o.pumheight = 10
o.pumblend = 0
o.showmode = false -- mode is shown in the statusline
o.laststatus = 3 -- global statusline
o.cmdheight = 1
o.splitbelow = true
o.splitright = true
o.splitkeep = "screen" -- keep window layout stable when splitting
o.fillchars = "eob: "

-- Whitespace visualization
o.list = true
o.listchars = "space:·,tab:→ ,trail:·,nbsp:·,extends:»,precedes:«"

-- Search
o.ignorecase = true
o.smartcase = true
o.hlsearch = true
o.incsearch = true

-- Indentation
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.smartindent = true
o.autoindent = true

-- Editing behavior
o.mouse = "a"
o.clipboard = "unnamedplus" -- sync with system clipboard
o.virtualedit = "block"
o.undofile = true
o.swapfile = false
o.updatetime = 250
o.timeoutlen = 400
o.wrap = false
o.confirm = true

-- Folding (driven by treesitter in ftplugin/*).
o.foldlevel = 99
o.foldlevelstart = 99
o.foldenable = true

-- Native completion (0.12). blink.cmp owns the popup, so leave autocomplete off
-- to avoid a double menu, but keep a sensible completeopt for both paths.
o.autocomplete = false
o.completeopt = "menu,menuone,noselect,fuzzy"
o.pumborder = "rounded"

-- Session persistence (was set in the old init.lua).
o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

g.base46_cache = nil -- NvChad theme cache is gone; guard any stragglers.

-- DAP signs and highlights (sign_define for DAP is unaffected by the 0.12
-- diagnostic sign_define removal). Ported verbatim from the old options.lua.
local dap_sign = vim.fn.sign_define
dap_sign("DapBreakpoint", { text = "", texthl = "DapBreakpointColor", linehl = "", numhl = "" })
dap_sign("DapStopped", { text = "", texthl = "DapStoppedColor", linehl = "CursorLine", numhl = "" })
dap_sign("DapBreakpointRejected", { text = "", texthl = "DapRejectedColor", linehl = "", numhl = "" })
dap_sign("DapBreakpointCondition", { text = "", texthl = "DapConditionColor", linehl = "", numhl = "" })

local dap_hl = vim.api.nvim_set_hl
dap_hl(0, "DapBreakpointColor", { fg = "#FF0000", bold = true })
dap_hl(0, "DapStoppedColor", { fg = "#00FF00", bold = true })
dap_hl(0, "DapRejectedColor", { fg = "#FFA500", bold = true })
dap_hl(0, "DapConditionColor", { fg = "#00FFFF", bold = true })
