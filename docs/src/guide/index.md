# Getting Started

This guide walks you through installing and activating these dotfiles on your system.

There are two ways in. Deploy a published release if you only want to run these dotfiles; clone the
repository if you intend to change them — the release archive carries no build tooling.

## Quick Start (clone)

```bash
git clone https://github.com/arttet/dotfiles.git
cd dotfiles
mise install
mise run deploy:sync:config
mise run deploy:check    # Preview what will be linked
mise run deploy:apply
mise install             # Install the deployed global toolchain
mise run setup           # GitHub extensions, telemetry, and agent skills
```

## Quick Start (release)

Every tag publishes an archive alongside an SBOM, a license inventory, a manifest naming the commit it
was built from, and checksums. Check it before you trust it:

```bash
gh release download --repo arttet/dotfiles
sha256sum --check checksums.sha256
gh attestation verify dotfiles.tar.gz --repo arttet/dotfiles

mkdir dotfiles && tar -xzf dotfiles.tar.gz -C dotfiles && cd dotfiles
dotter deploy --verbose --dry-run
dotter deploy --verbose --force
```

The archive unpacks to `dotfiles/` plus `.dotter/`, which is the layout `dotter` expects, and the
vendored plugins are already inside it — do not run `vendir sync` there. `INSTALL.md` ships in the
archive with the offline deployment instructions.

## Prerequisites

- [mise](https://mise.jdx.dev/) — installs every pinned tool below with `mise install`
- [dotter](https://github.com/SuperCuber/dotter) — the deployer
- [just](https://github.com/casey/just) (optional, for convenience commands)
- [vendir](https://github.com/vmware-tanzu/carvel-vendir) (to sync external plugins)

> **Note:** The tools configured in these dotfiles (yazi, eza, Zellij, etc.) are assumed to be installed separately via your package manager.

## Deployment

**dotter** is the only deployer, on every platform — it handles Windows-specific paths and profiles:

```bash
# Preview changes without applying
mise run deploy:check

# Deploy dotfiles
mise run deploy:apply

# Remove deployed links
mise run deploy:undeploy
```

The `just` recipes of the same name are convenience shims over these mise tasks — the mise tasks are
what CI runs. GNU Stow is not used and the tree is not laid out for it.

What gets deployed is selected in `.dotter/local.toml` by listing packages. A fresh clone ships:

```toml
packages = ["default"]
```

`default` is a group (configured in `.dotter/global.toml`) that pulls in `agent` (Claude Code, Codex,
Kimi Code, OpenCode), `dev` (mise), `editor` (Helix, Zed), `shell` (Bash, PowerShell, Zsh), and
`terminal` (Alacritty, Windows Terminal). The `wallpapers` package is deliberately outside `default` —
add it to opt into the ~1.1 GB background collections:

```toml
packages = ["default", "wallpapers"]
```

## Sync External Dependencies

Some configs rely on vendored plugins and themes:

```bash
mise run deploy:sync            # plugins and wallpapers (~1.1 GB)
mise run deploy:sync:config     # plugins only, which is what CI runs
```

This updates external resources managed by [vendir](https://github.com/vmware-tanzu/carvel-vendir) (Alacritty themes, Yazi plugins, etc.). Do not edit these files manually.

## Directory Overview

```text
dotfiles/
├── .config/          # Tool configurations (nvim, shells, git, etc.)
│   ├── bash/
│   ├── nushell/
│   ├── nvim/
│   └── shell/shell.d/ # Shared aliases and functions
├── .bashrc
├── .bash_profile
├── .zshenv
└── ...

nixos/                # NixOS and Home Manager configs
misc/                 # Supplementary files and justfile modules
```

## Useful Commands

```bash
mise tasks                     # List all available tasks
mise run fmt:write             # Format all code
mise run lint:all              # Run all linters
(cd docs && aube run docs:dev) # Start documentation dev server
mise run bench:all             # Benchmark shell startup times
mise run artifact:dotfiles:all # Build a release set locally
```

## Next Steps

- **Shells**: Primary shell is [Nushell](https://www.nushell.sh/). Bash and Zsh configs are also provided.
- **Editor**: Neovim 0.12+ on the built-in `vim.pack` manager — start with `nvim`.
- **Multiplexer**: [Zellij](https://github.com/zellij-org/zellij#readme) (`zellij`) or Tmux (`tmux`, prefix `Ctrl + A`).
