-- Statusline + tabline: mini.statusline / mini.tabline (eager -- visible at draw).
-- Replaces NvChad's statusline/tabufline. Keeps the wakatime segment and uses
-- native diagnostic/LSP info. mini.nvim is already added by 10-icons.lua.

vim.pack.add { { src = "https://github.com/echasnovski/mini.nvim" } }

local MiniStatusline = require "mini.statusline"

MiniStatusline.setup {
  use_icons = true,
  content = {
    active = function()
      local mode, mode_hl = MiniStatusline.section_mode { trunc_width = 120 }
      local git = MiniStatusline.section_git { trunc_width = 75 }
      local diff = MiniStatusline.section_diff { trunc_width = 75 }
      local diagnostics = MiniStatusline.section_diagnostics { trunc_width = 75 }
      local lsp = MiniStatusline.section_lsp { trunc_width = 75 }
      local filename = MiniStatusline.section_filename { trunc_width = 140 }
      local fileinfo = MiniStatusline.section_fileinfo { trunc_width = 120 }
      local location = MiniStatusline.section_location { trunc_width = 75 }
      local wakatime = vim.g.wakatime_status or ""

      return MiniStatusline.combine_groups {
        { hl = mode_hl, strings = { mode } },
        { hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics, lsp } },
        "%<",
        { hl = "MiniStatuslineFilename", strings = { filename } },
        "%=",
        { hl = "MiniStatuslineFilename", strings = { wakatime } },
        { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
        { hl = mode_hl, strings = { location } },
      }
    end,
  },
}

require("mini.tabline").setup()
