-- Rust Analyzer Configuration
-- https://rust-analyzer.github.io/
vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json" },

  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
        loadOutDirsFromCheck = true,
        runBuildScripts = true,
      },
      checkOnSave = {
        command = "clippy",
        extraArgs = { "--", "-W", "clippy::pedantic" },
      },
      procMacro = {
        enable = true,
      },
    },
  },
})
