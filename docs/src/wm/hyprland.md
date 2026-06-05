# Hyprland

A dynamic tiling Wayland compositor that doesn't sacrifice on appearance.

## Configuration Paths

- Config: `dotfiles/.config/hypr/hyprland.lua`
- Idlehands: `dotfiles/.config/hypr/hypridle.conf`
- Lockscreen: `dotfiles/.config/hypr/hyprlock.conf`

## Keybindings

The **Super** (Mod) key is used for most system actions.

### Applications

| Tool             | Action          | Shortcut            |
| :--------------- | :-------------- | :------------------ |
| **Terminal**     | Ghostty         | `Super + Return`    |
| **Launcher**     | Walker          | `Super + R`         |
| **Browser**      | Zen Browser     | `Super + B`         |
| **File Manager** | Thunar          | `Super + E`         |
| **File Manager** | Yazi (Terminal) | `Super + Shift + E` |
| **Audio**        | Pavucontrol     | `Super + A`         |

### Window Management

| Action            | Shortcut                               |
| :---------------- | :------------------------------------- |
| Close Window      | `Super + Q`                            |
| Toggle Fullscreen | `Super + F`                            |
| Toggle Floating   | `Super + Shift + F`                    |
| Move Focus        | `Super + Arrow Keys`                   |
| Resize Window     | `Super + Ctrl + R` (Enter Resize Mode) |

### Workspaces

| Action                     | Shortcut                     |
| :------------------------- | :--------------------------- |
| Switch to Workspace (1-10) | `Super + 1-9 (0=10)`         |
| Move Window to Workspace   | `Super + Shift + 1-9 (0=10)` |

### System & Media

| Action              | Shortcut                   |
| :------------------ | :------------------------- |
| Reload Hyprland     | `Super + Shift + R`        |
| Lock Screen         | `Super + L`                |
| Power Menu          | `Super + Backspace`        |
| Screenshot (Region) | `Super + Shift + S`        |
| Screenshot (Output) | `Print`                    |
| Volume Up/Down      | `XF86AudioRaise/Lower`     |
| Brightness Up/Down  | `XF86MonBrightnessUp/Down` |
| Media Controls      | `XF86AudioPlay/Next/Prev`  |
