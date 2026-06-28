-- Colorscheme: gruvbox (eager -- needed before the first redraw).
-- Replaces NvChad's base46 engine + gruvbox/gruvbox_light toggle. The dark/light
-- toggle keymap lives in lua/core/keymaps.lua (`<leader>th`).

vim.pack.add { { src = "https://github.com/ellisonleao/gruvbox.nvim" } }

local ok, gruvbox = pcall(require, "gruvbox")
if ok then
  gruvbox.setup {
    contrast = "hard",
    italic = { strings = false, comments = true, operators = false, folds = true },
  }
end

vim.o.background = "dark"
pcall(vim.cmd.colorscheme, "gruvbox")
