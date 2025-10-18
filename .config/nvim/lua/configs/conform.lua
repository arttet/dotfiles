-- Configures the conform.nvim plugin for code formatting.
-- Sets up formatters for various file types and defines custom formatters.

local options = {
  formatters_by_ft = {
    bash = { "shfmt" },
    bibtex = { "bibtex-tidy" },
    c = { "clang-format" },
    cmake = { "cmake_format" },
    cpp = { "clang-format" },
    css = { "prettier" },
    fish = { "fish_indent" },
    go = { "goimports", "gofmt" },
    html = { "prettier" },
    javascript = { "prettier" },
    json = { "prettier" },
    json5 = { "prettier" },
    jsonc = { "prettier" },
    lua = { "stylua" },
    make = { "prettier" },
    markdown = { "markdownlint-cli2" },
    nix = { "nixfmt" },
    powershell = { "pwsh_format" },
    proto = { "buf" },
    ps1 = { "pwsh_format" },
    python = { "ruff_format" },
    rust = { "rustfmt" },
    sql = { "sql_formatter" },
    terraform = { "terraform_fmt" },
    tex = { "tex-fmt" },
    toml = { "taplo" },
    xml = { "xmlformatter" },
    yaml = { "yamlfmt" },
    zig = { "zigfmt" },
  },

  formatters = {
    pwsh_format = {
      command = "pwsh",
      args = {
        "-NoLogo",
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        vim.fn.fnamemodify(vim.fn.stdpath "config" .. "/scripts/format-powershell.ps1", ":p"),
      },
      stdin = true,
    },
  },

  format_on_save = {
    timeout_ms = 1000,
    lsp_fallback = true,
  },
}

return options
