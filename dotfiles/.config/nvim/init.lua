-- Neovim entry point (0.12+, vim.pack, no NvChad).
--
-- Load order:
--   1. vim.loader.enable()  -- Lua module cache, MUST be the first line for the startup win.
--   2. core modules          -- options, diagnostics, autocmds, keymaps, LSP (no plugins).
--   3. plugin/*.lua          -- auto-sourced alphabetically after init.lua; each file is one
--                               `vim.pack.add` + setup. Filename prefix == load order.
--
-- See dotfiles/.config/nvim/AGENTS.md for the conventions agents must preserve.

vim.loader.enable()

-- Leader keys must be set before any mapping or plugin is sourced.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable netrw up front; nvim-tree owns file exploration.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require "core"
