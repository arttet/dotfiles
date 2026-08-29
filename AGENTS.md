# Dotfiles — Agent Guide

This file is the canonical source of truth for repository-wide AI agent instructions. `CLAUDE.md` is the
tool-specific entry point that must reference this guide instead of duplicating its rules. If an adapter conflicts with
this file, follow `AGENTS.md`.

This repository is a personal, cross-platform dotfiles configuration for Artyom Tetyukhin (`@arttet`). It manages shell, terminal, editor, window-manager, and AI-tool configurations, deploying them to `$HOME` as symlinks.

## Project Overview

- **Repository**: `https://github.com/arttet/dotfiles`
- **Maintainer**: `@arttet` (see `.github/CODEOWNERS`)
- **Primary language of documentation and comments**: English
- **Deployment model**: Symlink-based dotfiles deployed with **dotter** (`just deploy apply` / `mise run deploy:apply`)
- **External assets**: Plugins and themes are vendored with **vendir** (`vendir.yml`); wallpapers live in a separate `vendir.wallpapers.yml` and land in `dotfiles/.local/share/backgrounds/`. Each config has its own lock file, plus a `*.windows.yml` variant for Windows path handling
- **Task runners**: `just` (`Justfile`) for deployment and local recipes; `mise` (`mise.toml`) for pinned dev tools and Stage-1 CI gate tasks
- **Documentation site**: VitePress under `docs/`, served via aube (`just docs dev`)
- **NixOS integration**: `nixos/home.nix` links selected dotfiles into a Home Manager generation

## Repository Layout

```text
.
├── .dotter/              # dotter deployment configuration
│   └── global.toml       # package/profiles and file mappings
├── .github/              # CI/CD workflows and Dependabot config
│   ├── codeql/           # CodeQL scan configuration (actions, javascript)
│   └── workflows/ci.yml  # validation, security, docs, deployment
├── docs/                 # VitePress documentation site
│   ├── package.json      # aube-managed dev dependencies
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
│   │   ├── hypr/         # Hyprland (Lua), hyprpaper, wallpaper switcher script
│   │   ├── kimi-code/    # Kimi Code settings
│   │   ├── mise/         # global toolchain: config.toml + conf.d/ (numbered by priority)
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
│   ├── .local/share/     # XDG_DATA_HOME tree
│   │   └── backgrounds/  # vendored wallpaper collections (~1.1 GB, opt-in)
│   └── .ssh/config
├── misc/                 # additional Just modules
│   └── justfiles/docs.just
├── nixos/
│   └── home.nix          # Home Manager links for NixOS
├── Justfile              # primary task definitions
├── mise.toml             # pinned dev tools + Stage-1 CI gate tasks (fmt/lint/security/antivirus/docs)
├── vendir.yml            # external dependency specifications (plugins, themes)
├── vendir.wallpapers.yml # wallpaper collections, synced separately
├── vendir.lock*.yml      # pinned versions; *.windows.yml variants use backslash paths
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

# Development (mise-backed)
just install       # install pinned CI/dev tools (mise install)
just fmt           # delegates to `mise run fmt:write` (dprint + stylua + shfmt + just --fmt)
just lint          # delegates to `mise run lint:all` (all Stage-1 linters)
just check         # delegates to `mise run check` (all Stage-1 gates)
just ci            # delegates to `mise run ci` (GitHub Actions locally via act)
just clean         # remove vendir deps, .tools caches, docs artifacts

# Dotfiles deployment (deploy module)
just deploy sync             # vendir sync --locked, wallpapers included (~1.1 GB)
just deploy config           # same, minus the wallpapers (what CI runs)
just deploy wallpapers       # wallpaper collections only
just deploy check       # dotter dry-run preview
just deploy apply       # dotter deploy --verbose --force
just deploy undeploy    # dotter undeploy

# Docs
just docs dev      # VitePress dev server (port 5173)
just docs build    # VitePress production build
just docs preview  # preview production build

# Performance (thin shim over `mise run bench:<target>`)
just bench         # every benchmark available on the platform
just bench zsh     # one target: nu, bash, zsh, tmux, pwsh
just bench ci      # compare with misc/baseline.json (Linux only)

# Stage-1 CI gates via mise (local CI parity)
mise install       # install all pinned tools from mise.toml
mise run check     # all Stage-1 gates: fmt, lint, security, antivirus, docs
mise tasks         # list individual gate tasks (fmt:all, lint:all, security:all, ...)
mise run deps:outdated  # Renovate local report of available dependency updates
mise run ci:list   # list GitHub Actions jobs runnable locally via act
mise run ci        # run the CI workflow locally via act (requires Docker)

# Security gate (each task is also a CI step)
mise run security:all       # secrets, SAST, web, Trivy, licenses, OSV, Grype, Grant, policy, zizmor
mise run security:codeql:actions  # CodeQL over the workflows (~1 GB on first run); docs:codeql covers TypeScript
mise run security:conftest  # OPA/Rego policies over workflows, mise.toml and the VEX document
mise run security:trivy:license # licenses of the deployed tree (needs deploy:sync:config)
mise run security:grant     # license policy over the deployed tree (Linux/macOS only)
mise run security:grype:images  # scan the digest-pinned ClamAV and Renovate images (nightly in CI)
mise run docs:security      # hardening checks over the built site (needs docs:build first)
```

