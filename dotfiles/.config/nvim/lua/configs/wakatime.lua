-- Configures the vim-wakatime plugin.
-- Initializes and periodically updates the WakaTime status in the statusline.

vim.g.wakatime_status = " WakaTime is initializing..."

local function trim(str)
  return (str:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function wakatime_status()
  if vim.g.loaded_wakatime ~= 1 then
    return " WakaTime Error"
  end

  vim.fn.WakaTimeToday(function(output)
    vim.g.wakatime_status = string.format("  %s", trim(output))
  end)

  return vim.g.wakatime_status
end

vim.schedule(function()
  vim.g.wakatime_status = " WakaTime is loading..."
  wakatime_status()
end)

vim.fn.timer_start(300000, wakatime_status, { ["repeat"] = -1 })
