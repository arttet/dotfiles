-- Time tracking: vim-wakatime. The statusline segment + refresh timer live in
-- lua/configs/wakatime.lua (reused). Loaded after first draw.

vim.pack.add { { src = "https://github.com/wakatime/vim-wakatime" } }

vim.schedule(function()
  require "configs.wakatime"
end)
