-- Core (plugin-independent) configuration loader.
-- Pure Neovim 0.12 APIs only -- safe to load before any plugin is installed.

require "core.options"
require "core.diagnostics"
require "core.autocmds"
require "core.keymaps"
require "core.dap" -- defines the on-demand loader + registers the lua-json5 build hook
require "configs.lsp"
