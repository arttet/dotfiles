# Tmux

The classic terminal multiplexer, optimized for workflow with Vim-style navigation and custom prefix mapping.

## Configuration Paths

- Config: `dotfiles/.config/tmux/tmux.conf`

## Prefix

The **prefix** is `Ctrl + A`.

## General

| Action               | Shortcut                 |
| :------------------- | :----------------------- |
| Reload configuration | `Ctrl + A`, then `R`     |
| Session tree         | `Ctrl + A`, then `S`     |
| Last active window   | `Ctrl + A`, then `Space` |
| Toggle zoom          | `Ctrl + A`, then `M`     |

## Window & Pane Management

| Action                | Shortcut              |
| :-------------------- | :-------------------- |
| New window            | `Ctrl + A`, then `C`  |
| Split horizontal      | `Ctrl + A`, then `    |
| Split horizontal full | `Ctrl + A`, then `\\` |
| Split vertical        | `Ctrl + A`, then `-`  |
| Split vertical full   | `Ctrl + A`, then `_`  |
| Close focus           | `Ctrl + A`, then `X`  |

## Navigation & Resizing

| Action                | Shortcut                     |
| :-------------------- | :--------------------------- |
| Focus pane            | `Ctrl + H` / `J` / `K` / `L` |
| Resize down (5 lines) | `Ctrl + A`, then `J`         |
| Resize up (5 lines)   | `Ctrl + A`, then `K`         |
| Resize right (5 cols) | `Ctrl + A`, then `L`         |
| Resize left (5 cols)  | `Ctrl + A`, then `H`         |

> **Note:** `Ctrl + H/J/K/L` is provided by `vim-tmux-navigator` and works across both Tmux panes and Vim/Neovim splits. It conflicts with Helix's view-jump keys when Helix runs inside Tmux.

## Copy Mode (`Ctrl + A`, then `[`)

| Action          | Shortcut             |
| :-------------- | :------------------- |
| Start selection | `V`                  |
| Yank (copy)     | `Y`                  |
| Paste           | `Ctrl + A`, then `]` |

## TPM Plugin Keys

| Action            | Shortcut                   |
| :---------------- | :------------------------- |
| Install plugins   | `Ctrl + A`, then `I`       |
| Update plugins    | `Ctrl + A`, then `U`       |
| Uninstall plugins | `Ctrl + A`, then `Alt + U` |
