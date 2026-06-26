# Terminal Stack

This project uses a unified configuration strategy for multiple terminal emulators to ensure a consistent experience regardless of the environment.

## Supported Terminals

- **Alacritty**: High-performance, cross-platform.
- **Ghostty**: Modern, feature-rich terminal.
- **WezTerm**: Highly configurable, GPU-accelerated.

## Unified Configuration Philosophy

All terminals are configured with shared parameters:

- **Font**: `IosevkaTerm Nerd Font` (Primary), size `13.0`.
- **Opacity**: `0.95` with background blur enabled.
- **Padding**: `5px` on all sides.
- **Shell**: `nu --login --interactive` (Nushell).

## Unified Hotkeys

The following shortcuts are consistent across Alacritty, Ghostty, and WezTerm. We prioritize `Ctrl + Shift` for terminal actions to avoid conflicts with shell and TUI tools.

| Category      | Action             | Shortcut                |
| :------------ | :----------------- | :---------------------- |
| **Windows**   | New window         | `Ctrl + Shift + N`      |
| **Windows**   | Close window       | `Ctrl + Shift + Q`      |
| **Tabs**      | New tab            | `Ctrl + Shift + T`      |
| **Tabs**      | Close tab          | `Ctrl + Shift + W`      |
| **View**      | Toggle fullscreen  | `F11` or `Ctrl + Enter` |
| **Clipboard** | Copy               | `Ctrl + Shift + C`      |
| **Clipboard** | Paste              | `Ctrl + Shift + V`      |
| **Zoom**      | Increase font size | `Ctrl + Shift + +`      |
| **Zoom**      | Decrease font size | `Ctrl + Shift + -`      |
| **Zoom**      | Reset font size    | `Ctrl + Shift + 0`      |

> **Note:** Terminal shortcuts sit at the top of the input stack. If a shortcut is also bound in your multiplexer or editor, the terminal usually intercepts it first. See the [Hotkey Conflict Map](/cheatsheet#conflict-map) for a full breakdown.

## Configuration Paths

| Terminal      | Path                                        |
| :------------ | :------------------------------------------ |
| **Alacritty** | `dotfiles/.config/alacritty/alacritty.toml` |
| **Ghostty**   | `dotfiles/.config/ghostty/config`           |
| **WezTerm**   | `dotfiles/.config/wezterm/wezterm.lua`      |
