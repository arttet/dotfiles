# Getting Started

This guide walks you through installing and activating these dotfiles on your system.

## Quick Start

```bash
git clone https://github.com/arttet/dotfiles.git
cd dotfiles
just deploy check   # Preview what will be linked
just deploy apply   # Deploy with dotter
```

## Prerequisites

- [mise](https://mise.jdx.dev/) — installs every pinned tool below with `mise install`
- [dotter](https://github.com/SuperCuber/dotter) — the deployer
- [just](https://github.com/casey/just) (optional, for convenience commands)
- [vendir](https://github.com/vmware-tanzu/carvel-vendir) (to sync external plugins)

> **Note:** The tools configured in these dotfiles (Yazi, Eza, Zellij, etc.) are assumed to be installed separately via your package manager.

## Deployment

**dotter** is the only deployer, on every platform — it handles Windows-specific paths and profiles:

```bash
# Preview changes without applying
just deploy check

# Deploy dotfiles
just deploy apply

# Remove deployed links
just deploy undeploy
```

Each recipe is a shim over the matching mise task (`mise run deploy:check`, `deploy:apply`, `deploy:undeploy`),
which is exactly what CI runs.

Available profiles (configured in `.dotter/global.toml`):

| Profile   | Description                                |
| --------- | ------------------------------------------ |
| `default` | Core configs (`~/.config/`)                |
| `bash`    | Bash RC files (`.bashrc`, `.bash_profile`) |
| `zsh`     | Zsh environment (`.zshenv`)                |

Activate a profile:

```bash
dotter deploy -p bash
```

## Sync External Dependencies

Some configs rely on vendored plugins and themes:

```bash
just deploy sync
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
just help       # List all available commands
just fmt        # Format all code
just lint       # Run all linters
just bench      # Benchmark shell startup times
just docs serve # Start documentation dev server
```

## Next Steps

- **Shells**: Primary shell is [Nushell](https://www.nushell.sh/). Bash and Zsh configs are also provided.
- **Editor**: Neovim config is NvChad-based — start with `nvim`.
- **Multiplexer**: [Zellij](https://github.com/zellij-org/zellij#readme) (`zellij`) or Tmux (`tmux`, prefix `Ctrl + A`).
