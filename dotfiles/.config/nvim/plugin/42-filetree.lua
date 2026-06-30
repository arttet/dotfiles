-- File explorer: nvim-tree (replaces netrw, disabled in init.lua).
-- Configured after first draw. Toggle/focus keymaps live in core/keymaps.lua.

vim.pack.add { { src = "https://github.com/nvim-tree/nvim-tree.lua" } }

vim.schedule(function()
  require("nvim-tree").setup {
    hijack_cursor = true,
    view = { width = 32 },
    renderer = { group_empty = true, highlight_git = true },
    filters = { dotfiles = false },
    git = { enable = true },
    actions = { open_file = { quit_on_open = false } },
  }
end)
