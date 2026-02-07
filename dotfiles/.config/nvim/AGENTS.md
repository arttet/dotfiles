# AI Agent Guidelines for Neovim Lua Configuration

This document provides expert guidance for AI agents working with this Neovim configuration written in Lua.

## Requirements

- **Minimum Neovim Version**: 0.11+
- **Language**: Lua
- **Plugin Manager**: lazy.nvim

## Important Notes

- Use only APIs available in Neovim 0.11+
- Avoid deprecated functions (e.g., vim.loop → vim.uv, lspconfig → vim.lsp)
- Test solutions on Neovim 0.11 before suggesting them

## Configuration Structure

This is a **NvChad-based Neovim configuration** using lazy.nvim as the plugin manager. The configuration follows a modular structure:

- `init.lua` - Main entry point, bootstraps lazy.nvim and loads core modules
- `lua/options.lua` - Vim options and settings
- `lua/mappings.lua` - Keybindings and mappings
- `lua/autocmds.lua` - Autocommands and event handlers
- `lua/chadrc.lua` - NvChad-specific configuration
- `lua/configs/` - Plugin and feature configurations
- `lua/plugins/` - Plugin specifications for lazy.nvim

## Lua Language Expertise

### Neovim Lua API Fundamentals

**Keymapping:**

```lua
-- Modern way (Neovim 0.7+)
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', {
  desc = 'Find files',
  silent = true,
  noremap = true
})

-- Mode can be string or table
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y', { desc = 'Yank to clipboard' })
```

**Autocommands:**

```lua
-- Create autocommand group
local augroup = vim.api.nvim_create_augroup('MyGroup', { clear = true })

-- Create autocommand
vim.api.nvim_create_autocmd('BufWritePre', {
  group = augroup,
  pattern = '*.lua',
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
```

**User Commands:**

```lua
vim.api.nvim_create_user_command('FormatFile', function(opts)
  vim.lsp.buf.format({ async = false })
end, {
  desc = 'Format current file',
  bang = true,  -- Allow ! modifier
})
```

### Lazy.nvim Plugin Management

Plugins are specified as Lua tables with the following structure:

```lua
{
  "author/plugin-name",
  lazy = true,              -- Load on-demand
  event = "VeryLazy",       -- Load on event
  cmd = "CommandName",      -- Load on command
  ft = "lua",              -- Load on filetype
  keys = {                 -- Load on keypress
    { "<leader>ff", "<cmd>SomeCommand<cr>", desc = "Description" }
  },
  dependencies = {         -- Plugin dependencies
    "other/plugin",
  },
  config = function()      -- Setup function
    require('plugin').setup({
      -- options
    })
  end,
  opts = {                 -- Shorthand for config with setup()
    -- options passed to setup()
  },
  init = function()        -- Runs before plugin loads
    vim.g.plugin_setting = true
  end,
}
```

### NvChad Conventions

**Base46 Theming:**

- Themes are loaded via `dofile(vim.g.base46_cache .. "filename")`
- Cache directory: `vim.fn.stdpath "data" .. "/base46/"`
- Custom highlights go in `lua/configs/` or via `require "nvchad.configs.theme"`

**Module Loading:**

- Use `require "module"` for lua/ directory files (no .lua extension)
- Use `require "configs.name"` for lua/configs/name.lua
- Use `require "plugins.name"` for lua/plugins/name.lua

**NvChad Plugin Imports:**

- Core plugins: `import = "nvchad.plugins"`
- Custom plugins: `import = "plugins"`

### Best Practices

**1. Module Pattern:**

```lua
local M = {}

M.setup = function()
  -- Setup code
end

M.some_function = function(args)
  -- Function code
end

return M
```

**2. Safe Requires:**

```lua
local ok, module = pcall(require, 'module-name')
if not ok then
  vim.notify('Module not found: module-name', vim.log.levels.ERROR)
  return
end
```

**3. Conditional Loading:**

```lua
vim.schedule(function()
  -- Deferred execution (runs after startup)
end)

vim.defer_fn(function()
  -- Delayed execution
end, 100)  -- milliseconds
```

**4. Path Handling:**

