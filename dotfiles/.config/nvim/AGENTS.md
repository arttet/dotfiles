# AI Agent Guidelines for Neovim Lua Configuration

Expert guidance for AI agents working with this Neovim configuration (Lua).

## Requirements

- **Minimum Neovim Version**: 0.12 (latest stable; this config uses 0.12-only APIs)
- **Language**: Lua
- **Plugin Manager**: built-in `vim.pack` (no NvChad, no lazy.nvim)
- **Toolchain on PATH**: `git`, a C compiler (`cc`/`gcc`/`clang`), `tree-sitter` CLI
  (for treesitter parsers), plus `ripgrep` + `fd` (telescope). Run `just nvim doctor`
  to verify the environment before debugging anything else.

## Compatibility Notes

- Use only APIs available in Neovim 0.12+ (`vim.pack`, `vim.lsp.config`/`enable`,
  `vim.diagnostic.config{ signs = { text = {} } }`, `vim.treesitter.start`,
  `vim.text.diff`). Do not reintroduce `vim.loop` (use `vim.uv`) or `nvim-lspconfig`
  wrappers.
- The diagnostic `sign_define` path was removed in 0.12 — configure signs via
  `vim.diagnostic.config`. (DAP still uses `vim.fn.sign_define`, which is fine.)
- `vim.treesitter.get_parser()` returns `nil` instead of throwing — guard callers.

## Configuration Structure

```text
init.lua                  # vim.loader.enable(); leader; netrw off; require("core")
nvim-pack-lock.json       # vim.pack lockfile (committed; never hand-edit)
lua/core/                 # plugin-independent setup (pure 0.12 APIs)
  init.lua                #   loads options/diagnostics/autocmds/keymaps + configs.lsp
  options.lua, diagnostics.lua, autocmds.lua, keymaps.lua
  dap.lua                 #   on-demand DAP loader (installs the debug stack on first use)
lua/configs/              # reused plugin option modules (lsp/, dap/, conform, treesitter, ...)
plugin/NN-name.lua        # one plugin per file, AUTO-SOURCED ALPHABETICALLY at startup
ftplugin/                 # (optional) per-filetype tweaks
```

**Load model:** `plugin/*.lua` files are sourced alphabetically after `init.lua`, so the
numeric filename prefix (`00`, `10`, …) _is_ the load order. Each file is one
`vim.pack.add { ... }` followed by the plugin's `setup`. There is no event/ft/cmd lazy
loading built into `vim.pack`; lazy loading here means deferring `require(...).setup()`
with `vim.schedule(...)` or a `once`-autocmd (see `plugin/50-completion.lua`,
`lua/core/dap.lua`).

## vim.pack essentials

```lua
vim.pack.add {
  "https://github.com/owner/plugin",                              -- string spec
  { src = "https://github.com/owner/plugin", version = "main" },  -- branch/tag/commit
  { src = "https://github.com/owner/plugin", name = "alias" },    -- install-dir override
}
require("plugin").setup(opts) -- vim.pack does NOT auto-call setup(); you do.
```

- Lifecycle: `vim.pack.get()`, `vim.pack.update([names],{force=true})`, `vim.pack.del{}`.
- Install hooks are `PackChanged` autocmds (`ev.data = {spec, kind, active, path}`,
  `kind ∈ {install, update, delete}`). **Register a hook BEFORE the `add()` it must fire
  for** (so it also runs on fresh-machine lockfile bootstrap). See
  `plugin/20-treesitter.lua` (TSUpdate) and `lua/core/dap.lua` (lua-json5 build).
- Plugins needed before first redraw (colorscheme, icons, statusline/tabline,
  treesitter) are eager; everything else defers.

## LSP

Native only. Per-server presets live in `lua/configs/lsp/<name>.lua` and call
`vim.lsp.config(name, {...})`. `lua/configs/lsp/init.lua` sets shared capabilities +
on-attach keymaps (`LspAttach`) and `vim.lsp.enable(servers)`. Mason is kept purely as a
tool installer (`plugin/45-mason.lua`, list in `lua/configs/meson.lua`). Native maps
`grn/gra/grr/gri/grt/gO` and `<C-S>` already exist; add only deltas.

## Treesitter

`nvim-treesitter` **`main`** branch (the `master` API `configs.setup()` is gone). Parsers
are installed via `require("nvim-treesitter").install(list)` and compiled locally; the
list is in `lua/configs/treesitter.lua`. Highlight/fold are enabled per-filetype with
`vim.treesitter.start()` in `plugin/20-treesitter.lua`.

## Diagnostics & commands

- `just nvim doctor` — environment sanity (run first).
- `just nvim verify` — syntax + load + lsp gate.
- `just nvim sandbox` — launch the sandboxed instance against this config.
- `just nvim pack-status|pack-update|pack-restore` — lockfile state / update / undo.
- `just nvim ts-check|ts-install`, `just nvim lsp-check`, `just nvim startuptime`.
- `just nvim clean|bootstrap-test` — repair / prove fresh-machine reproduction.
- `just nvim fmt|lint` — stylua + selene.

## Code Style

- 2-space indent; prefer double quotes; trailing commas on multi-line tables.
- `function()` not `function ()`; snake_case names; `--` / `--[[ ]]` comments.
- Format with `stylua` (`.stylua.toml`); lint with `selene` (`selene.toml`, `std = "vim"`).
- Use `vim.keymap.set`, `vim.uv`, and guard fallible plugin requires with `pcall`.

## Agent Instructions

1. **Preserve structure:** one plugin per `plugin/*.lua`; keep `core/` plugin-free.
2. **Never hand-edit `nvim-pack-lock.json`.**
3. **`vim.loader.enable()` stays the first line of `init.lua`.**
4. Register install hooks before the `add()` they target.
5. Verify changes: `just nvim verify` (or `stylua --check` + `selene` + `luac -p`).
6. Minimal diffs; match existing patterns; use modern 0.12 APIs.

## Resources

- `:h vim.pack` · `:h vim.pack-examples` · `:h news-0.12` · `:h deprecated-0.12`
- `:h lsp` · `:h diagnostic-signs` · `:h vim.treesitter`
- nvim-treesitter `main`: <https://github.com/nvim-treesitter/nvim-treesitter/tree/main>
