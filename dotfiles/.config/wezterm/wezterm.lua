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
  { family = "IosevkaTerm Nerd Font", weight = "Medium" },
  { family = "CaskaydiaCove Nerd Font", weight = "Medium" },
  { family = "JetBrainsMono Nerd Font", weight = "Medium" },
  "Noto Color Emoji",
})

config.font_size = 13.0

-- --------------------------------------------------
-- Window appearance (unified with Alacritty/Ghostty)
-- --------------------------------------------------
config.window_padding = {
  left = 5,
  right = 5,
  top = 5,
  bottom = 5,
}

-- Minimal window decorations and no tab bar
config.window_decorations = "RESIZE"
config.enable_tab_bar = true
config.use_fancy_tab_bar = true

-- Background opacity and blur (unified)
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20

-- --------------------------------------------------
-- Key bindings (unified across terminals)
-- --------------------------------------------------
-- Rules:
--   - Ctrl+Shift = terminal actions (no shell conflicts)
--   - Ctrl alone = shell/TUI (SIGINT, vim, etc.)
-- --------------------------------------------------
config.keys = {
  -- New tab
  {
    key = "T",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SpawnTab("CurrentPaneDomain"),
  },

  -- Close tab
  {
    key = "W",
    mods = "CTRL|SHIFT",
    action = wezterm.action.CloseCurrentTab({ confirm = false }),
  },

  -- New window
  {
    key = "N",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SpawnWindow,
  },

  -- Close window
  {
    key = "Q",
    mods = "CTRL|SHIFT",
    action = wezterm.action.QuitApplication,
  },

  -- Toggle fullscreen
  {
    key = "F11",
    action = wezterm.action.ToggleFullScreen,
  },
  {
    key = "Enter",
    mods = "CTRL",
    action = wezterm.action.ToggleFullScreen,
  },

  -- Copy (Ctrl+Shift to avoid SIGINT conflict)
  {
    key = "C",
    mods = "CTRL|SHIFT",
    action = wezterm.action.CopyTo("Clipboard"),
  },

  -- Paste (Ctrl+Shift to avoid vim conflict)
  {
    key = "V",
    mods = "CTRL|SHIFT",
    action = wezterm.action.PasteFrom("Clipboard"),
  },

  -- Font size zoom
  {
    key = "Equal",
    mods = "CTRL|SHIFT",
    action = wezterm.action.IncreaseFontSize,
  },
  {
    key = "Minus",
    mods = "CTRL|SHIFT",
    action = wezterm.action.DecreaseFontSize,
  },
  {
    key = "0",
    mods = "CTRL|SHIFT",
    action = wezterm.action.ResetFontSize,
  },
}

-- --------------------------------------------------
-- Performance and UX tweaks
-- --------------------------------------------------
config.scrollback_lines = 10000
config.adjust_window_size_when_changing_font_size = false
config.warn_about_missing_glyphs = false

return config
