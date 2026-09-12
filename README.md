# Dotfiles

[![CI](https://github.com/arttet/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/arttet/dotfiles/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/arttet/dotfiles)](./LICENSE)
[![Release](https://img.shields.io/github/v/release/arttet/dotfiles)](https://github.com/arttet/dotfiles/releases)

Cross-platform shell, terminal, editor, and AI-agent configuration deployed with dotter.

## Requirements

| Tool                                           | Purpose                             |
| ---------------------------------------------- | ----------------------------------- |
| [mise](https://mise.jdx.dev/)                  | Installs the pinned toolchain.      |
| [dotter](https://github.com/SuperCuber/dotter) | Deploys the configuration symlinks. |
| [GitHub CLI](https://cli.github.com/)          | Installs GitHub Dash during setup.  |

## Quick Start

Install [mise](https://mise.jdx.dev/getting-started.html), then run:

```sh
git clone https://github.com/arttet/dotfiles.git
cd dotfiles
mise install
mise run deploy:sync:config
mise run deploy:check
mise run deploy:apply
mise install
mise run setup
```

The second `mise install` installs the global toolchain after dotter has deployed it. Review the dry-run
output before applying. For release archives and complete setup instructions, use the documentation.

## Development

```sh
mise install
mise run hooks:install
mise run check:all
```

## 📚 Project Resources

| Resource      | URL                                  |
| ------------- | ------------------------------------ |
| Documentation | <https://dotfiles.arttet.dev>        |
| Source        | <https://github.com/arttet/dotfiles> |
