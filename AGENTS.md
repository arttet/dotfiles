# Dotfiles — Agent Guide

This file is the canonical source of truth for repository-wide AI agent instructions. `CLAUDE.md` is the
tool-specific entry point that must reference this guide instead of duplicating its rules. If an adapter conflicts with
this file, follow `AGENTS.md`.

This repository is a personal, cross-platform dotfiles configuration for Artyom Tetyukhin (`@arttet`). It manages shell, terminal, editor, window-manager, and AI-tool configurations, deploying them to `$HOME` as symlinks.

## Project Overview

- **Repository**: `https://github.com/arttet/dotfiles`
- **Maintainer**: `@arttet` (see `.github/CODEOWNERS`)
- **Primary language of documentation and comments**: English
- **Deployment model**: Symlink-based dotfiles deployed with **dotter** (`just deploy`) or GNU **stow** (`just install`/`uninstall`)
- **External assets**: Plugins, themes, and wallpapers are vendored with **vendir** (`vendir.yml` + `vendir.lock.yml`, plus `vendir.lock.windows.yml` for Windows path handling)
- **Task runner**: `just` (`Justfile`)
- **Documentation site**: VitePress under `docs/`, served via Bun (`just docs dev`)
- **NixOS integration**: `nixos/home.nix` links selected dotfiles into a Home Manager generation

## Repository Layout

```text
.
├── .dotter/              # dotter deployment configuration
│   └── global.toml       # package/profiles and file mappings
├── .github/              # CI/CD workflows and Dependabot config
│   └── workflows/ci.yml  # validation, security, docs, deployment
├── docs/                 # VitePress documentation site
│   ├── package.json      # Bun-based dev dependencies
│   ├── .vitepress/config.ts
│   └── src/              # markdown content
├── dotfiles/             # actual dotfile contents (deployed to $HOME)
│   ├── .bash_profile
│   ├── .bashrc
│   ├── .zshenv
│   ├── .config/          # XDG_CONFIG_HOME tree
│   │   ├── alacritty/    # terminal config + vendored Catppuccin themes
│   │   ├── bash/         # bash-specific interactive/login scripts
│   │   ├── bat/
│   │   ├── claude/       # Claude Code settings
│   │   ├── codex/        # OpenAI Codex CLI settings
│   │   ├── ghostty/      # terminal config
│   │   ├── git/          # gitconfig, allowed_signers, ignore
│   │   ├── helix/        # editor config
│   │   ├── hypr/         # Hyprland (Lua) + wallpapers (vendored)
│   │   ├── kimi-code/    # Kimi Code settings
│   │   ├── nushell/      # modules/ + scripts/ + config.nu/env.nu
│   │   ├── nvim/         # NvChad-based Neovim config
│   │   ├── powershell/   # profile.ps1, config.ps1, aliases, functions
│   │   ├── shell/        # POSIX shared shell logic
│   │   │   ├── profile.d/00-profile.sh
│   │   │   └── shell.d/  # aliases, functions, git helpers, theme, OS tweaks
│   │   ├── starship/     # prompt configs (main, tmux, zellij)
│   │   ├── tmux/         # tmux.conf + vendored TPM
│   │   ├── wezterm/
│   │   ├── yazi/         # file manager config + vendored plugins/flavors
│   │   ├── zed/
│   │   ├── zellij/
│   │   └── zsh/          # zsh-specific scripts
│   └── .ssh/config
├── misc/                 # additional Just modules
│   └── justfiles/docs.just
├── nixos/
│   └── home.nix          # Home Manager links for NixOS
├── scripts/              # (currently empty directory)
├── Justfile              # primary task definitions
├── vendir.yml            # external dependency specifications
├── vendir.lock.yml       # pinned external dependency versions
├── vendir.lock.windows.yml # Windows-specific lock file (backslash paths)
├── dprint.json           # formatter config
├── .stylua.toml          # Lua formatter config
├── selene.toml           # Lua linter config
├── .markdownlint-cli2.jsonc
├── .stylelintrc.json
├── .yamllint.yml
├── .lychee.toml          # docs link-checker config
├── AGENTS.md           # this agent guide
└── CLAUDE.md             # Claude Code specific guidance
```

## Technology Stack

### Shells (all configured)

