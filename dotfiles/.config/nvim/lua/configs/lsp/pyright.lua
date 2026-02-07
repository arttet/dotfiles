-- Python Language Server (Pyright) Configuration
-- https://microsoft.github.io/pyright
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", ".git" },

  settings = {
    pyright = {
      -- Control Pyright’s built-in features
      disableLanguageServices = false,
      disableOrganizeImports = false,
    },
    python = {
      analysis = {
        -- Type checking mode: "off", "basic", "strict"
        typeCheckingMode = "strict",

        -- Enable auto-import suggestions
        autoImportCompletions = true,

        -- Use all files in workspace for diagnostics
        diagnosticMode = "workspace",

        -- Allow reading types from installed libraries
        useLibraryCodeForTypes = true,

        -- Automatically detect and add search paths
        autoSearchPaths = true,
      },
    },
  },
})
