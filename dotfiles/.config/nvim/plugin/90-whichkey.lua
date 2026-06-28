-- Keybinding discovery: which-key. Loaded after first draw.

vim.pack.add { { src = "https://github.com/folke/which-key.nvim" } }

vim.schedule(function()
  require("which-key").setup { preset = "modern" }
end)
