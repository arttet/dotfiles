-- Tool installer: mason + mason-tool-installer (installs LSP servers, DAP
-- adapters, formatters, linters). Kept purely as an installer; the LSP servers
-- themselves are configured natively in lua/configs/lsp/. Loaded after first
-- draw. The tool list is reused from lua/configs/meson.lua.

vim.pack.add {
  { src = "https://github.com/williamboman/mason.nvim" },
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
}

vim.schedule(function()
  require("mason").setup()
  -- configs.meson returns a setup function (registers mason-tool-installer).
  local setup_tools = require "configs.meson"
  setup_tools()
end)
