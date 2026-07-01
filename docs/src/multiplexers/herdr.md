# Herdr

A mouse-native, agent-aware terminal multiplexer written in Rust. Herdr behaves like a tmux-style multiplexer
(persistent panes, detach/reattach, a `Ctrl + B` prefix) but treats coding agents — Claude Code, Codex, and
others — as first-class objects: panes can be scanned for agent state (idle, working, blocked) and jumped to
directly.

> **Note:** Herdr is not yet wired into this repository's dotfiles. There is no vendored config under
> `dotfiles/.config/herdr/`; it currently only appears as a system package (`unstablePkgs.herdr`) in the
> companion NixOS configuration. The keybindings and config path below are Herdr's upstream defaults, not a
> customization maintained here.

## Installation

- Nix: `nix run github:ogulcancelik/herdr` (not yet in nixpkgs proper)
- Homebrew: `brew install herdr`
- Mise: `mise use -g herdr`
- Script: `curl -fsSL https://herdr.dev/install.sh | sh` (`install.ps1` for the Windows preview build)
- Cargo: build from source with `cargo build --release`

## Configuration

- Config: `~/.config/herdr/config.toml` (TOML, optional — Herdr runs with sane defaults if absent)

Configuration topics covered upstream include keybindings, themes, sidebar/dashboard layout, notifications, and
scrollback buffer size (10 MB default). See [herdr.dev/docs](https://herdr.dev/docs/) for the full reference.

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