- **Nushell** — primary cross-platform shell (`dotfiles/.config/nushell/`)
- **Zsh** — `dotfiles/.config/zsh/`, sourced via `$ZDOTDIR`
- **Bash** — `dotfiles/.config/bash/`
- **PowerShell** — `dotfiles/.config/powershell/`

### Terminals

- **Ghostty** (`dotfiles/.config/ghostty/config`)
- **WezTerm** (`dotfiles/.config/wezterm/wezterm.lua`)
- **Alacritty** (`dotfiles/.config/alacritty/alacritty.toml`)
- **Windows Terminal** fragment (`dotfiles/.config/windows-terminal/fragments/dotfiles.json`)

All terminal emulators default to **Nushell** (`nu --login --interactive`) on supported platforms and share unified parameters: IosevkaTerm Nerd Font, 13 pt, 5 px padding, 0.95 opacity, 10000 scrollback.

### Editors

- **Neovim** — NvChad v2.5 base with `lazy.nvim`, Neovim 0.11+ required (`dotfiles/.config/nvim/`)
- **Helix** (`dotfiles/.config/helix/`)
- **Zed** (`dotfiles/.config/zed/settings.json`)

### Multiplexers & Window Management

- **Zellij** (`dotfiles/.config/zellij/config.kdl`) — default shell `nu`
- **Tmux** (`dotfiles/.config/tmux/tmux.conf`) — TPM plugins vendored under `dotfiles/.config/tmux/plugins/tpm`
- **Hyprland** — Lua-configured Wayland compositor (`dotfiles/.config/hypr/hyprland.lua`)

### Prompt & Navigation

- **Starship** — three configs for main, tmux, and zellij contexts
- **Zoxide** — initialized via cached init scripts in bash/zsh; generated into Nushell autoload
- **FZF** — configured in `profile.d/00-profile.sh` and Nushell `env.nu`

### AI Tool Configs

- `.config/claude/settings.json` — Claude Code permissions + statusline
- `.config/claude/keybindings.json` — Claude Code keybindings
- `.config/codex/config.toml`
- `.config/kimi-code/config.toml` + `tui.toml` + `mcp.json` + `themes/nord.json`
- `.config/opencode/`

These files contain placeholders for credentials (empty `api_key`, OAuth file storage) and must not receive literal secrets.

## Build, Test, and Development Commands

All commands are run from the repository root via `just`.

```sh
# Help
just help

# Dotfiles deployment
just sync          # vendir sync --locked
just check         # dotter dry-run preview
just deploy        # dotter deploy --verbose --force
just undeploy      # dotter undeploy
just install       # stow -v --target=${HOME} dotfiles  (Unix only)
just uninstall     # stow -v --delete --target=${HOME} dotfiles (Unix only)

# Formatting
just fmt           # dprint fmt + stylua + shfmt + just --fmt

# Linting
just lint          # selene + shellcheck + yamllint + markdownlint + actionlint + stylelint

# Docs
just docs dev      # VitePress dev server (port 5173)
just docs build    # VitePress production build
just docs preview  # preview production build

# Performance
just bench         # hyperfine benchmarks for bash, zsh, nu, pwsh

# Dependencies
just deps          # install actionlint via go install
```

## Code Style Guidelines

### Formatters

| Language / File type                   | Tool         | Config                                                                                                          |
| -------------------------------------- | ------------ | --------------------------------------------------------------------------------------------------------------- |
| JSON, YAML, TOML, Markdown, TypeScript | `dprint`     | `dprint.json` (line width 120, LF, 2 spaces)                                                                    |
| Lua (Neovim/Nushell/Yazi)              | `stylua`     | `.stylua.toml` (120 cols, Unix LF, 2 spaces, auto-prefer double quotes)                                         |
| Shell (bash/zsh)                       | `shfmt`      | called via `just fmt` on `dotfiles/.bashrc`, `.bash_profile`, `dotfiles/.config/bash`, `dotfiles/.config/shell` |
| Justfile                               | `just --fmt` | `Justfile`                                                                                                      |
| CSS                                    | `stylelint`  | `.stylelintrc.json` (currently no rules)                                                                        |

### Shell scripting conventions

