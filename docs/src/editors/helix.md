# Helix Editor

A post-modern modal text editor with built-in LSP support and a focus on terminal multiplexer integration.

## Configuration Paths

- Config: `dotfiles/.config/helix/config.toml`
- Languages: `dotfiles/.config/helix/languages.toml`

## Keybindings

### Navigation & Views

| Action            | Mode   | Shortcut      |
| :---------------- | :----- | :------------ |
| Jump View Left    | Normal | `Ctrl + H`    |
| Jump View Down    | Normal | `Ctrl + J`    |
| Jump View Up      | Normal | `Ctrl + K`    |
| Jump View Right   | Normal | `Ctrl + L`    |
| Next Buffer       | Normal | `Tab`         |
| Previous Buffer   | Normal | `Shift + Tab` |
| Move Parent Node  | Insert | `Shift + Tab` |
| Extend Node End   | Select | `Tab`         |
| Extend Node Start | Select | `Shift + Tab` |

### Space Menu (Leader)

| Category     | Action                      | Shortcut            |
| :----------- | :-------------------------- | :------------------ |
| **Pickers**  | File Picker                 | `Space + F`         |
| **Pickers**  | Buffer Picker               | `Space + B`         |
| **Pickers**  | Symbol Picker               | `Space + S`         |
| **Pickers**  | Workspace Symbol Picker     | `Space + Shift + S` |
| **Pickers**  | Diagnostics                 | `Space + D`         |
| **Pickers**  | Workspace Diagnostics       | `Space + Shift + D` |
| **Pickers**  | Changed Files               | `Space + Shift + C` |
| **Pickers**  | Jumplist                    | `Space + J`         |
| **Explorer** | File Explorer (current dir) | `Space + E`         |
| **Explorer** | File Explorer               | `Space + Shift + E` |
| **Search**   | Global Search               | `Space + /`         |
| **System**   | Command Palette             | `Space + ?`         |
| **System**   | Reload Config               | `Space + C`         |
| **System**   | Write File                  | `Space + W`         |
| **System**   | Format                      | `Space + Shift + F` |
| **System**   | Quit                        | `Space + Q`         |

### Integrations — Floating Panes

Launches in floating pane (Zellij/Tmux) or standalone.

| Tool         | Action                | Shortcut    |
| :----------- | :-------------------- | :---------- |
| **Yazi**     | Floating File Manager | `Space + Y` |
| **LazyGit**  | Floating Git TUI      | `Space + G` |
| **Terminal** | Floating NuShell      | `Space + T` |

### Integrations — Split Panes

Opens in a new split pane below or to the right.

| Tool         | Action             | Shortcut            |
| :----------- | :----------------- | :------------------ |
| **Yazi**     | Split Pane (Down)  | `Space + Shift + Y` |
| **LazyGit**  | Split Pane (Right) | `Space + Shift + G` |
| **Terminal** | Split Pane (Right) | `Space + Shift + T` |
