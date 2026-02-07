-- Configures the vim-visual-multi plugin.
-- Sets up key mappings for multiple cursors and disables them in the NvimTree buffer.

vim.g.VM_maps = {
  ["Find Under"] = "<M-n>", -- Alt+n
  ["Find Subword Under"] = "<M-n>",
  ["Add Cursor Down"] = "<M-Down>", -- Alt+↓
  ["Add Cursor Up"] = "<M-Up>", -- Alt+↑
  ["Select All"] = "<M-a>", -- Alt+a
  ["Skip Region"] = "<M-x>", -- Alt+x
  ["Remove Region"] = "<M-q>", -- Alt+q
}

-- Disable VisualMulti keybindings in nvim-tree
vim.api.nvim_create_autocmd("FileType", {
  pattern = "NvimTree",
  callback = function()
    vim.b.VM_disable_mappings = true
  end,
})
