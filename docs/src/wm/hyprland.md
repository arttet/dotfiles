# Hyprland

A dynamic tiling Wayland compositor that doesn't sacrifice on appearance.

## Configuration Paths

- Config: `dotfiles/.config/hypr/hyprland.lua`
- Idle: `dotfiles/.config/hypr/hypridle.conf`
- Lockscreen: `dotfiles/.config/hypr/hyprlock.conf`

## Keybindings

The **Super** (Mod) key is used for most system actions. On most keyboards this is the Windows/Command key.

### Applications

| Tool             | Action          | Shortcut            |
| :--------------- | :-------------- | :------------------ |
| **Terminal**     | Ghostty         | `Super + Enter`     |
| **Launcher**     | Walker          | `Super + R`         |
| **Browser**      | Zen Browser     | `Super + B`         |
| **File Manager** | Thunar          | `Super + E`         |
| **File Manager** | Yazi (Terminal) | `Super + Shift + E` |
| **Audio**        | Pavucontrol     | `Super + A`         |

### Window Management

| Action            | Shortcut                               |
| :---------------- | :------------------------------------- |
| Close window      | `Super + Q`                            |
| Toggle fullscreen | `Super + F`                            |
| Toggle floating   | `Super + Shift + F`                    |
| Move focus        | `Super + Arrow Keys`                   |
| Resize window     | `Super + Ctrl + R` (enter resize mode) |

### Workspaces

| Action                     | Shortcut                           |
| :------------------------- | :--------------------------------- |
| Switch to workspace (1-10) | `Super + 1`–`9` (`0` = 10)         |
| Move window to workspace   | `Super + Shift + 1`–`9` (`0` = 10) |

### System & Media

| Action              | Shortcut                   |
| :------------------ | :------------------------- |
| Reload Hyprland     | `Super + Shift + R`        |
| Lock screen         | `Super + L`                |
| Power menu          | `Super + Backspace`        |
| Screenshot (region) | `Super + Shift + S`        |
| Screenshot (output) | `Print`                    |
| Volume up/down      | `XF86AudioRaise/Lower`     |
| Brightness up/down  | `XF86MonBrightnessUp/Down` |
| Media controls      | `XF86AudioPlay/Next/Prev`  |

> **Note:** Hyprland shortcuts consume input before it reaches applications. See the [conflict map](/cheatsheet#conflict-map) if a shortcut stops working inside an app.
