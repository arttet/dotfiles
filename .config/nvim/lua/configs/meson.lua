-- Configures the mason-tool-installer.nvim plugin.
-- Defines the list of LSP servers, DAP adapters, formatters, and linters to be installed by Mason.

local function setup_mason_tools()
  local mason_installer = require "mason-tool-installer"

  local tools = {
    -- LSP Servers
    "ansiblels",
    "asm_lsp",
    "bashls",
    "buf_ls",
    "clangd",
    "cssls",
    "docker-compose-language-service",
    "dockerfile-language-server",
    "eslint",
    "gh-actions-language-server",
    "gitlab-ci-ls",
    "glsl_analyzer",
    "gopls",
    "graphql",
    "helm-ls",
    "html",
    "hyprls",
    "json-lsp",
    "julia-lsp",
    "lemminx",
    "ltex-ls",
    "lua-language-server",
    "marksman",
    "neocmake",
    "postgres-lsp",
    "pyright",
    "ruff",
    "rust-analyzer",
    "solidity",
    "sqls",
    "taplo",
    "terraform-ls",
    "typescript-language-server",
    "vim-language-server",
    "yaml-language-server",
    "zls",

    -- DAP Adapters
    "debugpy",
    "codelldb",

    -- Formatters
    "bibtex-tidy",
    "buf",
    "clang-format",
    "gofmt",
    "goimports",
    "markdownlint-cli2",
    "nixfmt",
    "prettier",
    "ruff",
    "rustfmt",
    "shfmt",
    "sql-formatter",
    "stylua",
    "taplo",
    "terraform-fmt",
    "tex-fmt",
    "xmlformatter",
    "yamlfmt",

    -- Linters
    "shellcheck",
    "pylint",
    "eslint_d",
  }

  local config = {
    ensure_installed = tools,
    auto_update = true,
    run_on_start = true,
    start_delay = 3000,
  }

  mason_installer.setup(config)
end

return setup_mason_tools
