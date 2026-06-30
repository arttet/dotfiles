# Tmux

Tmux 3.2 or newer is required. The configuration uses `Ctrl + A` as its prefix, vi-style copy mode, a `tmux2k`
status line, and plugins pinned and deployed by `vendir`. TPM is not used.

## Configuration

- Config: `dotfiles/.config/tmux/tmux.conf`
- Vendored plugins: `dotfiles/.config/tmux/plugins/`
- Primary terminal font: a patched Nerd Font, for example IosevkaTerm Nerd Font

Run `just sync` after checkout or after a plugin lock update. Plugin executables are used directly from the vendored
directory; dotfiles do not install global binaries. `tmux2k` also requires Bash 5.2 or newer for its colors to render
correctly.

## General shortcuts

| Action               | Shortcut                   |
| :------------------- | :------------------------- |
| Reload configuration | `Ctrl + A`, then `r`       |
| Session tree         | `Ctrl + A`, then `S`       |
| New tmux window      | `Ctrl + A`, then `c`       |
| Last active window   | `Ctrl + A`, then `Space`   |
| Tmux FZF launcher    | `Ctrl + A`, then `F`       |
| Yazi popup           | `Alt + Y`                  |
| Nushell popup        | `Alt + T`                  |
| Lazygit popup        | `Alt + G`                  |
| Configuration menu   | `Alt + E`                  |
| Enter copy mode      | `Ctrl + A`, then `v`       |
| Paste tmux buffer    | `Ctrl + A`, then `P`       |
| Toggle zoom          | `Ctrl + A`, then `M`       |
| Focus adjacent pane  | `Alt + ←/↓/↑/→`            |
| Resize pane          | `Ctrl + A`, then `h/j/k/l` |

The split shortcuts are `|` and `\` for horizontal splits, and `-` and `_` for vertical splits. Uppercase `\` and
`_` create a full-size pane.

`Ctrl + A`, then `c` creates a tmux window, not a terminal tab. Terminal tabs remain terminal-specific, for example
`Ctrl + Shift + T` in WezTerm and Ghostty.

Pane navigation with `Alt` and the arrow keys is global and does not require the tmux prefix. The terminal emulator
must pass these key combinations through to tmux rather than reserving them for its own shortcuts. The repository
config explicitly forwards these sequences in Alacritty, WezTerm, and Ghostty.

## Popup tools

Install Yazi, Nushell, Lazygit, and Helix (`hx`) with the system package manager. The popup bindings run existing
system binaries and do not install them automatically.

`Alt + Y` opens Yazi at 90% of the client width and height. `Alt + T` opens an interactive login Nushell at 80%, and
`Alt + G` opens Lazygit at 90%. All three inherit the active pane's working directory and close when the launched
process exits. The prefix variants (`Ctrl + A`, then `Ctrl + Y`, `Ctrl + T`, or `Ctrl + G`) remain available as
fallbacks.

`Alt + E` opens a centered configuration menu; `Ctrl + A`, then `e` is its fallback. The menu uses Helix in a popup
to edit Nushell's `config.nu` and `env.nu`, the tmux configuration, `yazi.toml`, or Lazygit's `config.yml`. The
standard `Ctrl + A`, then `d` detach binding is preserved.

The direct Alt bindings are global tmux shortcuts. Outside copy mode, tmux consumes them before the active shell or
TUI can use them. In vi copy mode, tmux-yank retains its table-local `Alt + Y` behavior. Alacritty, Ghostty, and WezTerm
explicitly forward all four Alt sequences.

## Clipboard

`escape-time` is set to `0`, so `Esc`-prefixed key handling is immediate. `detach-on-destroy` is set to `off`, so
closing the last window in a session does not immediately detach the client.

Enter copy mode with `Ctrl + A`, then `v` or `Ctrl + A`, then `[`. Press `v` to begin selection, move with vi keys,
and press `y` or `Enter` to copy and leave copy mode. `Ctrl + A`, then `P` pastes the tmux buffer. With mouse mode
enabled, dragging with the primary button and releasing copies the selection automatically.

`set-clipboard on` is enabled, so tmux can forward copies through the terminal clipboard path when supported.
`tmux-yank` remains vendored for mouse handling and external clipboard backends such as `clip.exe` on WSL, `wl-copy` on
Wayland, `xsel` or `xclip` on X11, and `pbcopy` on macOS.

WSL clipboard acceptance remains a post-merge check because no WSL distribution is installed in the current test
environment. Verify both keyboard and mouse copy with `Привет — 你好 — مرحبا — 🚀`. Start with auto-detection; if it
fails, configure `@override_copy_command 'clip.exe'`. Use `win32yank.exe -i --crlf` only if `clip.exe` is confirmed to
corrupt Unicode.

## Status line

The status line is provided by `tmux2k` and uses the upstream `gruvbox` theme with:

- `@tmux2k-theme 'gruvbox'`
- `@tmux2k-icons-only false`
- `@tmux2k-left-plugins "session git cwd"`
- `@tmux2k-right-plugins "battery time"`
- `@tmux2k-window-list-format '#I:#W'`
- `@tmux2k-window-list-alignment 'absolute-centre'`

This yields session, Git, and current-directory information on the left, a centered window list, and battery plus time
on the right. `tmux2k` includes its own battery plugin, so there is no separate `tmux-battery` dependency anymore.
Desktops or hosts without a visible battery may show the plugin's missing-battery indicator instead of a percentage.
Icons and their text labels are both displayed.

The config still enables `tmux-256color`, RGB terminal overrides, and `allow-passthrough on` so true-color themes and
modern terminal integrations render correctly. `tmux2k` refreshes dynamic plugins every five seconds via
`@tmux2k-refresh-rate 5`. Rounded separators and Nerd Font glyphs are part of the intended presentation.

The bottom status area is two rows high. The upper row is intentionally empty, keeping pane output visually separated
from the rendered tmux2k status line. This costs one additional terminal row. Reloading the configuration preserves
the populated status format instead of replacing it with the empty spacer.

`tmux-fzf` is bound directly to its vendored `main.sh` launcher. The script runs in the background only after pressing
`Ctrl + A`, then `F`, so tmux startup does not execute FZF or wait for plugin initialization. This does not rely on TPM.

## Smug project session

Smug is an external session manager, not a tmux plugin. Install tmux, Smug 0.3.18 or newer, Helix (`hx`), and
Lazygit using the system package manager. Start the deployable project layout from the repository root:

```sh
smug start dotfiles dotfiles_root="$PWD"
```

On PowerShell, use:

```powershell
smug start dotfiles "dotfiles_root=$($PWD.Path)"
```

Smug 0.3.18 has a Windows panic when `-f` is used without a positional session name. Prefer `smug start dotfiles`
against the deployed config in `~/.config/smug/dotfiles.yml`. If a custom file is unavoidable, use a placeholder
name:

```powershell
smug start placeholder -f .\dotfiles.yml "dotfiles_root=$($PWD.Path)"
```

The session attaches automatically and creates `editor`, `shell`, and `git` windows in that order. `editor` is
selected and runs `hx .`; `git` runs `lazygit`; `shell` starts no services. Stop it with `smug stop dotfiles`. Manual
tmux sessions remain available and are independent of this declarative project layout.
