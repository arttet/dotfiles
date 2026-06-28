-- DAP on-demand loader.
--
-- The full debugger stack (6 plugins + a Rust build for lua-json5) is heavy and
-- rarely needed at startup, so it is installed/loaded on the first debug action
-- instead of eagerly. `vim.pack.add` installs-if-missing then loads, so the very
-- first <F5>/<F9> may pause briefly to clone+build; subsequent calls are instant.

local M = { loaded = false }

-- Build lua-json5 (needs cargo on PATH) when it is installed/updated. Registered
-- eagerly at module load (core.dap is required from lua/core/init.lua) so the
-- hook exists before any `vim.pack.add` that could install lua-json5 -- including
-- headless updates / fresh bootstraps that never trigger a DAP keymap.
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("core_dap_build", { clear = true }),
  callback = function(ev)
    local d = ev.data
    if d.spec.name ~= "lua-json5" or (d.kind ~= "install" and d.kind ~= "update") then
      return
    end
    local is_win = vim.fn.has "win32" == 1
    local script = vim.fs.joinpath(d.path, is_win and "install.ps1" or "install.sh")
    if vim.fn.filereadable(script) ~= 1 then
      return
    end
    local cmd = is_win and { "powershell", "-ExecutionPolicy", "Bypass", "-File", script } or { "sh", script }
    vim.notify("Building lua-json5 (cargo)...", vim.log.levels.INFO)
    vim.system(cmd, { cwd = d.path }, function(out)
      local level = out.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
      vim.schedule(function()
        vim.notify("lua-json5 build exited with code " .. out.code, level)
      end)
    end)
  end,
})

function M.ensure()
  if M.loaded then
    return true
  end

  vim.pack.add {
    { src = "https://github.com/nvim-neotest/nvim-nio" },
    { src = "https://github.com/mfussenegger/nvim-dap" },
    { src = "https://github.com/rcarriga/nvim-dap-ui" },
    { src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
    { src = "https://github.com/nvim-telescope/telescope-dap.nvim" },
    { src = "https://github.com/Joakker/lua-json5", name = "lua-json5" },
  }

  local ok, err = pcall(require, "configs.dap")
  if not ok then
    vim.notify("Failed to initialize DAP:\n" .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  M.loaded = true
  return true
end

return M
