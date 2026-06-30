-- UI: noice (cmdline/messages/popups) + notify. Kept for the look; loaded after
-- first draw and guarded so a noice failure never blocks startup.

vim.pack.add {
  { src = "https://github.com/MunifTanjim/nui.nvim" },
  { src = "https://github.com/rcarriga/nvim-notify" },
  { src = "https://github.com/folke/noice.nvim" },
}

vim.schedule(function()
  local ok, noice = pcall(require, "noice")
  if not ok then
    vim.notify("noice failed to load; continuing without it", vim.log.levels.WARN)
    return
  end

  noice.setup {
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
    },
  }
end)