- Quote variable expansions: `"${VAR}"` or `"${VAR:?}"` for required variables.
- Avoid adding `.` or world-writable directories to `PATH`.
- Prefer `command -v` checks before running optional tools.
- XDG Base Directory compliance is required: configs in `~/.config`, data in `~/.local/share`, state in `~/.local/state`, cache in `~/.cache`.
- Do not hardcode secrets; use environment variables, system keychain, or OAuth file storage.

### Lua / Neovim conventions

- Target Neovim 0.11+.
- Use `vim.uv`, not `vim.loop`.
- Use `vim.keymap.set`, not `vim.api.nvim_set_keymap`.
- Plugin specs live in `dotfiles/.config/nvim/lua/plugins/`.
- Per-plugin configs live in `dotfiles/.config/nvim/lua/configs/`.

## Testing Instructions

Local validation mirrors the CI pipeline:

```sh
# Format check
just fmt
dprint check
just --fmt --check

# Lint
just lint

# Validate vendored deps are present
just sync

# Validate dotfiles can be deployed
just check
```

The GitHub Actions workflow (`.github/workflows/ci.yml`) runs the following gates:

- **Stage 1** (parallel):
  - `fmt` — dprint check + justfile format check
  - `lint` — yamllint, actionlint, stylelint
  - `security` — TruffleHog secret scan, Trivy filesystem scan (secrets/misconfig), SARIF upload
  - `antivirus` — ClamAV scan
  - `docs` — Bun install, audit, VitePress build, Lychee link check
- **Stage 2** (gated by Stage 1):
  - `hyprland` — `hyprland --verify-config`
  - `neovim` — syntax check + headless `Lazy! sync`
  - `helix` — `hx --health all`
  - `ghostty` — `ghostty +validate-config`
  - `alacritty` — `alacritty migrate --dry-run`
  - `nushell` — `nu --config ... --env-config ... -c "exit 0"`
  - `yazi` — `yazi --debug`
  - `starship` — `starship print-config` for all three configs
  - `zellij` — `zellij --config ... setup --dump-config`
  - `bash` — `bash -n` on all bash files
  - `zsh` — `zsh -n` on all zsh files
  - `stow` — symlink verification
- **Stage 3**:
  - `deploy` — publish docs to GitHub Pages (only on `main`, not scheduled)

## Deployment Architecture

### dotter (primary)

`.dotter/global.toml` defines profile groups and per-tool file mappings:

- `default` → `agent`, `editor`, `shell`, `terminal`
- `agent` → `agents`, `opencode`, `claude`, `codex`, `kimi`
- `editor` → `helix`, `zed`
- `shell` → `bash`, `powershell`, `zsh`
- `terminal` → `alacritty`, `windows-terminal`

Default target type is `symbolic`. Windows-only paths use `if = "dotter.windows"`.

### stow (alternative)

`just install` / `uninstall` run `stow` against the `dotfiles/` tree directly. The CI `stow` job verifies that expected paths are symlinks.

### NixOS / Home Manager

`nixos/home.nix` builds a fixed list of out-of-store symlinks via `config.lib.file.mkOutOfStoreSymlink` and asserts every target exists. It covers the Linux/Wayland subset of the dotfiles.

## External Dependencies (vendir)

`vendir.yml` pins external repositories into `dotfiles/.config/`:

- Alacritty Catppuccin themes
- Tmux Plugin Manager (TPM)
- Yazi flavors and plugins (catppuccin, chmod, copy-file-contents, full-border, git, ouch, piper, starship, toggle-pane, torrent-preview, yaziline)
- Hyprland wallpapers (catppuccin, graphite, nord, whitesur, mactahoe)

**Rule**: update these with `just sync` / `just update`, not by hand. `just sync` uses `--locked` for reproducibility; `just update` re-resolves refs and rewrites `vendir.lock.yml` (and `vendir.lock.windows.yml` on Windows). Vendored paths are excluded from formatting and linting.

> `vendir.lock.windows.yml` is kept because `vendir` on Windows normalizes paths to backslashes while the committed `vendir.lock.yml` uses forward slashes. `just sync` selects the appropriate lock file automatically.

> Known issue (see `TODO.md`): `vendir sync` can fail on Windows with access-denied errors on its temp clone.

## Security Considerations

