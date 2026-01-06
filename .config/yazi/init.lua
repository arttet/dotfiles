require("full-border"):setup {
    -- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
    type = ui.Border.ROUNDED,
}

require("git"):setup()

require("starship"):setup()

require("yaziline"):setup({
  -- Powerline separators for maximum visual impact
  separator_style = "curvy", -- "angly" | "curvy" | "liney" | "empty"
  separator_open = "",        -- left solid
  separator_close = "",       -- right solid

  -- Inner (thin) layer
  separator_open_thin = "",   -- left thin
  separator_close_thin = "",  -- right thin

  -- Rounded caps
  separator_head = "",
  separator_tail = "",

  -- Icons with Nerd Font symbols
  select_symbol = "󰻃",            -- selection icon (more visible)
  yank_symbol = "󰆐",              -- yank/copy icon

  -- Filename display settings for better context
  filename_max_length = 40,        -- increased from 24 for more info
  filename_truncate_length = 12,   -- increased from 6 for better context
  filename_truncate_separator = "…" -- single ellipsis character
})
