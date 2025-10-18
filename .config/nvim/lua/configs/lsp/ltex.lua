-- LTeX Configuration (Grammar & Spell Check)
-- https://github.com/valentjn/ltex-ls
vim.lsp.config("ltex", {
  cmd = { "ltex-ls" },
  filetypes = { "markdown", "text", "tex", "latex", "rst" },
  root_markers = { ".git" },

  settings = {
    ltex = {
      additionalRules = {},
      dictionary = {
        ["en-US"] = {
          "Neovim",
        },
      },
      disabledRules = {
        ["en-US"] = {},
      },
      enabled = true,
      language = "en-US",
    },
  },
})