Stage-1 gate tasks live in `mise.toml` and are exactly what CI runs (`.github/workflows/ci.yml` calls
`mise run fmt:all` / `lint:all` / `security:*` / `antivirus:all` / `docs:*`). Stage 2 and 3 follow the same
rule: `validate:*`, `bench:*`, `deploy:*`, and `deploy:cloudflare:*` are mise tasks, and every workflow step
is a `mise run` of one of them. Tools are pinned in `mise.toml`; mise itself is installed in CI by
`jdx/mise-action`, pinned to a commit SHA. CI uses neither Nix nor stow.

That pin is what makes the install trustworthy. The action carries a minisign public key in its own
source, so pinning the commit pins the key; it then verifies `SHASUMS256.txt` from the mise release
against that key and checks the downloaded asset against those checksums. Do not set the action's
`sha256` input: it verifies the extracted binary instead and makes the action skip the signature
check entirely.

### Fork trust model

Pull requests from forks are welcome and run every read-only gate. What they never get is anything that
could act on this repository: no secrets, no OIDC token, no write to the Security tab, no pull-request
comment, no deployment. That decision is made once by the `guard` job, which publishes a `trusted`
output, and every privileged step carries `if: needs.guard.outputs.trusted == 'true'`.

Two rules in `policy/workflows.rego` keep it from drifting: every job must list `guard` in `needs`, and
any job holding a write permission or reading a real secret must reference
`needs.guard.outputs.trusted`. `pull_request_target` is rejected outright — it is the usual way a
repository hands a fork both its secrets and its write token.

### License inventory

`mise run security:trivy:license` and `mise run security:grant` look at the deployed tree, not just the
committed one: several vendored components carry GPL-3.0 or AGPL-3.0, and the useful output is
visibility, not a red build.

Both need a synced tree. The vendored plugins are gitignored, so without `mise run deploy:sync:config`
the inventory would silently omit two thirds of its subjects and claim the rest is the whole picture;
the CI job runs the sync as its own step for the same reason. Wallpapers are outside that sync — their
licenses belong to the wallpaper release set, not to the configuration gate.

### Suppressing a finding

Do not add `.trivyignore`, `[[IgnoredVulns]]`, or a severity downgrade. The only sanctioned mechanism is
a statement in `misc/vex/dotfiles.openvex.json`, which records who asserted it, when, about which
package, and on what grounds; `policy/vex.rego` rejects a `not_affected` statement with no OpenVEX
justification. The document ships with the release archive and is signed with it.

Two mechanics are easy to get wrong. Grype treats a VEX document as annotation only — the
`ignore: [{vex-status: not_affected}]` rule in `.grype.yaml` is what turns a statement into
suppression, and `show-suppressed: true` keeps the entry visible in the output instead of vanishing.
And for a directory scan Grype derives the product identity as `pkg:generic/<name>@<version>`, which it
cannot build without a version, so statements identify the vulnerable package itself as the product:
`"products": [{"@id": "pkg:golang/stdlib@1.26.4"}]`.

Benchmark tools are pinned in `mise.toml` like everything else: `hyperfine`, `nushell`, `powershell`, and
`tmux`. `bash` and `zsh` have no mise registry entry, so the performance job installs them with
`nix profile install "${NIXPKGS}#bash" "${NIXPKGS}#zsh"` — the only remaining use of Nix in CI.

The benchmark itself is pure mise: `[vars]` holds every raw/configured command, each `bench:<shell>` task is a
single `hyperfine` call, `bench:collect` aggregates whatever exports exist in `.tools/bench/runs/`, and
`misc/bench.jq` derives its targets from those results. The `bench:*` tasks use `shell = "nu -c"` because mise
hands a bash task a POSIX-style `PATH`, which `hyperfine --shell=none` cannot resolve on Windows.

### Global mise toolchain