```lua
local path = vim.fn.stdpath "data"      -- Data directory
local config = vim.fn.stdpath "config"  -- Config directory
local cache = vim.fn.stdpath "cache"    -- Cache directory

-- Join paths safely
local full_path = vim.fn.fnamemodify(path .. "/subdir", ":p")
```

**5. Table Operations:**

```lua
-- Extend tables
local tbl = vim.tbl_extend('force', default_opts, user_opts)

-- Deep copy
local copy = vim.deepcopy(original)

-- Check if table contains value
vim.tbl_contains({'a', 'b', 'c'}, 'b')  -- true
```

**6. Buffer and Window Operations:**

```lua
-- Get current buffer/window
local buf = vim.api.nvim_get_current_buf()
local win = vim.api.nvim_get_current_win()

-- Set buffer options
vim.api.nvim_buf_set_option(buf, 'filetype', 'lua')

-- Buffer-local keymap
vim.api.nvim_buf_set_keymap(buf, 'n', '<leader>r', ':lua print("hi")<cr>', {})
```

## Common Tasks

### Adding a New Plugin

1. Create file in `lua/plugins/` (e.g., `lua/plugins/myplugin.lua`)
2. Return plugin spec:

```lua
return {
  "author/plugin-name",
  event = "VeryLazy",
  opts = {
    -- configuration
  },
}
```

### Adding Keymaps

Edit `lua/mappings.lua`:

```lua
local map = vim.keymap.set

map("n", "<leader>cc", function()
  -- Custom function
end, { desc = "Custom command" })
```

### Adding Autocommands

Edit `lua/autocmds.lua`:

```lua
local autocmd = vim.api.nvim_create_autocmd

autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
  end,
})
```

### Configuring LSP

Typically in `lua/configs/lspconfig.lua`:

```lua
local on_attach = function(client, bufnr)
  -- Keymaps and settings
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

require('lspconfig').lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }
      }
    }
  }
})
```

## Troubleshooting

**Check if plugin is loaded:**

```lua
:lua print(vim.inspect(require('lazy').plugins()))
```

**Reload module:**

```lua
:lua package.loaded['module.name'] = nil
:lua require('module.name')
```

**Debug plugin loading:**

```lua
:Lazy profile  -- See plugin load times
:Lazy health   -- Check plugin health
```

**Check Neovim Lua path:**

```lua
:lua print(vim.inspect(vim.api.nvim_list_runtime_paths()))
```

## Code Style

- **Indentation:** 2 spaces
- **Quotes:** Prefer double quotes for strings
- **Tables:** Trailing commas on multi-line tables
- **Functions:** Use `function()` not `function ()`
- **Naming:** snake_case for functions and variables
- **Comments:** Use `--` for single line, `--[[ ]]` for blocks

## Important Notes

1. **Load Order:** init.lua → lazy.nvim → plugins → options → autocmds → mappings
2. **Session Options:** Configured with `vim.o.sessionoptions` for session persistence
3. **Leader Key:** Set to space (`" "`) via `vim.g.mapleader`
4. **UV vs Loop:** Modern Neovim uses `vim.uv` (previously `vim.loop`) for libuv bindings
5. **Scheduled Functions:** Use `vim.schedule()` for mappings to ensure proper loading order
6. **Windows Paths:** Use forward slashes in Lua strings; Neovim handles conversion

## Resources

- Neovim Lua Guide: `:h lua-guide`
- Neovim API: `:h api`
- Lazy.nvim: `:h lazy.nvim`
- NvChad Docs: <https://nvchad.com/docs/quickstart/install>
- Lua 5.1 Reference: <https://www.lua.org/manual/5.1/>

## Agent Instructions

When modifying this configuration:

1. **Preserve Structure:** Keep the modular organization intact
2. **Follow Patterns:** Match existing code style and conventions
3. **Test Changes:** Verify syntax with `:luafile %` or restart Neovim
4. **Minimal Changes:** Edit only what's necessary
5. **Document:** Add descriptive comments for complex logic
6. **Check Dependencies:** Ensure required plugins are specified
7. **Respect NvChad:** Don't override NvChad core without good reason
8. **Use Modern APIs:** Prefer `vim.keymap.set` over `vim.api.nvim_set_keymap`
