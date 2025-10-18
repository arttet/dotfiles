# Gemini Guidelines for Neovim Lua Configuration

This document provides expert guidance for Gemini working with this Neovim configuration written in Lua.

## Requirements

- **Minimum Neovim Version**: 0.11+
- **Language**: Lua
- **Plugin Manager**: lazy.nvim

## Important Notes

- Use only APIs available in Neovim 0.11+
- Avoid deprecated functions (e.g., vim.loop → vim.uv, lspconfig → vim.lsp)
- Test solutions on Neovim 0.11 before suggesting them

## Configuration Overview

- **Framework**: This is a NvChad-based Neovim configuration.
- **Plugin Manager**: `lazy.nvim` is used for plugin management.
- **Structure**: The configuration is modular. Key files include:
  - `init.lua`: Main entry point.
  - `lua/options.lua`: Vim options.
  - `lua/mappings.lua`: Keybindings.
  - `lua/autocmds.lua`: Autocommands.
  - `lua/chadrc.lua`: NvChad-specific configuration.
  - `lua/configs/`: Plugin configurations.
  - `lua/plugins/`: Plugin specifications for `lazy.nvim`.

## Core Instructions

1. **Preserve Structure**: Maintain the existing modular organization. Do not introduce new files or directories unless necessary for a new feature.
2. **Follow Patterns**: Adhere to the existing code style, naming conventions, and architectural patterns.
3. **NvChad Conventions**: Respect NvChad's conventions and overrides. Do not modify core NvChad functionality without a compelling reason.
4. **Modern APIs**: Use modern Neovim Lua APIs, such as `vim.keymap.set` for keymappings.
5. **Lazy.nvim Specs**: When adding or modifying plugins, use the `lazy.nvim` specification format found in the `lua/plugins/` directory.
6. **Code Style**:
    - **Indentation**: 2 spaces.
    - **Quotes**: Use double quotes (`"`) for strings.
    - **Tables**: Use trailing commas on multi-line table definitions.
    - **Naming**: Use `snake_case` for variables and function names.

## Common Tasks

- **Adding a Plugin**: Create a new file in `lua/plugins/` that returns the plugin's `lazy.nvim` specification.
- **Adding Keymaps**: Modify `lua/mappings.lua`.
- **Adding Autocommands**: Modify `lua/autocmds.lua`.

By following these guidelines, you will ensure that changes are consistent, maintainable, and aligned with the project's standards.