- **No secrets in version control**. AI tool configs use empty `api_key` fields and OAuth file storage; Git config uses SSH signing keys referenced by path, not embedded key material.
- **Shell startup** scripts validate PATH additions (user-owned, no current directory).
- **CI runs secret scanning**: TruffleHog, Trivy, and ClamAV on every push/PR.
- `download()` helper in `shell.d/40-functions.sh` supports optional SHA-256 verification.
- Sensitive paths like `~/.ssh/config` are included as config files, not key material.

When modifying configs:

1. Do not add literal API keys, tokens, or private keys.
2. Avoid `eval` of untrusted input and `curl ... | sh` patterns.
3. Keep `PATH` free of `.` and world-writable directories.
4. Prefer quoting variable expansions in shell code.

## Platform Support

- **Linux** — primary; NixOS, Arch, Ubuntu/Debian are explicitly handled
- **macOS** — Homebrew path support in shell configs
- **Windows** — PowerShell, Windows Terminal, Git Bash/MSYS path normalization (`cygpath`)
- **Wayland** — Hyprland, environment variables in `dotfiles/.config/environment.d/wayland.conf`

## Key Configuration Entry Points

| Shell              | Entry point                                              | Loads                                                     |
| ------------------ | -------------------------------------------------------- | --------------------------------------------------------- |
| Bash (login)       | `dotfiles/.bash_profile` → `.config/bash/bash_profile`   | XDG, `profile.d/*.sh`, then `.bashrc`                     |
| Bash (interactive) | `dotfiles/.bashrc` → `.config/bash/bashrc`               | `shell/shell.d/*.sh`, `bash/bash.d/*.bash`                |
| Zsh (env)          | `dotfiles/.zshenv`                                       | XDG, `ZDOTDIR`                                            |
| Zsh (login)        | `dotfiles/.config/zsh/.zprofile`                         | `shell/profile.d/*.sh`                                    |
| Zsh (interactive)  | `dotfiles/.config/zsh/.zshrc`                            | `shell/shell.d/*.sh`, `zsh/zsh.d/*.zsh`                   |
| Nushell            | `dotfiles/.config/nushell/env.nu` + `config.nu`          | modules in `modules/`, autoload-generated tools           |
| PowerShell         | `dotfiles/.config/powershell/profile.ps1` → `config.ps1` | XDG, PSReadLine, cached tool inits, aliases, functions    |
| Kimi Code          | `dotfiles/.config/kimi-code/config.toml` + `tui.toml`    | `mcp.json`, `themes/nord.json`, `~/.agents/skills`        |
| Claude Code        | `dotfiles/.config/claude/settings.json`                  | `CLAUDE_CONFIG_DIR`, permissions, MCP servers, statusline |
| Codex              | `dotfiles/.config/codex/config.toml`                     | `CODEX_HOME`, approval policy, MCP servers                |

## Agent-Specific Guidance

- Read `CLAUDE.md` for tool-specific context when editing files in that scope.
- Read `dotfiles/.config/codex/AGENTS.md` before changing Codex config.
- Read `dotfiles/.config/kimi-code/AGENTS.md` before changing Kimi Code config.
- Read `dotfiles/.config/nvim/AGENTS.md` before changing Neovim Lua.
- For shell changes, update the appropriate file under `dotfiles/.config/shell/`, `bash/`, `zsh/`, `nushell/`, or `powershell/`; do not edit monolithic RC files directly.
- After adding a new tool config, consider adding it to:
  - `.dotter/global.toml` (deployment mapping)
  - `nixos/home.nix` (if Linux/Wayland applicable)
  - `Justfile` (if a new validation recipe is needed)
  - `.github/workflows/ci.yml` (validation job)
- Run `just fmt` and `just lint` before committing.
- If adding an external plugin/theme, declare it in `vendir.yml`, run `just sync`, and commit `vendir.yml`, `vendir.lock.yml`, and `vendir.lock.windows.yml`.
- The `dotfiles/.config/nvim` configuration is currently noted as broken in `TODO.md`; treat it as a known issue requiring a dedicated fix session.

## Useful Links

- Repository: `https://github.com/arttet/dotfiles`
- Docs site: built from `docs/` and deployed to GitHub Pages
- CI pipeline: `.github/workflows/ci.yml`