The machine-wide toolchain is **not** in `mise.toml`; it lives in `dotfiles/.config/mise/conf.d/*.toml`
(deployed as a whole directory by `.dotter/global.toml` and `nixos/home.nix`), with settings and global tasks
in `dotfiles/.config/mise/config.toml`.

In the deployed `~/.config/mise/conf.d`, a **higher file number wins**: it takes precedence on version
conflicts and lands earlier in `PATH`. Verify with `mise bin-paths | head` — the first entries must be the
shell and the language toolchains.

> Do not check this by pointing `MISE_CONFIG_DIR`/`XDG_CONFIG_HOME` at a copy of the tree: loaded that way,
> mise walks `conf.d` in the opposite order and the measurement comes out inverted. Only the deployed
> default path reflects reality.

Files are therefore numbered by ascending priority, in visually distinct groups:

| Range | Group                                                                                         |
| ----- | --------------------------------------------------------------------------------------------- |
| 01–09 | viewers, data, text, logs, reference, media (lowest priority)                                 |
| 12–19 | diagnostics: archive, bench, disk, network, monitor, process, containers, remote              |
| 24–29 | daily tools: navigation, files, version control, task runners, multiplexers, prompt           |
| 60–69 | agents and IDE: formatters, language servers, editors, skill CLIs, MCP servers, coding agents |
| 90–99 | languages: typst, python, zig, go, cpp, rust, javascript, shell (highest priority)            |

Rules when adding a tool:

- A language file is self-contained: compiler, package manager, formatter, debugger and the language's own
  server live together, so dropping the language means dropping one file.
- `62-lsp.toml` and `60-fmt.toml` hold servers and formatters that are not tied to a toolchain file —
  either because no such file exists (`bash-language-server`, `marksman`, `shfmt`, `taplo`) or because the
  server is a separate project from the toolchain (`typescript-language-server`, `cmake-language-server`).
- `94–99` is a contiguous, reserved block (zig, go, cpp, rust, javascript, shell) — do not insert files
  inside it; new language toolchains go at `93` or below.
- `97-rust.toml` also puts `~/.cargo/bin` near the top of `PATH`; if a tool resolves to an unexpected
  version, check `mise which <tool>`.

## Code Style Guidelines

### Formatters

| Language / File type                   | Tool         | Config                                                                                                          |
| -------------------------------------- | ------------ | --------------------------------------------------------------------------------------------------------------- |
| JSON, YAML, TOML, Markdown, TypeScript | `dprint`     | `dprint.json` (line width 120, LF, 2 spaces)                                                                    |
| Lua (Neovim/Nushell/Yazi)              | `stylua`     | `.stylua.toml` (120 cols, Unix LF, 2 spaces, auto-prefer double quotes)                                         |
| Shell (bash/zsh)                       | `shfmt`      | called via `just fmt` on `dotfiles/.bashrc`, `.bash_profile`, `dotfiles/.config/bash`, `dotfiles/.config/shell` |
| Justfile                               | `just --fmt` | `Justfile`                                                                                                      |
| CSS                                    | `stylelint`  | `.stylelintrc.json` (currently no rules)                                                                        |

`.github/workflows/ci.yml` is excluded from dprint (see `excludes` in `dprint.json`) because its section
headers use zero-indent `# ===...` separators, which pretty_yaml would re-indent.

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
just deploy sync

