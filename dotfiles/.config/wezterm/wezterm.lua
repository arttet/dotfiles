local wezterm = require("wezterm")

-- Create config using the new builder when available
local config = wezterm.config_builder and wezterm.config_builder() or {}

-- --------------------------------------------------
-- Color scheme selection based on system appearance
-- --------------------------------------------------
local function scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "Catppuccin Mocha"
  end
  return "Catppuccin Frappe"
end

-- Set initial color scheme
config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())

-- Automatically update color scheme when system appearance changes
wezterm.on("window-config-reloaded", function(window)
  window:set_config_overrides({
    color_scheme = scheme_for_appearance(window:get_appearance()),
  })
end)

-- --------------------------------------------------
-- Default shell configuration
-- --------------------------------------------------

-- Nushell
-- https://www.nushell.sh
config.default_prog = { "nu", "--login", "--interactive" }

-- if wezterm.target_triple:find("windows") then
--   config.default_prog = { "pwsh.exe", "-NoLogo" }
-- else
--   config.default_prog = { "zsh", "-l" }
-- end


-- Start new sessions in the user's home directory
config.default_cwd = wezterm.home_dir

-- --------------------------------------------------
-- Font configuration with Nerd Font fallback
-- --------------------------------------------------
config.font = wezterm.font_with_fallback({
  "JetBrainsMono Nerd Font",
  -- "JetBrains Mono",
  -- "Symbols Nerd Font Mono",
})

config.font_size = 13.0

-- --------------------------------------------------
-- Window appearance
-- --------------------------------------------------
config.window_padding = {
  left = 6,
  right = 6,
  top = 4,
  bottom = 4,
}

-- Minimal window decorations and no tab bar
config.window_decorations = "RESIZE"
config.enable_tab_bar = true
config.use_fancy_tab_bar = true

-- --------------------------------------------------
-- Key bindings
--
-- Default Key Assignments
-- wezterm show-keys --lua
--
-- https://wezterm.org/config/default-keys.html
-- --------------------------------------------------
config.keys = {
  -- New tab
  {
    key = "T",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SpawnTab("CurrentPaneDomain"),
  },

  -- Close tab fast
  {
    key = "W",
    mods = "CTRL|SHIFT",
    action = wezterm.action.CloseCurrentTab({ confirm = false }),
  },

  -- Toggle fullscreen
  {
    key = "F11",
    action = wezterm.action.ToggleFullScreen,
  },
}

-- --------------------------------------------------
-- Performance and UX tweaks
-- --------------------------------------------------
config.scrollback_lines = 10000
config.adjust_window_size_when_changing_font_size = false
config.warn_about_missing_glyphs = false

return config
