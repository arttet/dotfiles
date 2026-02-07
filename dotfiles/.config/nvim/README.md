# My Neovim Config

This is a personalized Neovim configuration based on NvChad, tailored for development with a focus on debugging and a smooth user experience.

## 🔌 Plugins & Keybindings

Below is a list of the core plugins used in this configuration, along with their associated custom keybindings.

### Debugging (DAP)

Debugging is handled by a suite of plugins working together, with `nvim-dap` as the core.

- **[mfussenegger/nvim-dap](https://github.com/mfussenegger/nvim-dap)**: Debug Adapter Protocol client.
- **[rcarriga/nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)**: A UI for `nvim-dap`.
- **[nvim-telescope/telescope-dap.nvim](https://github.com/nvim-telescope/telescope-dap.nvim)**: DAP integration for Telescope.
- **[theHamsta/nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text)**: Shows debug info inline.

| Keybinding      | Description                      |
| --------------- | -------------------------------- |
| `<F5>`          | Start/Continue debugging         |
| `<F6>`          | Run last debug configuration     |
| `<F7>`          | Toggle the DAP UI                |
| `<F8>`          | Set a conditional breakpoint     |
| `<F9>`          | Toggle a breakpoint              |
| `<F10>`         | Step Over                        |
| `<F11>`         | Step Into                        |
| `<F12>`         | Step Out                         |
| `<leader>dc`    | Select debug configuration       |

### Terminal CLI Integration

| Keybinding      | Description                          |
| --------------- | ------------------------------------ |
| `<leader>tt`    | Open Terminal in a new tab           |
| `<leader>td`    | Open LazyDocker in a new tab         |
| `<leader>tl`    | Open LazyGit in a new tab            |
| `<leader>tu`    | Open GitUI in a new tab              |
| `<leader>tc`    | Open GitHub Copilot CLI in a new tab |
| `<leader>tg`    | Open Gemini CLI in a new tab         |

### UI & General Editor Enhancements

- **[folke/noice.nvim](https://github.com/folke/noice.nvim)**: Replaces the Neovim UI for messages, cmdline and popups.
- **[mg979/vim-visual-multi](https://github.com/mg979/vim-visual-multi)**: Multiple cursors.

| Keybinding      | Description                      |
| --------------- | -------------------------------- |
| `<leader>ph`    | Pick a message from Noice history|
| `i: jk`         | Escape from insert mode          |
| `;`             | Enter command mode               |
| `<C-q>`         | Close window/tab                 |
| `<A-t>`         | Open a new terminal buffer       |
| `t: <C-q>`      | Close the terminal               |

### Core Functionality Plugins

These plugins provide essential functionality but do not have custom keybindings assigned in the main `mappings.lua` file. They are configured to work automatically or via commands.

- **[WhoIsSethDaniel/mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim)**: Automatically installs LSP servers, DAPs, linters, and formatters.
- **[nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)**: Provides advanced syntax highlighting and code parsing.
- **[stevearc/conform.nvim](https://github.com/stevearc/conform.nvim)**: Code formatting, configured to run on save.
- **[neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)**: Configurations for the Language Server Protocol.
- **[folke/todo-comments.nvim](https://github.com/folke/todo-comments.nvim)**: Highlights TODO, FIXME, etc.
- **[wakatime/vim-wakatime](https://github.com/wakatime/vim-wakatime)**: Automatic time tracking for projects.

### Debug Vim Configuration

- Check for errors on startup:

```vim
:messages
```

- Check Plugin Health

```vim
:checkhealth
```

- Verify plugin loading:

```vim
:Lazy profile
```

- Check LSP status:

```vim
:LspInfo
```

- Test DAP configuration:

```vim
:lua print(vim.inspect(require('dap').configurations))
```
