-- Configures the mason-tool-installer.nvim plugin.
-- Defines the list of LSP servers, DAP adapters, formatters, and linters to be installed by Mason.

local function setup_mason_tools()
  local mason_installer = require "mason-tool-installer"

  local tools = {
    -- LSP Servers (Mason package names, not vim.lsp.config server names).
    "ansible-language-server",
    "asm-lsp",
    "bash-language-server",
    "buf",
    "clangd",
    "css-lsp",
    "docker-compose-language-service",
    "dockerfile-language-server",
    "eslint-lsp",
    "gh-actions-language-server",
    "gitlab-ci-ls",
    "glsl_analyzer",
    "gopls",
    "graphql-language-service-cli",
    "helm-ls",
    "html-lsp",
    "hyprls",
    "json-lsp",
    "julia-lsp",
    "lemminx",
    "ltex-ls",
    "lua-language-server",
    "marksman",
    "neocmakelsp",
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

    -- Formatters (only tools available in Mason; gofmt/rustfmt come with their
    -- toolchains and are expected to be on PATH when needed).
    "bibtex-tidy",
    "buf",
    "clang-format",
    "goimports",
    "markdownlint-cli2",
    "nixfmt",
    "prettier",
    "ruff",
    "shfmt",
    "sql-formatter",
    "stylua",
    "taplo",
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
    -- Defer installation to avoid blocking startup or failing when a package
    -- name changes; run :MasonToolsInstall manually when needed.
    run_on_start = false,
    start_delay = 3000,
  }

  mason_installer.setup(config)
end

return setup_mason_tools
