# Zellij

A workspace manager and terminal multiplexer that is designed to be user-friendly with discoverable keybindings.

## Configuration Paths

- Config: `dotfiles/.config/zellij/config.kdl`

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
| Focus Left/Down/Up/Right  | `Alt + H` / `Alt + J` / `Alt + K` / `Alt + L` |
| Focus with Arrows         | `Alt + Arrow Keys`                            |
| New Pane                  | `Alt + N`                                     |
| Toggle Floating Panes     | `Alt + F`                                     |
| Previous/Next Swap Layout | `Alt + [` / `Alt + ]`                         |
| Resize Increase/Decrease  | `Alt + +` / `Alt + -`                         |
| Move Tab Left/Right       | `Alt + I` / `Alt + O`                         |
| Toggle Pane in Group      | `Alt + P`                                     |
| Toggle Group Marking      | `Alt + Shift + P`                             |
| Quit Zellij               | `Ctrl + Q`                                    |

### Locked Mode (`Ctrl + G`)

| Action                | Shortcut    |
| :-------------------- | :---------- |
| Switch Focus / Normal | `Space`     |
| Rename Tab            | `,` or `.`  |
| New Pane (Down)       | `-`         |
| New Pane (Right)      | `\` or `\|` |
| Previous Tab          | `B`         |
| About Plugin          | `?`         |
| Layout Manager        | `L`         |
| Go to Tab 1-9         | `1-9`       |
| New Tab               | `C`         |
| Plugin Manager        | `I` or `U`  |
| Toggle Fullscreen     | `M` or `Z`  |
| Detach Session        | `D`         |
| Close Focus           | `X`         |

### Pane Mode (`Ctrl + P`)

| Action                     | Shortcut            |
| :------------------------- | :------------------ |
| Move Focus (HJKL / Arrows) | `H/J/K/L` or arrows |
| New Pane                   | `N`                 |
| New Pane (Down)            | `D`                 |
| New Pane (Right)           | `R`                 |
| New Pane (Stacked)         | `S`                 |
| Toggle Floating            | `W`                 |
| Toggle Embed/Float         | `E`                 |
| Toggle Fullscreen          | `F`                 |
| Toggle Pinned              | `I`                 |
| Rename Pane                | `C`                 |
| Switch Focus               | `P`                 |
| Toggle Pane Frames         | `Z`                 |
| Close Focus                | `X`                 |

### Tab Mode (`Ctrl + T`)

| Action                 | Shortcut            |
| :--------------------- | :------------------ |
| New Tab                | `N`                 |
| Close Tab              | `X`                 |
| Next/Previous Tab      | `L` / `H` or arrows |
| Toggle Tab             | `Tab`               |
| Rename Tab             | `R`                 |
| Break Pane             | `B`                 |
| Break Pane Left/Right  | `[` / `]`           |
| Toggle Active Sync Tab | `S`                 |
| Go to Tab 1-9          | `1-9`               |

### Resize Mode (`Ctrl + N`)

| Action                     | Shortcut          |
| :------------------------- | :---------------- |
| Resize (Increase/Decrease) | `+` / `-` or `=`  |
| Resize Increase (HJKL)     | `H/J/K/L`         |
| Resize Decrease (HJKL)     | `Shift + H/J/K/L` |
| Resize with Arrows         | Arrow keys        |

### Move Mode (`Ctrl + H`)

| Action                    | Shortcut            |
| :------------------------ | :------------------ |
| Move Pane (HJKL / Arrows) | `H/J/K/L` or arrows |
| Move Pane                 | `N` or `Tab`        |
| Move Pane Backwards       | `P`                 |

### Scroll Mode (`Ctrl + S`)

| Action              | Shortcut                           |
| :------------------ | :--------------------------------- |
| Scroll Up/Down      | `K` / `J` or arrows                |
| Page Scroll Up/Down | `PageUp` / `PageDown` or `H` / `L` |
| Half Page Up/Down   | `U` / `D`                          |
| Scroll to Bottom    | `Ctrl + C`                         |
| Enter Search        | `S`                                |
| Edit Scrollback     | `E`                                |

### Search Mode (from Scroll)

| Action                  | Shortcut  |
| :---------------------- | :-------- |
| Search Down/Up          | `N` / `P` |
| Toggle Case Sensitivity | `C`       |
| Toggle Whole Word       | `O`       |
| Toggle Wrap             | `W`       |

### Session Mode (`Ctrl + O`)

| Action               | Shortcut |
| :------------------- | :------- |
| About Plugin         | `A`      |
| Configuration Plugin | `C`      |
| Layout Manager       | `L`      |
| Plugin Manager       | `P`      |
| Share Plugin         | `S`      |
| Session Manager      | `W`      |
| Detach               | `D`      |

### Tmux Mode (`Ctrl + B` / `Ctrl + A`)

| Action                     | Shortcut            |
| :------------------------- | :------------------ |
| Move Focus (HJKL / Arrows) | `H/J/K/L` or arrows |
| New Pane (Right)           | `\|` or `\` or `%`  |
| New Pane (Down)            | `-` or `_` or `"`   |
| Next/Previous Tab          | `N` / `P`           |
| Focus Next Pane            | `O`                 |
| Rename Tab                 | `,`                 |
| Enter Scroll               | `[`                 |
| Send Ctrl+B                | `Ctrl + B`          |
| Session Manager            | `S`                 |
| New Tab                    | `C`                 |
| Plugin Manager             | `I` / `U`           |
| Toggle Fullscreen          | `M` / `Z`           |
| Detach                     | `D`                 |
