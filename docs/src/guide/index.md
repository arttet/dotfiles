# Getting Started

This guide walks you through installing and activating these dotfiles on your system.

There are two ways in. Deploy a published release if you only want to run these dotfiles; clone the
repository if you intend to change them — the release archive carries no build tooling.

## Quick Start (clone)

```bash
git clone https://github.com/arttet/dotfiles.git
cd dotfiles
just install             # mise install + setup
mise run deploy:check    # Preview what will be linked
just apply               # Deploy with dotter
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
archive with the same instructions.

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
mise run deploy:check

# Deploy dotfiles
just apply

# Remove deployed links
just undeploy
```

Each recipe is a shim over the matching mise task (`mise run deploy:apply`, `deploy:undeploy`), which
is exactly what CI runs. GNU Stow is not used and the tree is not laid out for it.

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
just sync                       # plugins and wallpapers (~1.1 GB)
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
just help            # List all available commands
just fmt             # Format all code
just lint            # Run all linters
just docs dev        # Start documentation dev server
mise run bench:all   # Benchmark shell startup times
mise run artifact:dotfiles:all   # Build a release set locally
```

## Next Steps

- **Shells**: Primary shell is [Nushell](https://www.nushell.sh/). Bash and Zsh configs are also provided.
- **Editor**: Neovim config is NvChad-based — start with `nvim`.
- **Multiplexer**: [Zellij](https://github.com/zellij-org/zellij#readme) (`zellij`) or Tmux (`tmux`, prefix `Ctrl + A`).
