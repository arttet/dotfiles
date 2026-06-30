-- Autocommands.
-- Replaces `require "nvchad.autocmds"`; the NvDash auto-open autocmd is dropped
-- (mini.starter handles the dashboard now).

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text briefly.
autocmd("TextYankPost", {
  group = augroup("core_yank_highlight", { clear = true }),
  callback = function()
    vim.hl.on_yank { higroup = "Visual", timeout = 150 }
  end,
})

-- Spell check for prose-like filetypes.
autocmd("FileType", {
  group = augroup("core_spell", { clear = true }),
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})

-- Language-specific 4-space indentation overrides.
autocmd("FileType", {
  group = augroup("core_indent", { clear = true }),
  pattern = { "python", "c", "cpp", "java", "rust", "go" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
  desc = "Use 4-space indentation for specific languages",
})

-- Close some utility buffers with `q`.
autocmd("FileType", {
  group = augroup("core_quick_close", { clear = true }),
  pattern = { "help", "qf", "man", "lspinfo", "checkhealth", "startuptime" },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true })
  end,
})
