# Getting Started

This guide walks you through installing and activating these dotfiles on your system.

## Quick Start

```bash
git clone https://github.com/arttet/dotfiles.git
cd dotfiles
just check    # Preview what will be linked
just deploy   # Deploy with dotter
```

## Prerequisites

- [dotter](https://github.com/SuperCuber/dotter) (recommended) or [GNU Stow](https://www.gnu.org/software/stow/)
- [just](https://github.com/casey/just) (optional, for convenience commands)
- [vendir](https://github.com/vmware-tanzu/carvel-vendir) (to sync external plugins)

> **Note:** The tools configured in these dotfiles (Yazi, Eza, Zellij, etc.) are assumed to be installed separately via your package manager.

## Deployment

### Windows

Use **dotter** — it handles Windows-specific paths and profiles:

```bash
# Preview changes without applying
just check

# Deploy dotfiles
just deploy

# Remove deployed links
just undeploy
```

Activate additional profiles when needed:

```bash
dotter deploy -p bash
dotter deploy -p zsh
```

### macOS / Linux

Use **GNU Stow** for simple symlink deployment:

```bash
just install     # stow -v --target=$HOME dotfiles
just uninstall   # stow -v --delete --target=$HOME dotfiles
```

Alternatively, you can use **dotter** on Unix as well if you need profiles or templating:

```bash
just check
just deploy
```

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

### Option 2: GNU Stow

For simpler symlink-based deployment:

```bash
just install     # stow -v --target=$HOME dotfiles
just uninstall   # stow -v --delete --target=$HOME dotfiles
```

## Sync External Dependencies

Some configs rely on vendored plugins and themes:

```bash
just sync
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
- **Multiplexer**: [Zellij](https://zellij.dev/) (`zellij`) or Tmux (`tmux`, prefix `Ctrl + A`).
