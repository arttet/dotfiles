-- Completion: blink.cmp (replaces the nvim-cmp + cmp-* + LuaSnip stack).
-- Deferred with `vim.schedule` (after the first draw) rather than gated on the
-- first `InsertEnter`: loading on InsertEnter registers blink's own insert-mode
-- autocmds after that event has already fired, so the first insert session would
-- miss completion. `version` tracks the 1.x release tag so the prebuilt
-- fuzzy-match binary is fetched instead of compiled.

vim.schedule(function()
  vim.pack.add {
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range "1" },
  }
  require("blink.cmp").setup {
    keymap = { preset = "default" },
    appearance = { nerd_font_variant = "mono" },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      menu = { border = "rounded" },
    },
    signature = { enabled = true, window = { border = "rounded" } },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  }
end)
