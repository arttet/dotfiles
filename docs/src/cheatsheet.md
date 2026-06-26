# Hotkey Cheatsheet

This page is the single source of truth for every hotkey configured in these dotfiles. Use the site search (`Ctrl + K` / `Cmd + K`) or run `just hotkeys` from the terminal to fuzzy-find any shortcut without opening a browser.

## Table of Contents

- [Terminals](#terminals)
- [Editors](#editors)
  - [Neovim](#neovim)
  - [Helix](#helix)
- [Multiplexers](#multiplexers)
  - [Zellij](#zellij)
  - [Tmux](#tmux)
- [CLI & Shell](#cli--shell)
  - [Nushell](#nushell)
  - [Yazi](#yazi)
- [AI Agents](#ai-agents)
- [Window Management](#window-management)
  - [Hyprland](#hyprland)
- [Conflict Map](#conflict-map)
- [Discoverability Tips](#discoverability-tips)

## Terminals

Unified shortcuts across Alacritty, Ghostty, and WezTerm.

| Action             | Shortcut                |
| :----------------- | :---------------------- |
| New window         | `Ctrl + Shift + N`      |
| Close window       | `Ctrl + Shift + Q`      |
| New tab            | `Ctrl + Shift + T`      |
| Close tab          | `Ctrl + Shift + W`      |
| Toggle fullscreen  | `F11` or `Ctrl + Enter` |
| Copy               | `Ctrl + Shift + C`      |
| Paste              | `Ctrl + Shift + V`      |
| Increase font size | `Ctrl + Shift + +`      |
| Decrease font size | `Ctrl + Shift + -`      |
| Reset font size    | `Ctrl + Shift + 0`      |

## Editors

### Neovim

Leader key: `Space`

| Action              | Mode     | Shortcut                    |
| :------------------ | :------- | :-------------------------- |
| Command mode        | Normal   | `:`                         |
| Close window/tab    | Normal   | `Ctrl + Q`                  |
| Escape insert mode  | Insert   | `J`, then `K`               |
| New terminal buffer | Normal   | `Alt + T`                   |
| Close terminal      | Terminal | `Ctrl + Q`                  |
| Telescope history   | Normal   | `Space`, then `P`, then `H` |
| Full git blame      | Normal   | `Space`, then `G`, then `F` |
| Open terminal       | Normal   | `Space`, then `T`, then `T` |
| Open LazyGit        | Normal   | `Space`, then `T`, then `L` |
| Open GitUI          | Normal   | `Space`, then `T`, then `U` |
| Open LazyDocker     | Normal   | `Space`, then `T`, then `D` |
| Open Copilot CLI    | Normal   | `Space`, then `T`, then `C` |
| Open Gemini CLI     | Normal   | `Space`, then `T`, then `G` |
| DAP start/continue  | Normal   | `F5`                        |
| DAP run last        | Normal   | `F6`                        |
| DAP toggle UI       | Normal   | `F7`                        |
| DAP conditional BP  | Normal   | `F8`                        |
| DAP toggle BP       | Normal   | `F9`                        |
| DAP step over       | Normal   | `F10`                       |
| DAP step into       | Normal   | `F11`                       |
| DAP step out        | Normal   | `F12`                       |
| DAP select config   | Normal   | `Space`, then `D`, then `C` |

### Helix

Leader key: `Space`

| Action                       | Mode   | Shortcut                  |
| :--------------------------- | :----- | :------------------------ |
| Jump view left/down/up/right | Normal | `Ctrl + H/J/K/L`          |
| Next/previous buffer         | Normal | `Tab` / `Shift + Tab`     |
| File picker                  | Normal | `Space`, then `F`         |
| Buffer picker                | Normal | `Space`, then `B`         |
| Symbol picker                | Normal | `Space`, then `S`         |
| Workspace symbol picker      | Normal | `Space`, then `Shift + S` |
| Diagnostics                  | Normal | `Space`, then `D`         |
| Workspace diagnostics        | Normal | `Space`, then `Shift + D` |
| Changed files                | Normal | `Space`, then `Shift + C` |
| Jumplist                     | Normal | `Space`, then `J`         |
| File explorer (current dir)  | Normal | `Space`, then `E`         |
| File explorer                | Normal | `Space`, then `Shift + E` |
| Global search                | Normal | `Space`, then `/`         |
| Command palette              | Normal | `Space`, then `?`         |
| Reload config                | Normal | `Space`, then `C`         |
| Write file                   | Normal | `Space`, then `W`         |
| Format                       | Normal | `Space`, then `Shift + F` |
| Quit                         | Normal | `Space`, then `Q`         |
| Floating Yazi                | Normal | `Space`, then `Y`         |
| Floating LazyGit             | Normal | `Space`, then `G`         |
| Floating terminal            | Normal | `Space`, then `T`         |
| Split Yazi (down)            | Normal | `Space`, then `Shift + Y` |
| Split terminal (right)       | Normal | `Space`, then `Shift + T` |
| Split LazyGit (right)        | Normal | `Space`, then `Shift + G` |

## Multiplexers

### Zellij

| Mode    | Shortcut                 |
| :------ | :----------------------- |
| Normal  | `Esc`                    |
| Locked  | `Ctrl + G`               |
| Pane    | `Ctrl + P`               |
| Tab     | `Ctrl + T`               |
| Resize  | `Ctrl + N`               |
| Move    | `Ctrl + H`               |
| Scroll  | `Ctrl + S`               |
| Session | `Ctrl + O`               |
| Tmux    | `Ctrl + B` or `Ctrl + A` |

#### Shared (except Locked)

| Action                    | Shortcut                                      |
| :------------------------ | :-------------------------------------------- |
| Lock UI                   | `Ctrl + G`                                    |
| Focus left/down/up/right  | `Alt + H` / `Alt + J` / `Alt + K` / `Alt + L` |
| New pane                  | `Alt + N`                                     |
| Toggle floating panes     | `Alt + F`                                     |
| Previous/next swap layout | `Alt + [` / `Alt + ]`                         |
| Resize increase/decrease  | `Alt + +` / `Alt + -`                         |
| Move tab left/right       | `Alt + I` / `Alt + O`                         |
| Toggle pane in group      | `Alt + P`                                     |
| Toggle group marking      | `Alt + Shift + P`                             |
| Quit Zellij               | `Ctrl + Q`                                    |

#### Locked Mode (`Ctrl + G`, then ...)

| Action            | Shortcut   |
| :---------------- | :--------- |
| Switch focus      | `Space`    |
| Rename tab        | `,` or `.` |
| New pane (down)   | `-`        |
| New pane (right)  | `\\` or `  |
| Previous tab      | `B`        |
| About plugin      | `?`        |
| Layout manager    | `L`        |
| Go to tab 1-9     | `1`–`9`    |
| New tab           | `C`        |
| Plugin manager    | `I` / `U`  |
| Toggle fullscreen | `M` / `Z`  |
| Detach            | `D`        |
| Close focus       | `X`        |

#### Pane / Tab / Tmux Essentials

| Action                 | Shortcut                   |
| :--------------------- | :------------------------- |
| New pane               | `Ctrl + P`, then `N`       |
| New pane down          | `Ctrl + P`, then `D`       |
| New pane right         | `Ctrl + P`, then `R`       |
| Close focus            | `Ctrl + P`, then `X`       |
| New tab                | `Ctrl + T`, then `N`       |
| Close tab              | `Ctrl + T`, then `X`       |
| Next/previous tab      | `Ctrl + T`, then `L` / `H` |
| Rename tab             | `Ctrl + T`, then `R`       |
| Tmux new pane right    | `Ctrl + B`, then `         |
| Tmux new pane down     | `Ctrl + B`, then `-`       |
| Tmux next/previous tab | `Ctrl + B`, then `N` / `P` |
| Tmux session manager   | `Ctrl + B`, then `S`       |
| Tmux detach            | `Ctrl + B`, then `D`       |

### Tmux

Prefix: `Ctrl + A`

| Action                | Shortcut                   |
| :-------------------- | :------------------------- |
| Reload config         | `Ctrl + A`, then `R`       |
| Session tree          | `Ctrl + A`, then `S`       |
| Last active window    | `Ctrl + A`, then `Space`   |
| Toggle zoom           | `Ctrl + A`, then `M`       |
| New window            | `Ctrl + A`, then `C`       |
| Split horizontal      | `Ctrl + A`, then `         |
| Split horizontal full | `Ctrl + A`, then `\\`      |
| Split vertical        | `Ctrl + A`, then `-`       |
| Split vertical full   | `Ctrl + A`, then `_`       |
| Close focus           | `Ctrl + A`, then `X`       |
| Focus pane            | `Ctrl + H/J/K/L`           |
| Resize down/up        | `Ctrl + A`, then `J` / `K` |
| Resize left/right     | `Ctrl + A`, then `H` / `L` |
| Copy mode             | `Ctrl + A`, then `[`       |
| Paste                 | `Ctrl + A`, then `]`       |
| Install plugins       | `Ctrl + A`, then `I`       |
| Update plugins        | `Ctrl + A`, then `U`       |
| Uninstall plugins     | `Ctrl + A`, then `Alt + U` |

## CLI & Shell

### Nushell

| Action                | Shortcut      |
| :-------------------- | :------------ |
| Move to line start    | `Ctrl + A`    |
| Move to line end      | `Ctrl + E`    |
| Delete to line start  | `Ctrl + U`    |
| Delete to line end    | `Ctrl + K`    |
| Delete word backward  | `Ctrl + W`    |
| Clear screen          | `Ctrl + L`    |
| Cancel                | `Ctrl + C`    |
| Previous/next history | `Up` / `Down` |
| Accept completion     | `Tab`         |
| Previous completion   | `Shift + Tab` |
| Edit file with `fzf`  | `Ctrl + T`    |
| Jump directory        | `Alt + C`     |
| Search history        | `Ctrl + R`    |

| Alias | Command                |
| :---- | :--------------------- |
| `y`   | `yazi` (preserves cwd) |
| `gg`  | `lazygit`              |
| `n`   | `nvim`                 |
| `j`   | `just`                 |
| `jf`  | `just fmt`             |
| `jl`  | `just lint`            |
| `hk`  | `just hotkeys`         |

### Yazi

| Action                     | Shortcut      |
| :------------------------- | :------------ |
| Chmod on selected files    | `C`, then `M` |
| Copy file contents         | `C`, then `Y` |
| Toggle preview pane        | `F3`          |
| Maximize / restore preview | `F4`          |
| Compress with `ouch`       | `Shift + C`   |
| Quit                       | `Q`           |
| Open file                  | `Enter`       |
| Select item                | `Space`       |
| Yank/copy                  | `Y`           |
| Paste                      | `P`           |
| Cancel task                | `Esc`         |
| Toggle hidden              | `.`           |
| Shell                      | `;`           |
| Command                    | `:`           |
| Help                       | `?`           |

## AI Agents

### OpenCode

Leader key: `Ctrl + X`

| Action               | Shortcut                                        |
| :------------------- | :---------------------------------------------- |
| App exit             | `Ctrl + C`, `Ctrl + D`, or `Ctrl + X`, then `Q` |
| Interrupt            | `Esc`                                           |
| New session          | `Ctrl + X`, then `N`                            |
| List sessions        | `Ctrl + X`, then `L`                            |
| Compact session      | `Ctrl + X`, then `C`                            |
| Copy message         | `Ctrl + X`, then `Y`                            |
| Undo / redo message  | `Ctrl + X`, then `U` / `R`                      |
| Submit               | `Enter`                                         |
| New line             | `Shift + Enter`, `Ctrl + Enter`, `Alt + Enter`  |
| Command palette      | `Ctrl + P`                                      |
| Model list           | `Ctrl + X`, then `M`                            |
| Cycle recent model   | `F2` / `Shift + F2`                             |
| Agent list           | `Ctrl + X`, then `A`                            |
| Open external editor | `Ctrl + X`, then `E`                            |

### Claude Code

| Action            | Shortcut   |
| :---------------- | :--------- |
| External editor   | `Ctrl + E` |
| Cancel generation | `Ctrl + C` |
| Accept suggestion | `Tab`      |

Common commands: `/help`, `/compact`, `/cost`, `/exit`.

### Codex

| Action            | Shortcut   |
| :---------------- | :--------- |
| Cancel generation | `Ctrl + C` |
| Exit              | `Ctrl + D` |

Common commands: `/help`, `/clear`, `/compact`, `/model`.

### Kimi Code

| Action            | Shortcut   |
| :---------------- | :--------- |
| Cancel generation | `Ctrl + C` |
| Exit              | `Ctrl + D` |

## Window Management

### Hyprland

Mod key: `Super`

| Action                   | Shortcut                           |
| :----------------------- | :--------------------------------- |
| Terminal (Ghostty)       | `Super + Enter`                    |
| Launcher (Walker)        | `Super + R`                        |
| Browser (Zen)            | `Super + B`                        |
| File manager (Thunar)    | `Super + E`                        |
| File manager (Yazi)      | `Super + Shift + E`                |
| Audio (Pavucontrol)      | `Super + A`                        |
| Close window             | `Super + Q`                        |
| Toggle fullscreen        | `Super + F`                        |
| Toggle floating          | `Super + Shift + F`                |
| Move focus               | `Super + Arrow Keys`               |
| Resize mode              | `Super + Ctrl + R`                 |
| Switch workspace 1-10    | `Super + 1`–`9` (`0` = 10)         |
| Move window to workspace | `Super + Shift + 1`–`9` (`0` = 10) |
| Reload Hyprland          | `Super + Shift + R`                |
| Lock screen              | `Super + L`                        |
| Power menu               | `Super + Backspace`                |
| Screenshot (region)      | `Super + Shift + S`                |
| Screenshot (output)      | `Print`                            |
| Volume up/down           | `XF86AudioRaise/Lower`             |
| Brightness up/down       | `XF86MonBrightnessUp/Down`         |
| Media controls           | `XF86AudioPlay/Next/Prev`          |

## Conflict Map

Input is consumed from the outside in. The first layer that recognizes a shortcut wins:

```text
Hyprland (Wayland compositor)
    ↓
Terminal emulator (Alacritty / Ghostty / WezTerm)
    ↓
Terminal multiplexer (Zellij / Tmux) — only when running
    ↓
Shell (Nushell)
    ↓
Application / editor (Neovim / Helix / Yazi)
```

Known collisions to watch for:

| Shortcut             | Claimed by            | Also used by                         | Workaround                                |
| :------------------- | :-------------------- | :----------------------------------- | :---------------------------------------- |
| `Ctrl + H/J/K/L`     | Tmux pane focus       | Helix view jump                      | Use Tmux prefix + arrow keys inside Helix |
| `Ctrl + H`           | Zellij Move mode      | Helix view left                      | Use Zellij Locked mode (`Ctrl + G`)       |
| `Ctrl + Shift + C/V` | Terminal copy/paste   | Shell / TUI copy/paste               | Terminal wins; use app-specific bindings  |
| `Super + E`          | Hyprland file manager | Some apps use `Super + E` internally | Hyprland wins                             |

## Discoverability Tips

| Tool     | How to remember shortcuts                         |
| :------- | :------------------------------------------------ |
| Neovim   | Press `Space` and pause for `which-key.nvim`      |
| Helix    | Press `Space` to open the command menu            |
| Zellij   | Press `Ctrl + P`/`Ctrl + T`/etc. to see mode keys |
| Tmux     | Press `Ctrl + A`, then `?` for a key list         |
| Yazi     | Press `?` inside Yazi for the full keymap         |
| OpenCode | Press `Ctrl + X` and wait for the leader menu     |

Use `just hotkeys` (or `hk` in Nushell) to fuzzy-search this cheatsheet from anywhere in the terminal.
