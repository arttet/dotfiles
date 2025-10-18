-- lua/configs/dap/watcher.lua
local M = {}

local watcher_handle = nil
local reload_timer = nil
local DEBOUNCE_MS = 100

--- Sets up a file watcher for `.vscode/launch.json` and `.vscode/adapters.json`.
-- When changes are detected in these files, it reloads the DAP configurations.
-- It uses a debounce mechanism to avoid reloading too frequently.
M.setup_file_watcher = function()
  local watch_dir = vim.fn.getcwd() .. "/.vscode"

  -- Stop existing watcher
  if watcher_handle then
    vim.uv.fs_event_stop(watcher_handle)
    watcher_handle = nil
  end

  if vim.fn.isdirectory(watch_dir) == 1 then
    watcher_handle = vim.uv.new_fs_event()
    vim.uv.fs_event_start(
      watcher_handle,
      watch_dir,
      { recursive = false },
      vim.schedule_wrap(function(err, filename, events)
        if err then
          vim.notify("Error watching " .. watch_dir .. ": " .. err, vim.log.levels.ERROR)
          return
        end

        if (filename:match "launch%.json$" or filename:match "adapters%.json$") and events.change then
          -- Debounce reload
          if reload_timer then
            vim.uv.timer_stop(reload_timer)
          end

          reload_timer = vim.uv.new_timer()
          vim.uv.timer_start(
            reload_timer,
            DEBOUNCE_MS,
            0,
            vim.schedule_wrap(function()
              vim.notify("Detected change in " .. filename .. ", reloading DAP configs", vim.log.levels.INFO)
              require("configs.dap.adapters").load_configs()
            end)
          )
        end
      end)
    )
  end
end

-- Cleanup on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    if watcher_handle then
      vim.uv.fs_event_stop(watcher_handle)
      watcher_handle = nil
    end
    if reload_timer then
      vim.uv.timer_stop(reload_timer)
      reload_timer = nil
    end
  end,
})

-- Start watcher
M.setup_file_watcher()

return M
