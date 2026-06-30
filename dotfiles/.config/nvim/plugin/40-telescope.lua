-- Fuzzy finder: telescope (+ plenary). Installed eagerly (cheap once present),
-- configured after first draw. Keymaps live in lua/core/keymaps.lua.

vim.pack.add {
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
}

vim.schedule(function()
  require("telescope").setup {
    defaults = {
      prompt_prefix = "   ",
      selection_caret = " ",
      sorting_strategy = "ascending",
      layout_config = { prompt_position = "top", horizontal = { width = 0.9 } },
    },
  }
end)
