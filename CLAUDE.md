# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```sh
# Format all code (dprint, stylua, shfmt, justfile)
just fmt

# Run all linters (selene, shellcheck, yamllint, markdownlint, actionlint)
just lint

# Preview dotfiles deployment (dry-run)
just check

# Deploy dotfiles via dotter (symlinks into $HOME)
just deploy

# Sync external plugins/themes via vendir
just sync

# Benchmark shell startup times
just bench

# Docs dev server
just docs serve
```

## Architecture

### Dotfiles deployment

Dotfiles live under `dotfiles/` and are deployed to `$HOME` as symlinks via **dotter** (configured in `.dotter/global.toml`). The `default` profile maps `dotfiles/.config/` → `~/.config/`. The `bash` and `zsh` profiles handle shell RC files. Alternatively, `just install` / `just uninstall` use GNU stow against the same tree.

External plugins and themes (alacritty themes, yazi flavors/plugins) are vendored via **vendir** (`vendir.yml`) and should be updated with `just sync`, not edited by hand. Their paths are excluded from dprint formatting.

### Shell configuration

Shell configs follow XDG conventions. Shared shell logic lives in `dotfiles/.config/shell/shell.d/` (aliases, functions, git helpers, etc.) and is sourced by each shell's RC file. Shell-specific configs are in `dotfiles/.config/bash/`, `dotfiles/.config/zsh/`, and `dotfiles/.config/nushell/` (with a modules directory for nushell).

### Neovim configuration

`dotfiles/.config/nvim/` is a **NvChad**-based config using **lazy.nvim**. Requires Neovim 0.11+. Structure:

- `init.lua` — bootstraps lazy.nvim
- `lua/options.lua`, `lua/mappings.lua`, `lua/autocmds.lua` — core settings
- `lua/chadrc.lua` — NvChad overrides
- `lua/configs/` — per-plugin configs (lsp/, dap/, conform, treesitter, etc.)
- `lua/plugins/init.lua` — plugin specs

Use `vim.uv` not `vim.loop`. Use `vim.keymap.set` not `vim.api.nvim_set_keymap`.

### Formatting

- **Lua**: stylua (config: `.stylua.toml`)
- **Shell** (bash/zsh): shfmt
- **JSON, YAML, TOML, Markdown, TypeScript**: dprint (config: `dprint.json`, line width 120)
- **Justfile**: `just --fmt`

### CI pipeline

`.github/workflows/ci.yml` runs three parallel stage-1 jobs (fmt, lint, security) gating a docs build + deploy. Security scanning uses TruffleHog, Trivy, and Semgrep.

### Documentation

VitePress site in `docs/`, built with Bun. Managed via `just docs serve/build/preview`.

## Key constraints from AGENT.md

- **No secrets in configs**: use environment variable references (`${VAR}`) or system keychain — never literal tokens or keys.
- **No `.` in PATH**: avoid current-directory or world-writable PATH entries.
- **Shell startup budget**: Zsh/Bash < 100ms, Nushell < 200ms. Lazy-load expensive initializations (pyenv, rbenv, etc.).
- **Quoted variables**: always quote variable expansions in shell scripts; use `${VAR:?}` for required vars.
- **XDG compliance**: all tool configs must use XDG base directories (`~/.config`, `~/.local/share`, `~/.cache`).
