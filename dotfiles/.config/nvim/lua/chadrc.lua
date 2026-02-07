-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua

---@class ChadrcConfig
local M = {}

M.base46 = {
  theme = "gruvbox",
  theme_toggle = { "gruvbox", "gruvbox_light" },
}

M.nvdash = {
  load_on_startup = true,
  header = {
    " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
    " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
    " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
    " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
    " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
    " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
    "                                                       ",
    "                 Powered By  eovim                  ",
    "                                                       ",
  },
}

M.term = {
  float = {
    width = 0.8,
    height = 0.8 * 14 / 16,
    row = 0.1,
    col = 0.1,
  },
}

M.ui = {
  statusline = {
    enabled = true,
    theme = "default",
    separator_style = "arrow",
    order = {
      "mode",
      "file",
      "git",
      "wakatime",
      "%=",
      "lsp_msg",
      "%=",
      "diagnostics",
      "lsp",
      "cwd",
      "cursor",
    },
    modules = {
      wakatime = function()
        return vim.g.wakatime_status or ""
      end,
    },
  },

  tabufline = {
    lazyload = false,
  },
}

return M
