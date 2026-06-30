-- Editing UX: autopairs, indent guide, TODO highlights, multi-cursor.
-- Replaces nvim-autopairs (-> mini.pairs) and indent-blankline (-> mini.indentscope).

-- vim-visual-multi is a Vimscript plugin that reads g:VM_maps when it is sourced
-- (which `vim.pack.add` does immediately). Set the maps BEFORE the add, not in
-- the deferred block below, or they would be ignored.
require "configs.visual-multi"

vim.pack.add {
  { src = "https://github.com/echasnovski/mini.nvim" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/folke/todo-comments.nvim" },
  { src = "https://github.com/mg979/vim-visual-multi" },
}

vim.schedule(function()
  require("mini.pairs").setup()
  require("mini.indentscope").setup {
    symbol = "│",
    options = { try_as_border = true },
  }

  require("todo-comments").setup {}
end)
