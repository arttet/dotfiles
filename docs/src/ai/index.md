# AI Agents

This dotfiles repository configures four AI coding agents. This page covers the fastest ways to interact with each one: essential keybindings, common commands, and where their configuration lives.

## Configuration Paths

| Tool            | Configuration                                                                       |
| :-------------- | :---------------------------------------------------------------------------------- |
| **OpenCode**    | `dotfiles/.config/opencode/opencode.jsonc`, `dotfiles/.config/opencode/tui.json`    |
| **Claude Code** | `dotfiles/.config/claude/keybindings.json`, `dotfiles/.config/claude/settings.json` |
| **Codex**       | `dotfiles/.config/codex/config.toml`                                                |
| **Kimi Code**   | `dotfiles/.config/kimi-code/config.toml`, `dotfiles/.config/kimi-code/tui.toml`     |

## OpenCode

OpenCode is configured to start in **Plan** mode by default. The TUI uses a leader-key style menu.

### Global

| Action     | Shortcut                                        |
| :--------- | :---------------------------------------------- |
| Leader key | `Ctrl + X`                                      |
| App exit   | `Ctrl + C`, `Ctrl + D`, or `Ctrl + X`, then `Q` |
| Interrupt  | `Esc`                                           |

### Sessions

| Action          | Shortcut             |
| :-------------- | :------------------- |
| New session     | `Ctrl + X`, then `N` |
| List sessions   | `Ctrl + X`, then `L` |
| Timeline view   | `Ctrl + X`, then `G` |
| Export session  | `Ctrl + X`, then `X` |
| Compact session | `Ctrl + X`, then `C` |

### Messages

| Action            | Shortcut                                                       |
| :---------------- | :------------------------------------------------------------- |
| Page up/down      | `Page Up` / `Page Down` or `Ctrl + Alt + B` / `Ctrl + Alt + F` |
| Half page up/down | `Ctrl + Alt + U` / `Ctrl + Alt + D`                            |
| First / last      | `Ctrl + G` / `Home` or `Ctrl + Alt + G` / `End`                |
| Copy message      | `Ctrl + X`, then `Y`                                           |
| Undo / redo       | `Ctrl + X`, then `U` / `Ctrl + X`, then `R`                    |
| Toggle conceal    | `Ctrl + X`, then `H` (uppercase)                               |

### Input

| Action                | Shortcut                                                   |
| :-------------------- | :--------------------------------------------------------- |
| Submit                | `Enter`                                                    |
| New line              | `Shift + Enter`, `Ctrl + Enter`, `Alt + Enter`, `Ctrl + J` |
| History previous/next | `Up` / `Down`                                              |
| Command palette       | `Ctrl + P`                                                 |
| Model list            | `Ctrl + X`, then `M`                                       |
| Cycle recent model    | `F2` / `Shift + F2`                                        |
| Agent list            | `Ctrl + X`, then `A`                                       |
| Cycle agent           | `Tab` / `Shift + Tab`                                      |

### Editor / Text

| Action                | Shortcut                |
| :-------------------- | :---------------------- |
| Open external editor  | `Ctrl + X`, then `E`    |
| Word forward/backward | `Alt + F` / `Alt + B`   |
| Delete word forward   | `Alt + D`               |
| Delete word backward  | `Ctrl + W`              |
| Undo / redo           | `Ctrl + -` / `Ctrl + .` |

> **Tip:** The full OpenCode keymap is defined in `dotfiles/.config/opencode/tui.json`.

## Claude Code

Claude Code is configured with a strict permission model and minimal custom keybindings.

### Keybindings

| Action          | Shortcut   |
| :-------------- | :--------- |
| External editor | `Ctrl + E` |

### Common Commands

Type these in the Claude Code prompt:

| Command    | Purpose                      |
| :--------- | :--------------------------- |
| `/help`    | Show help                    |
| `/compact` | Compact conversation context |
| `/cost`    | Show token / cost usage      |
| `/exit`    | Exit Claude Code             |

### Session Controls

| Action            | Shortcut   |
| :---------------- | :--------- |
| Cancel generation | `Ctrl + C` |
| Accept suggestion | `Tab`      |

## Codex

Codex is configured for workspace-level access with explicit approval. Its keybindings come from the upstream Codex TUI.

### CLI

| Command                   | Purpose                        |
| :------------------------ | :----------------------------- |
| `codex`                   | Start Codex in the current dir |
| `codex --model gpt-5.5`   | Use a specific model           |
| `codex --approval-policy` | Set approval policy            |

### Common TUI Shortcuts

| Action            | Shortcut   |
| :---------------- | :--------- |
| Cancel generation | `Ctrl + C` |
| Exit              | `Ctrl + D` |

### Common Commands

| Command    | Purpose                 |
| :--------- | :---------------------- |
| `/help`    | Show available commands |
| `/clear`   | Clear the conversation  |
| `/compact` | Compact context         |
| `/model`   | Change model            |

## Kimi Code

Kimi Code is configured to run in plan mode by default with manual permissions.

### CLI

| Command           | Purpose                            |
| :---------------- | :--------------------------------- |
| `kimi-code`       | Start Kimi Code in the current dir |
| `kimi-code /path` | Open a specific project            |

### TUI

Kimi Code uses the upstream TUI keybindings. See the official Kimi Code documentation for the latest list.

| Action            | Shortcut   |
| :---------------- | :--------- |
| Cancel generation | `Ctrl + C` |
| Exit              | `Ctrl + D` |

## Permission Summary

All four agents follow a default-deny pattern for sensitive files and destructive commands:

| Category    | Default | Examples                                  |
| :---------- | :------ | :---------------------------------------- |
| Read        | Allow   | Source files, configs, public docs        |
| Secrets     | Deny    | `.env`, `*.pem`, SSH keys, kubeconfig     |
| Write       | Ask     | File edits, new files, refactors          |
| Execute     | Ask     | Build scripts, test commands, shell tasks |
| Network     | Ask     | Web fetch, package installs               |
| Destructive | Deny    | `rm -rf`, `git push`, `kubectl delete`    |

For exact rules, inspect the `permissions` block in each agent's configuration file.
