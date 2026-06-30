-- Diagnostics configuration.
-- Uses the 0.12 signs API (`signs = { text = {...} }`); the old `sign_define`
-- path for diagnostics was removed in 0.12.

local S = vim.diagnostic.severity

vim.diagnostic.config {
  severity_sort = true,
  update_in_insert = false,
  underline = true,
  virtual_text = {
    prefix = "●",
    spacing = 2,
    source = "if_many",
  },
  float = {
    border = "rounded",
    source = "if_many",
    header = "",
  },
  signs = {
    text = {
      [S.ERROR] = "",
      [S.WARN] = "",
      [S.INFO] = "",
      [S.HINT] = "󰌶",
    },
  },
}
