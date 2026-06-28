-- Start screen: mini.starter (replaces NvDash). Set up eagerly because it is the
-- pre-draw content when Neovim opens with no file. mini.nvim added by 10-icons.

vim.pack.add { { src = "https://github.com/echasnovski/mini.nvim" } }

local starter = require "mini.starter"

local header = table.concat({
  " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
  " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
  " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
  " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
  " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
  " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
}, "\n")

starter.setup {
  header = header,
  items = {
    { name = "Find file", action = "Telescope find_files", section = "Telescope" },
    { name = "Live grep", action = "Telescope live_grep", section = "Telescope" },
    { name = "Recent files", action = "Telescope oldfiles", section = "Telescope" },
    { name = "File tree", action = "NvimTreeToggle", section = "Actions" },
    { name = "New file", action = "enew", section = "Actions" },
    { name = "Quit", action = "qa", section = "Actions" },
  },
  content_hooks = {
    starter.gen_hook.adding_bullet(),
    starter.gen_hook.aligning("center", "center"),
  },
}
