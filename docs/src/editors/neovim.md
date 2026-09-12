# Neovim

A Neovim 0.12+ configuration built on the **built-in `vim.pack` plugin manager** with native LSP,
diagnostics and treesitter. No NvChad, no `lazy.nvim`, no `nvim-lspconfig`.

## Configuration Paths

- Main entry: `dotfiles/.config/nvim/init.lua`
- Keymaps: `dotfiles/.config/nvim/lua/core/keymaps.lua`
- Plugins: `dotfiles/.config/nvim/plugin/NN-name.lua` — one plugin per file, sourced in filename order
- Plugin settings: `dotfiles/.config/nvim/lua/configs/`
- Lockfile: `dotfiles/.config/nvim/nvim-pack-lock.json` — never hand-edited

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

## Pickers, Git & Theme

| Action                              | Mode   | Shortcut                    |
| :---------------------------------- | :----- | :-------------------------- |
| Message history (`noice.nvim`)      | Normal | `Space`, then `P`, then `H` |
| Full git blame (`gitsigns`)         | Normal | `Space`, then `G`, then `F` |
| Toggle light/dark theme (`gruvbox`) | Normal | `Space`, then `T`, then `H` |

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
