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

# Release artifact (Stage 3)
mise run artifact:dotfiles:all           # build, describe, scan and verify the dotfiles set
mise run artifact:dotfiles:verify:hash   # re-check an existing set against its own checksums
mise run artifact:dotfiles:verify:commit # re-check that its manifest describes this commit
mise run artifact:wallpapers:all         # the ~1.1 GB wallpapers set (main only in CI)
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

Two rules in `misc/policy/workflows.rego` keep it from drifting: every job must list `guard` in `needs`, and
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

### Release artifact

The `artifact` job publishes `dotfiles/` as something a consumer can check rather than trust. The set is
`dotfiles.tar.gz` plus an SPDX SBOM, the VEX document, a license inventory, a manifest and
`checksums.sha256`. Wallpapers are a second, separate set built only on pushes to `main`: they are
~1.1 GB of images and nothing on a pull request needs them.

The archive is packed in two halves and concatenated, because neither tool can see the other's files.
`artifact:dotfiles:pack:tracked` runs `git archive` over an explicit pathspec (`vars.artifact_tracked`):
`dotfiles/`, the two `.dotter/` files and `INSTALL.md` — the last two are what make an unpacked release
deployable at all. `artifact:dotfiles:pack:vendored` packs the vendored plugins, which are gitignored yet
ship to `$HOME`, so `git archive` cannot reach them. Both halves are allowlists, which is what keeps
shell history, `.zcompdump` and dotter caches out by construction rather than by exclusion patterns.

The pathspec is deliberately not `.gitattributes export-ignore`: that is a blocklist, and every new
top-level file would join the release by default.

`git archive` zeroes ownership and stamps the commit time by itself, so only the vendored half carries
the `--mtime` / `--owner` / `--numeric-owner` flags. It also packs `HEAD` rather than the working tree,
which is what `manifest.json` has always claimed — a dirty checkout can no longer ship edits under a
commit id that does not contain them. Reproducibility needs each half to be deterministic, not the
concatenation to be globally sorted. `gzip -n` stays a separate step because `tar --gzip` stamps the
current time.

`artifact:dotfiles:files:text` then reads the finished archive back with `tar -tzf`, so the manifest and
the license inventory describe what shipped rather than what was meant to ship.

`manifest.json` is where identity lives, which is why the commit SHA is not baked into file names. It
records the commit, the tree, and the SHA-256 of both the vendir config and its lock file: the same
commit with a different lock yields different bytes, and that pair is also what distinguishes the two
sets without any exclusion list.

`licenses.json` reports rather than blocks. Several vendored components carry GPL-3.0 (`tmux2k`) or
AGPL-3.0 (`torrent-preview.yazi`) while this repository is MIT; they are used deliberately, so the useful
output is visibility. A component with no license file is recorded as a finding too instead of being
dropped. For the same reason `grant` runs report-only over the SBOM.

### Suppressing a finding

Do not add `.trivyignore`, `[[IgnoredVulns]]`, or a severity downgrade. The only sanctioned mechanism is
a statement in `misc/vex/dotfiles.openvex.json`, which records who asserted it, when, about which
package, and on what grounds; `misc/policy/vex.rego` rejects a `not_affected` statement with no OpenVEX
justification. The document ships with the release archive and is signed with it.

Two mechanics are easy to get wrong. Grype treats a VEX document as annotation only — the
`ignore: [{vex-status: not_affected}]` rule in `.grype.yaml` is what turns a statement into
suppression, and `show-suppressed: true` keeps the entry visible in the output instead of vanishing.
And for a directory scan Grype derives the product identity as `pkg:generic/<name>@<version>`, which it
cannot build without a version, so statements identify the vulnerable package itself as the product:
`"products": [{"@id": "pkg:golang/stdlib@1.26.4"}]`.

Benchmark tools are pinned in `mise.toml` like everything else: `hyperfine`, `nushell`, `powershell`, and
`tmux`. `bash`, `zsh` and `retry` have no mise registry entry, so the performance job installs them with
`nix profile add nixpkgs#bash nixpkgs#retry nixpkgs#zsh` — the only remaining use of Nix in CI.

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
  - `performance` — Bash/Zsh via Nix, `mise run deploy:sync:config` as its own step, then
    `retry --times=3 -- mise run bench:ci`; compares startup ratios with `misc/baseline.json`. A shared
    runner can spike one median past the threshold, while a real regression reproduces on every attempt.
    The retry lives in the workflow rather than inside `bench:ci` because `retry(1)` comes from nixpkgs,
    not from the mise toolset
- **Stage 3**:
  - `artifact` — `mise run artifact:dotfiles:all`; the wallpapers set only on pushes to `main`
  - `deploy-cf-pages` — verify and unpack the docs package, then `mise run deploy:cloudflare:preview`
    on PRs, `:production` on `main`
  - `deploy-github-pages` — publish docs to GitHub Pages (only on `main`, not scheduled)

The `docs` job hands the deploy job a packed archive plus `checksums.sha256` (`docs-package`) rather
than the raw `docs/dist` tree, and `deploy-cf-pages` runs `docs:verify:hash` before `docs:unpack`.
Nothing reaches Cloudflare without the bytes being checked first — the same shape the dotfiles release
set already uses. GitHub Pages keeps its own path: `upload-pages-artifact` and `deploy-pages` travel
through a channel GitHub verifies itself.

`aube pack` writes an npm-style archive, so the site sits two levels down at `package/dist`. `docs:unpack`
strips both levels and takes only that subtree, which also keeps `package.json` out of the published
site. Getting this wrong publishes an empty site rather than failing, which is why the deploy verifies
and unpacks in separate, reproducible steps.

`.github/workflows/release.yml` is separate and runs on `v*` tags. It has no `guard` job because the
tag itself is the trust boundary — only a maintainer can push one — and it rebuilds the set from the
tagged commit rather than reusing a CI artifact, so a release cannot inherit something that was never
gated.

Its first job, `preflight`, checks two things against the API before anything is built. **The commit
must be on `main`**: a tag can be pushed onto any commit, so `compare/main...<commit>` has to report
`identical` (the tip) or `behind` (an ancestor); `ahead` and `diverged` mean the commit never reached
`main` and the tag is refused. **CI must have gone green for it**: CI does not trigger on tags, so this
looks up the most recent `ci.yml` run for the tagged commit — the one from when that commit landed on a
branch. No run at all fails rather than passes; a run still in flight is handed to
`gh run watch --exit-status`; the most recent conclusion wins, so a re-run that went red after an
earlier green still blocks the tag.

The `release` job then attests build provenance and publishes the six files with `gh release create`.
It is the one place that sets `cache: false` on `jdx/mise-action`: a poisoned cache entry here would end
up inside a signed artifact. `workflow_dispatch` runs the build without publishing, which is how a
release gets rehearsed before a tag is cut — the CI check applies to rehearsals too.

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

**Rule**: update these with `just deploy sync` / `mise run deps:vendir:update`, not by hand. `just deploy sync` uses `--locked` for reproducibility; `mise run deps:vendir:update` re-resolves refs and rewrites both lock files for the platform. Run `mise run deps:vendir:outdated` to see which pinned commits are behind their upstream HEAD — it reports on both configs. Both come in `:config` and `:wallpapers` variants that touch one lock file each. Vendored paths are excluded from formatting and linting.

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
