-- Formatting: conform.nvim. Options (formatters_by_ft, format_on_save, the
-- pwsh_format custom formatter) are reused from lua/configs/conform.lua.

vim.pack.add { { src = "https://github.com/stevearc/conform.nvim" } }

require("conform").setup(require "configs.conform")
