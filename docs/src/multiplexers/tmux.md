# Tmux

The classic terminal multiplexer, optimized for workflow with Vim-style navigation and custom prefix mapping.

## Configuration Paths

- Config: `dotfiles/.config/tmux/tmux.conf`

## Keybindings

The **Prefix** is `Ctrl + A`.

### General

| Action               | Shortcut         |
| :------------------- | :--------------- |
| Reload Configuration | `Prefix + R`     |
| Session Tree         | `Prefix + S`     |
| Last Active Window   | `Prefix + Space` |
| Toggle Zoom          | `Prefix + M`     |

### Window & Pane Management

| Action                | Shortcut      |
| :-------------------- | :------------ |
| New Window            | `Prefix + C`  |
| Split Horizontal      | `Prefix + \|` |
| Split Horizontal Full | `Prefix + \`  |
| Split Vertical        | `Prefix + -`  |
| Split Vertical Full   | `Prefix + _`  |
| Close Focus           | `Prefix + X`  |

### Navigation & Resizing

| Action                | Shortcut     |
| :-------------------- | :----------- |
| Focus Pane (Vim Keys) | `H/J/K/L`    |
| Resize Down (5 lines) | `Prefix + J` |
| Resize Up (5 lines)   | `Prefix + K` |
| Resize Right (5 cols) | `Prefix + L` |
| Resize Left (5 cols)  | `Prefix + H` |

### Copy Mode (`Prefix + [`)

| Action          | Shortcut     |
| :-------------- | :----------- |
| Start Selection | `V`          |
| Yank (Copy)     | `Y`          |
| Paste           | `Prefix + ]` |

### TPM Plugin Keys

| Action            | Shortcut           |
| :---------------- | :----------------- |
| Install Plugins   | `Prefix + I`       |
| Update Plugins    | `Prefix + U`       |
| Uninstall Plugins | `Prefix + Alt + U` |