# Validate dotfiles can be deployed
just deploy check
```

The GitHub Actions workflow (`.github/workflows/ci.yml`) runs the following gates:

The `allowed-endpoints` lists for `step-security/harden-runner` live in `.github/harden-runner/*.txt` and are
loaded by the `Load allowed endpoints` step in each job; to allow a new endpoint, add it to the appropriate
txt file, not to the workflow.

- **Stage 1** (parallel, via `mise run` with tools pinned in `mise.toml`):
  - `fmt` — `mise run fmt:all` (dprint check, editorconfig-checker, justfile/Lua/shell format checks)
  - `lint` — `mise run lint:all` (yamllint, actionlint, shellcheck, selene, taplo, markdownlint, stylelint, zizmor, Zellij/Nushell config validation)
  - `security` — TruffleHog secret scan (`--fail`), Semgrep SAST (p/ci OSS rules), Trivy filesystem scan (vuln/secret/misconfig) with blocking HIGH/CRITICAL gate, SARIF upload
  - `antivirus` — `mise run antivirus:all` (ClamAV via Docker image, DB cached daily)
  - `docs` — `mise run docs:install/audit/build/links` (aube install, audit, VitePress build, Lychee link check)
- **Stage 2** (gated by Stage 1):
  - `validate` — deploys the dotfiles with dotter (`mise run deploy:apply`), installs the global toolchain,
    then runs `mise run validate:all` (agents, MCP servers, editors, shells, multiplexers, CLI tools)
  - `performance` — `mise run bench:setup` (Bash/Zsh via Nix) then `mise run bench:ci`; compares startup
    ratios with `misc/baseline.json`
- **Stage 3**:
  - `deploy-cf-pages` — `mise run deploy:cloudflare:preview` on PRs, `:production` on `main`
  - `deploy-github-pages` — publish docs to GitHub Pages (only on `main`, not scheduled)

## Deployment Architecture

### dotter

`.dotter/global.toml` defines profile groups and per-tool file mappings:

- `default` → `agent`, `editor`, `shell`, `terminal`
- `agent` → `agents`, `opencode`, `claude`, `codex`, `kimi`
- `editor` → `helix`, `zed`
- `shell` → `bash`, `powershell`, `zsh`
- `terminal` → `alacritty`, `windows-terminal`

Default target type is `symbolic`. Windows-only paths use `if = "dotter.windows"`. CI deploys through the same
path (`mise run deploy:apply`), so a broken mapping fails the `validate` job.

### NixOS / Home Manager

`nixos/home.nix` builds a fixed list of out-of-store symlinks via `config.lib.file.mkOutOfStoreSymlink` and asserts every target exists. It covers the Linux/Wayland subset of the dotfiles.

## External Dependencies (vendir)

`vendir.yml` pins external repositories into `dotfiles/.config/`:

- Alacritty Catppuccin themes
- Tmux plugins (resurrect, continuum, yank, fzf, tmux2k)
- Yazi flavors and plugins (catppuccin, chmod, copy-file-contents, full-border, git, ouch, piper, starship, toggle-pane, torrent-preview, yaziline)

`vendir.wallpapers.yml` pins the wallpaper collections into `dotfiles/.local/share/backgrounds/` (catppuccin, graphite, graphite-nord, nord, whitesur, whitesur-nord, mactahoe).

**Rule**: update these with `just deploy sync` / `just vendir update`, not by hand. `just deploy sync` uses `--locked` for reproducibility; `just vendir update` re-resolves refs and rewrites both lock files for the platform. Run `just vendir outdated` to see which pinned commits are behind their upstream HEAD — it reports on both configs. Vendored paths are excluded from formatting and linting.

### Partial sync

The wallpaper collections are ~1.1 GB — roughly the entire size of a synced `dotfiles/` tree — and nothing in CI needs them, so there are three sync commands:

| Command                  | Config                  | Lock files                                                          |
| :----------------------- | :---------------------- | :------------------------------------------------------------------ |
| `just deploy sync`       | both                    | both pairs                                                          |
| `just deploy config`     | `vendir.yml`            | `vendir.lock.yml` / `vendir.lock.windows.yml`                       |
| `just deploy wallpapers` | `vendir.wallpapers.yml` | `vendir.lock.wallpapers.yml` / `vendir.lock.wallpapers.windows.yml` |

The split is by config file, not by flag: `vendir.yml` holds the plugins and themes, `vendir.wallpapers.yml` holds the images, and each has its own pair of lock files. `just deploy config` is therefore just a plain `vendir sync` of the default config, and CI runs `mise run deploy:sync:config` everywhere.

Splitting by `vendir sync --directory` was tried and rejected: `--directory` matches `directories[].path` joined with `contents[].path` **exactly** — no prefix, no globs — so it would need one flag per component, kept in step with `vendir.yml` by hand. Nor can a parent like `dotfiles/.config` be declared as a `directories[].path`: vendir owns that path outright and deletes everything in it that the config does not declare.

Deployment is split the same way: `dotfiles/.local/share/backgrounds` belongs to the `wallpapers` dotter package, which is deliberately outside `default`. A desktop that wants them runs `just deploy wallpapers` and adds `"wallpapers"` to `packages` in `.dotter/local.toml`.

> The `*.windows.yml` lock files are kept because `vendir` on Windows normalizes paths to backslashes while the committed ones use forward slashes. The sync tasks select the appropriate lock file automatically.

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
- If adding an external plugin/theme, declare it in `vendir.yml`, run `just deploy sync`, and commit `vendir.yml`, `vendir.lock.yml`, and `vendir.lock.windows.yml`.
- The `dotfiles/.config/nvim` configuration is currently noted as broken in `TODO.md`; treat it as a known issue requiring a dedicated fix session.

## Useful Links

- Repository: `https://github.com/arttet/dotfiles`
- Docs site: built from `docs/` and deployed to GitHub Pages
- CI pipeline: `.github/workflows/ci.yml`
