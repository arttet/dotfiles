# Zellij

A workspace manager and terminal multiplexer that is designed to be user-friendly with discoverable keybindings.

## Configuration Paths

- Config: `dotfiles/.config/zellij/config.kdl`

## Themes

Uses built-in Zellij themes with auto-switching based on terminal color scheme (CSI 2031 / DSR 997):

- **Default**: `gruvbox-dark`
- **Dark mode**: `gruvbox-dark`
- **Light mode**: `gruvbox-light`

## Troubleshooting

Run `zellij setup --check` to verify configuration, theme loading, and directory paths.

## Keybindings

Zellij uses modal input. Each mode is entered via a prefix and has its own keymap.

### Mode Switching

| Mode        | Shortcut                 |
| :---------- | :----------------------- |
| **Normal**  | `Esc` (from other modes) |
| **Locked**  | `Ctrl + G`               |
| **Pane**    | `Ctrl + P`               |
| **Tab**     | `Ctrl + T`               |
| **Resize**  | `Ctrl + N`               |
| **Move**    | `Ctrl + H`               |
| **Scroll**  | `Ctrl + S`               |
| **Session** | `Ctrl + O`               |
| **Tmux**    | `Ctrl + B` or `Ctrl + A` |

### Shared (All Modes Except Locked)

| Action                    | Shortcut                                      |
| :------------------------ | :-------------------------------------------- |
| Lock UI                   | `Ctrl + G`                                    |
| Focus left/down/up/right  | `Alt + H` / `Alt + J` / `Alt + K` / `Alt + L` |
| Focus with arrows         | `Alt + Arrow Keys`                            |
| New pane                  | `Alt + N`                                     |
| Toggle floating panes     | `Alt + F`                                     |
| Previous/next swap layout | `Alt + [` / `Alt + ]`                         |
| Resize increase/decrease  | `Alt + +` / `Alt + -`                         |
| Move tab left/right       | `Alt + I` / `Alt + O`                         |
| Toggle pane in group      | `Alt + P`                                     |
| Toggle group marking      | `Alt + Shift + P`                             |
| Quit Zellij               | `Ctrl + Q`                                    |

> **Note:** `Ctrl + H` enters Move mode in Zellij, which conflicts with Helix's `Ctrl + H` (jump view left). Run Zellij in Locked mode (`Ctrl + G`) or use `Alt + H` for focus when editing inside Zellij.

### Locked Mode (`Ctrl + G`)

| Action                | Shortcut   |
| :-------------------- | :--------- |
| Switch focus / normal | `Space`    |
| Rename tab            | `,` or `.` |
| New pane (down)       | `-`        |
| New pane (right)      | `\\` or `  |
| Previous tab          | `B`        |
| About plugin          | `?`        |
| Layout manager        | `L`        |
| Go to tab 1-9         | `1`–`9`    |
| New tab               | `C`        |
| Plugin manager        | `I` or `U` |
| Toggle fullscreen     | `M` or `Z` |
| Detach session        | `D`        |
| Close focus           | `X`        |

### Pane Mode (`Ctrl + P`)

| Action                     | Shortcut            |
| :------------------------- | :------------------ |
| Move focus (HJKL / arrows) | `H/J/K/L` or arrows |
| New pane                   | `N`                 |
| New pane (down)            | `D`                 |
| New pane (right)           | `R`                 |
| New pane (stacked)         | `S`                 |
| Toggle floating            | `W`                 |
| Toggle embed/float         | `E`                 |
| Toggle fullscreen          | `F`                 |
| Toggle pinned              | `I`                 |
| Rename pane                | `C`                 |
| Switch focus               | `P`                 |
| Toggle pane frames         | `Z`                 |
| Close focus                | `X`                 |

### Tab Mode (`Ctrl + T`)

| Action                 | Shortcut            |
| :--------------------- | :------------------ |
| New tab                | `N`                 |
| Close tab              | `X`                 |
| Next/previous tab      | `L` / `H` or arrows |
| Toggle tab             | `Tab`               |
| Rename tab             | `R`                 |
| Break pane             | `B`                 |
| Break pane left/right  | `[` / `]`           |
| Toggle active sync tab | `S`                 |
| Go to tab 1-9          | `1`–`9`             |

### Resize Mode (`Ctrl + N`)

| Action                     | Shortcut          |
| :------------------------- | :---------------- |
| Resize (increase/decrease) | `+` / `-` or `=`  |
| Resize increase (HJKL)     | `H/J/K/L`         |
| Resize decrease (HJKL)     | `Shift + H/J/K/L` |
| Resize with arrows         | Arrow keys        |

### Move Mode (`Ctrl + H`)

| Action                    | Shortcut            |
| :------------------------ | :------------------ |
| Move pane (HJKL / arrows) | `H/J/K/L` or arrows |
| Move pane                 | `N` or `Tab`        |
| Move pane backwards       | `P`                 |

### Scroll Mode (`Ctrl + S`)

| Action              | Shortcut                             |
| :------------------ | :----------------------------------- |
| Scroll up/down      | `K` / `J` or arrows                  |
| Page scroll up/down | `Page Up` / `Page Down` or `H` / `L` |
| Half page up/down   | `U` / `D`                            |
| Scroll to bottom    | `Ctrl + C`                           |
| Enter search        | `S`                                  |
| Edit scrollback     | `E`                                  |

### Search Mode (from Scroll)

| Action                  | Shortcut  |
| :---------------------- | :-------- |
| Search down/up          | `N` / `P` |
| Toggle case sensitivity | `C`       |
| Toggle whole word       | `O`       |
| Toggle wrap             | `W`       |

### Session Mode (`Ctrl + O`)

| Action               | Shortcut |
| :------------------- | :------- |
| About plugin         | `A`      |
| Configuration plugin | `C`      |
| Layout manager       | `L`      |
| Plugin manager       | `P`      |
| Share plugin         | `S`      |
| Session manager      | `W`      |
| Detach               | `D`      |

### Tmux Mode (`Ctrl + B` / `Ctrl + A`)

| Action                     | Shortcut            |
| :------------------------- | :------------------ |
| Move focus (HJKL / arrows) | `H/J/K/L` or arrows |
| New pane (right)           | `                   |
| New pane (down)            | `-` or `_` or `"`   |
| Next/previous tab          | `N` / `P`           |
| Focus next pane            | `O`                 |
| Rename tab                 | `,`                 |
| Enter scroll               | `[`                 |
| Send Ctrl + B              | `Ctrl + B`          |
| Session manager            | `S`                 |
| New tab                    | `C`                 |
| Plugin manager             | `I` / `U`           |
| Toggle fullscreen          | `M` / `Z`           |
| Detach                     | `D`                 |
