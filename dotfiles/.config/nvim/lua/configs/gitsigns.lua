-- Configures the gitsigns.nvim plugin.
-- Enables current line blame and sets its options.

require("gitsigns").setup {
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol",
    delay = 1000,
    ignore_whitespace = false,
  },
}
