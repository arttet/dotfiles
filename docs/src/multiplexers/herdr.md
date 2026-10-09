# Herdr

A mouse-native, agent-aware terminal multiplexer written in Rust. Herdr behaves like a tmux-style multiplexer
(persistent panes, detach/reattach, a `Ctrl + B` prefix) but treats coding agents — Claude Code, Codex, and
others — as first-class objects: panes can be scanned for agent state (idle, working, blocked) and jumped to
directly.

> **Note:** This repository vendors `dotfiles/.config/herdr/config.toml` (deployed to
> `~/.config/herdr/config.toml`): the catppuccin theme with `catppuccin-latte` for light mode and
> first-run onboarding disabled. The keybindings below are Herdr's upstream defaults — the vendored
> config does not rebind them.

## Installation

- Nix: `nix run github:herdrdev/herdr` (not yet in nixpkgs proper)
- Homebrew: `brew install herdr`
- Mise: `mise use -g herdr`
- GitHub releases: [download a binary](https://github.com/herdrdev/herdr/releases)
- Cargo: build from source with `cargo build --release`

## Configuration

- Config: `dotfiles/.config/herdr/config.toml` (TOML, deployed to `~/.config/herdr/config.toml`)

Configuration topics covered upstream include keybindings, themes, sidebar/dashboard layout, notifications, and
scrollback buffer size (10 MB default). See [Herdr documentation](https://github.com/herdrdev/herdr#readme) for the full reference.

## Keybindings

Prefix: `Ctrl + B` (press and release, then press the action key).

| Action                  | Shortcut                     |
| :---------------------- | :--------------------------- |
| New workspace           | `Ctrl + B`, then `Shift + N` |
| Split pane (vertical)   | `Ctrl + B`, then `V`         |
| Split pane (horizontal) | `Ctrl + B`, then `-`         |
| New tab                 | `Ctrl + B`, then `C`         |
| Switch workspaces       | `Ctrl + B`, then `W`         |
| Detach                  | `Ctrl + B`, then `Q`         |
| Help / all bindings     | `Ctrl + B`, then `?`         |

Herdr is also mouse-native: click panes, drag borders to resize, and split or switch from right-click menus
without touching the keyboard.

## Agent detection

Panes running a supported agent (Claude Code, Codex, Devin CLI, GitHub Copilot CLI, and others) are detected
automatically by process name and terminal output, and surfaced in the sidebar with their state (idle/done,
working, blocked). `herdr integration install <agent>` wires up native session restore for supported agents.
