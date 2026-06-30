-- Icons: mini.icons (eager -- statusline/tabline/tree need it before first draw).
-- Provides a nvim-web-devicons compatibility shim for plugins that expect it.

vim.pack.add { { src = "https://github.com/echasnovski/mini.nvim" } }

require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()
