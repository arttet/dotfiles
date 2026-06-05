# Neovim (NvChad)

A highly optimized Neovim configuration based on **NvChad**, focusing on developer productivity, aesthetics, and modern Lua APIs.

## Configuration Paths

- Main entry: `dotfiles/.config/nvim/init.lua`
- Mappings: `dotfiles/.config/nvim/lua/mappings.lua`
- Plugins: `dotfiles/.config/nvim/lua/plugins/init.lua`

## Keybindings

### Editor

| Action              | Mode     | Shortcut |
| :------------------ | :------- | :------- |
| Enter command mode  | Normal   | `;`      |
| Close window/tab    | Normal   | `<C-q>`  |
| Escape insert mode  | Insert   | `jk`     |
| New terminal buffer | Normal   | `<A-t>`  |
| Close terminal      | Terminal | `<C-q>`  |

### Pickers & Git

| Action                    | Mode   | Shortcut     |
| :------------------------ | :----- | :----------- |
| Telescope message history | Normal | `<leader>ph` |
| Full git blame            | Normal | `<leader>gf` |

### Terminal Integrations

Open tools in a new Neovim tab.

| Tool           | Action           | Shortcut     |
| :------------- | :--------------- | :----------- |
| **Terminal**   | Open terminal    | `<leader>tt` |
| **LazyGit**    | Open Git TUI     | `<leader>tl` |
| **GitUI**      | Open Git TUI     | `<leader>tu` |
| **LazyDocker** | Open Docker TUI  | `<leader>td` |
| **Copilot**    | Open Copilot CLI | `<leader>tc` |
| **Gemini**     | Open Gemini CLI  | `<leader>tg` |

### Debugging (DAP)

| Action                 | Shortcut     |
| :--------------------- | :----------- |
| Start/Continue         | `<F5>`       |
| Run Last               | `<F6>`       |
| Toggle DAP UI          | `<F7>`       |
| Conditional Breakpoint | `<F8>`       |
| Toggle Breakpoint      | `<F9>`       |
| Step Over              | `<F10>`      |
| Step Into              | `<F11>`      |
| Step Out               | `<F12>`      |
| Select Config          | `<leader>dc` |
