# Nushell

A modern, structured shell that treats data as first-class citizens.

## Configuration Paths

- Config: `dotfiles/.config/nushell/config.nu`
- Env: `dotfiles/.config/nushell/env.nu`
- Modules: `dotfiles/.config/nushell/modules/`

## Key Modules

The shell is modularized for better maintenance:

- `aliases.nu`: Custom shortcuts for common tools.
- `git.nu`: Enhanced git completions and status aliases.
- `yazi.nu`: File manager shell integration.
- `fzf.nu`: Fuzzy finder integrations for history and files.

## Common Replacements

Nushell is configured to use modern Rust-based replacements for classic utils:

- `ls` → `eza`
- `cat` → `bat`
- `find` → `fd`
- `grep` → `rg`

## Shell Keybindings

### Line Editing

| Action               | Shortcut   |
| :------------------- | :--------- |
| Move to line start   | `Ctrl + A` |
| Move to line end     | `Ctrl + E` |
| Delete to line start | `Ctrl + U` |
| Delete to line end   | `Ctrl + K` |
| Delete word backward | `Ctrl + W` |
| Clear screen         | `Ctrl + L` |
| Cancel               | `Ctrl + C` |
| Submit command       | `Enter`    |

### History & Completion

| Action                | Shortcut      |
| :-------------------- | :------------ |
| Previous history item | `Up`          |
| Next history item     | `Down`        |
| Accept completion     | `Tab`         |
| Previous completion   | `Shift + Tab` |

### Custom Fuzzy Bindings

| Action               | Shortcut   |
| :------------------- | :--------- |
| Edit file with `fzf` | `Ctrl + T` |
| Jump directory       | `Alt + C`  |
| Search history       | `Ctrl + R` |

### Quick Aliases

Run `g?` in Nushell for the full interactive git cheat sheet.

| Alias | Command                |
| :---- | :--------------------- |
| `y`   | `yazi` (preserves cwd) |
| `gg`  | `lazygit`              |
| `n`   | `nvim`                 |
| `j`   | `just`                 |
| `jf`  | `just fmt`             |
| `jl`  | `just lint`            |

## Quick Access

Use `just hotkeys` (or the Nushell alias `hk`) to fuzzy-search this documentation's hotkey cheatsheet directly from the terminal.
