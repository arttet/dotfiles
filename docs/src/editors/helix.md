# Helix Editor

A post-modern modal text editor with built-in LSP support and a focus on terminal multiplexer integration.

## Configuration Paths

- Config: `dotfiles/.config/helix/config.toml`
- Languages: `dotfiles/.config/helix/languages.toml`

## Leader Key

The **leader** key is `Space`.

## Navigation & Views

| Action            | Mode   | Shortcut      |
| :---------------- | :----- | :------------ |
| Jump view left    | Normal | `Ctrl + H`    |
| Jump view down    | Normal | `Ctrl + J`    |
| Jump view up      | Normal | `Ctrl + K`    |
| Jump view right   | Normal | `Ctrl + L`    |
| Next buffer       | Normal | `Tab`         |
| Previous buffer   | Normal | `Shift + Tab` |
| Move parent node  | Insert | `Shift + Tab` |
| Extend node end   | Select | `Tab`         |
| Extend node start | Select | `Shift + Tab` |

## Space Menu (Leader)

| Category     | Action                      | Shortcut                  |
| :----------- | :-------------------------- | :------------------------ |
| **Pickers**  | File picker                 | `Space`, then `F`         |
| **Pickers**  | Buffer picker               | `Space`, then `B`         |
| **Pickers**  | Symbol picker               | `Space`, then `S`         |
| **Pickers**  | Workspace symbol picker     | `Space`, then `Shift + S` |
| **Pickers**  | Diagnostics                 | `Space`, then `D`         |
| **Pickers**  | Workspace diagnostics       | `Space`, then `Shift + D` |
| **Pickers**  | Changed files               | `Space`, then `Shift + C` |
| **Pickers**  | Jumplist                    | `Space`, then `J`         |
| **Explorer** | File explorer (current dir) | `Space`, then `E`         |
| **Explorer** | File explorer               | `Space`, then `Shift + E` |
| **Search**   | Global search               | `Space`, then `/`         |
| **System**   | Command palette             | `Space`, then `?`         |
| **System**   | Reload config               | `Space`, then `C`         |
| **System**   | Write file                  | `Space`, then `W`         |
| **System**   | Format                      | `Space`, then `Shift + F` |
| **System**   | Quit                        | `Space`, then `Q`         |

## Floating Pane Integrations

Launches in a floating pane (Zellij/Tmux) or standalone.

| Tool         | Action                | Shortcut          |
| :----------- | :-------------------- | :---------------- |
| **Yazi**     | Floating file manager | `Space`, then `Y` |
| **LazyGit**  | Floating Git TUI      | `Space`, then `G` |
| **Terminal** | Floating Nushell      | `Space`, then `T` |

## Split Pane Integrations

Opens in a new split pane below or to the right.

| Tool         | Action             | Shortcut                  |
| :----------- | :----------------- | :------------------------ |
| **Yazi**     | Split pane (down)  | `Space`, then `Shift + Y` |
| **LazyGit**  | Split pane (right) | `Space`, then `Shift + G` |
| **Terminal** | Split pane (right) | `Space`, then `Shift + T` |

## Discoverability

Helix shows contextual hints automatically. After pressing `Space`, the menu lists every bound command and its shortcut. Press `Space`, then `?` at any time for the command palette.
