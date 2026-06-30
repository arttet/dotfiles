# Gemini Guidelines for Neovim Lua Configuration

Read and follow [AGENTS.md](./AGENTS.md) before working in this directory. It is the
canonical source of truth for this configuration's architecture (Neovim 0.12+, built-in
`vim.pack`, no NvChad, native LSP/diagnostics/treesitter), conventions, the `plugin/*.lua`
load model, code style, and the `just nvim *` diagnostics/repair commands.

If anything here ever conflicts with `AGENTS.md`, follow `AGENTS.md`.

## Quick reminders

- Target Neovim 0.12+ APIs only; never reintroduce NvChad, lazy.nvim, or `nvim-lspconfig`.
- One plugin per `plugin/NN-name.lua` (auto-sourced alphabetically). Keep `lua/core/`
  plugin-free. Never hand-edit `nvim-pack-lock.json`.
- Verify changes with `just nvim verify` (or `stylua --check` + `selene` + `luac -p`).
