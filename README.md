# Dotfiles

[![CI](https://github.com/arttet/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/arttet/dotfiles/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/arttet/dotfiles)](./LICENSE)
[![Release](https://img.shields.io/github/v/release/arttet/dotfiles)](https://github.com/arttet/dotfiles/releases)

Cross-platform shell, terminal, editor, and AI-agent configuration deployed with dotter.

## Project Resources

| Resource      | URL                           |
| ------------- | ----------------------------- |
| Documentation | <https://dotfiles.arttet.dev> |

## Requirements

| Tool                                           | Purpose                                                                             | Required |
| ---------------------------------------------- | ----------------------------------------------------------------------------------- | -------- |
| [mise](https://mise.jdx.dev/)                  | Installs the pinned toolchain and runs every task.                                  | Yes      |
| [dotter](https://github.com/SuperCuber/dotter) | Deploys the configuration symlinks.                                                 | Yes      |
| [GitHub CLI](https://cli.github.com/)          | Installs [GitHub Dash](https://github.com/dlvhdr/gh-dash) in the post-deploy setup. | Optional |

## Deploy

Install [mise](https://mise.jdx.dev/getting-started.html), then run:

```sh
git clone https://github.com/arttet/dotfiles.git
cd dotfiles

mise install                 # repository toolchain, including dotter
mise run deploy:sync:config  # vendor the pinned plugins and themes
mise run deploy:check        # dry run: review every symlink before it is written
mise run deploy:apply        # the deployment itself
mise install                 # global toolchain, now that ~/.config/mise is linked
```

`deploy:apply` is the only step that touches the home directory; everything before it is preparation,
and `deploy:check` prints the same plan without writing anything. The second `mise install` picks up the
global tool list that dotter has just linked into `~/.config/mise`. For release archives and the complete
setup, use the documentation.

## Post-deploy

The complete idempotent setup installs the GitHub Dash extension, opts Go out of telemetry and installs the
managed agent skills.

```sh
mise run setup
```

Run a single optional step such as `mise run setup:skills` when the complete setup is not needed.

## Development

Install the toolchain, wire the [hk](https://hk.jdx.dev/) pre-commit hooks into the clone, then run the
same gates CI runs:

```sh
mise install
mise run hooks:install
mise run check:all
```

`check:all` covers format, lint, security, antivirus, documentation, validation, benchmarks and the
release artifacts. Use `mise run check` for the everyday subset, which drops the antivirus, benchmark and
artifact gates, or run a single gate with `mise run fmt:all`, `mise run lint:all` and friends.
