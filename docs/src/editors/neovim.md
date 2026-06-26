# Neovim (NvChad)

A highly optimized Neovim configuration based on **NvChad**, focusing on developer productivity, aesthetics, and modern Lua APIs.

## Configuration Paths

- Main entry: `dotfiles/.config/nvim/init.lua`
- Mappings: `dotfiles/.config/nvim/lua/mappings.lua`
- Plugins: `dotfiles/.config/nvim/lua/plugins/init.lua`

## Leader Key

The **leader** key is `Space`.

## Editor

| Action              | Mode     | Shortcut      |
| :------------------ | :------- | :------------ |
| Enter command mode  | Normal   | `:`           |
| Close window/tab    | Normal   | `Ctrl + Q`    |
| Escape insert mode  | Insert   | `J`, then `K` |
| New terminal buffer | Normal   | `Alt + T`     |
| Close terminal      | Terminal | `Ctrl + Q`    |

## Pickers & Git

| Action                    | Mode   | Shortcut                    |
| :------------------------ | :----- | :-------------------------- |
| Telescope message history | Normal | `Space`, then `P`, then `H` |
| Full git blame            | Normal | `Space`, then `G`, then `F` |

## Terminal Integrations

Open tools in a new Neovim tab.

| Tool           | Action           | Shortcut                    |
| :------------- | :--------------- | :-------------------------- |
| **Terminal**   | Open terminal    | `Space`, then `T`, then `T` |
| **LazyGit**    | Open Git TUI     | `Space`, then `T`, then `L` |
| **GitUI**      | Open Git TUI     | `Space`, then `T`, then `U` |
| **LazyDocker** | Open Docker TUI  | `Space`, then `T`, then `D` |
| **Copilot**    | Open Copilot CLI | `Space`, then `T`, then `C` |
| **Gemini**     | Open Gemini CLI  | `Space`, then `T`, then `G` |

## Debugging (DAP)

| Action                 | Shortcut                    |
| :--------------------- | :-------------------------- |
| Start/Continue         | `F5`                        |
| Run Last               | `F6`                        |
| Toggle DAP UI          | `F7`                        |
| Conditional Breakpoint | `F8`                        |
| Toggle Breakpoint      | `F9`                        |
| Step Over              | `F10`                       |
| Step Into              | `F11`                       |
| Step Out               | `F12`                       |
| Select Config          | `Space`, then `D`, then `C` |

## Discoverability

Press `Space` and pause briefly (or press it twice) to open `which-key.nvim`. It shows every available keybinding grouped by prefix, so you rarely need to leave the editor to remember a shortcut.
