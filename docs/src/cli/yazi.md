# Yazi

A blazing fast terminal file manager written in Rust, based on async I/O.

## Configuration Paths

- Config: `dotfiles/.config/yazi/yazi.toml`
- Keymaps: `dotfiles/.config/yazi/keymap.toml`
- Plugins: `dotfiles/.config/yazi/plugins/`

## Custom Keybindings

| Action                     | Shortcut      |
| :------------------------- | :------------ |
| Chmod on selected files    | `C`, then `M` |
| Copy file contents         | `C`, then `Y` |
| Toggle preview pane        | `F3`          |
| Maximize / restore preview | `F4`          |
| Compress with `ouch`       | `Shift + C`   |

## Common Defaults

| Action        | Shortcut |
| :------------ | :------- |
| Quit          | `Q`      |
| Open file     | `Enter`  |
| Select item   | `Space`  |
| Yank/copy     | `Y`      |
| Paste         | `P`      |
| Cancel task   | `Esc`    |
| Toggle hidden | `.`      |
| Shell         | `;`      |
| Command       | `:`      |
| Help          | `?`      |

For the full default keymap, see the upstream Yazi documentation or press `?` inside Yazi.

## Plugins

- `chmod`: Quick permission management.
- `copy-file-contents`: Directly copy file data to clipboard.
- `ouch`: Integration with the Ouch compression tool.
- `toggle-pane`: Flexible workspace layout management.
- `full-border`: Full border UI.
- `git`: Git status indicators.
- `piper`: Pipe operations.
- `starship`: Starship prompt integration.
- `yaziline`: Custom status line.
- `torrent-preview`: Torrent file preview.
