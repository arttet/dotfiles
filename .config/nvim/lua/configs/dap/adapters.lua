-- lua/configs/dap/adapters.lua
local dap = require "dap"
local json5 = require "json5"
local vscode = require "dap.ext.vscode"

local M = {}

-- Platform detection
local function get_platform()
  if vim.fn.has "win32" == 1 or vim.fn.has "win64" == 1 then
    return "windows"
  elseif vim.uv.os_uname().sysname == "Darwin" then
    return "osx"
  elseif vim.uv.os_uname().sysname == "Linux" then
    return "linux"
  end
  return nil
end

-- Platform-specific adapter resolution
local function get_adapter(adapter_config)
  local platform = get_platform()
  if not platform or not adapter_config[platform] then
    return adapter_config
  end
  return vim.tbl_extend("force", adapter_config, adapter_config[platform])
end

-- Load DAP configurations
--- Loads DAP configurations from various sources.
-- It clears existing adapters and configurations, then loads new ones from:
-- - `.vscode/launch.json` in the current working directory
-- - `.vscode/adapters.json` in the current working directory
-- - `.dap_adapters.json` in the Neovim config directory
--
-- It also handles platform-specific adapter configurations and maps file types to adapters.
M.load_configs = function()
  -- Clear existing
  for lang in pairs(dap.adapters) do
    dap.adapters[lang] = nil
  end
  for lang in pairs(dap.configurations) do
    dap.configurations[lang] = {}
  end

  -- Config paths
  local config_paths = {
    vim.fn.getcwd() .. "/.vscode/launch.json",
    vim.fn.getcwd() .. "/.vscode/adapters.json",
    vim.fn.stdpath "config" .. "/.dap_adapters.json",
  }

  -- Type mappings
  local type_to_adapter = {
    javascript = { "node2", "pwa-node", "pwa-chrome" },
    typescript = { "node2", "pwa-node", "pwa-chrome" },
    lua = { "lua" },
    cpp = { "cppdbg", "codelldb" },
    python = { "python", "python3" },
    go = { "go" },
    rust = { "lldb", "codelldb" },
  }

  -- Load from files
  for _, path in ipairs(config_paths) do
    if vim.fn.filereadable(path) == 1 then
      local file_content = table.concat(vim.fn.readfile(path), "\n")
      local success, parsed = pcall(json5.parse, file_content)

      if success and parsed then
        if parsed.adapters then
          for adapter_name, adapter_config in pairs(parsed.adapters) do
            dap.adapters[adapter_name] = get_adapter(adapter_config)
          end
        end

        if path:match "launch%.json$" then
          vscode.load_launchjs(path, type_to_adapter)
        end

        vim.notify("Loaded DAP configs from " .. path, vim.log.levels.INFO)
      else
        vim.notify(string.format("Failed to parse JSON5: %s\nError: %s", path, tostring(parsed)), vim.log.levels.ERROR)
      end
    end
  end

  if vim.tbl_isempty(dap.configurations) then
    vim.notify("No DAP configurations loaded", vim.log.levels.WARN)
  end
end

-- Initial load
M.load_configs()

-- Manual reload command
vim.api.nvim_create_user_command("DapReloadConfigs", M.load_configs, {
  desc = "Reload DAP configurations",
})

return M
