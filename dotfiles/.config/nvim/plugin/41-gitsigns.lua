-- Git signs + line blame. Configured after first draw. Options are reused from
-- the existing lua/configs/gitsigns.lua (which calls gitsigns.setup).

vim.pack.add { { src = "https://github.com/lewis6991/gitsigns.nvim" } }

vim.schedule(function()
  require "configs.gitsigns"
end)
