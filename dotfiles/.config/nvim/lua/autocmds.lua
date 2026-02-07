-- Autocommand definitions
-- This file contains custom autocommands for:
-- - Spell checking for specific file types
-- - Language-specific indentation settings
-- - Automatically opening NvDash

require "nvchad.autocmds"

-- Spell Check
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})

-- Language-specific indentation overrides
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "c", "cpp", "java", "rust", "go" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
  desc = "Use 4-space indentation for specific languages",
})

-- Open NvDash when delete all buffer action and last empty buffer
vim.api.nvim_create_autocmd({ "BufEnter", "BufDelete", "FileType" }, {
  callback = function(args)
    if args.event == "FileType" then
      vim.o.showtabline = vim.bo.ft == "nvdash" and 0 or 2
      return
    end

    local buf = args.buf

    if not vim.bo[buf].buflisted then
      return
    end

    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
        if #vim.t.bufs == 1 and vim.api.nvim_buf_get_name(buf) == "" then
          vim.cmd "Nvdash"
        end
      end
    end)
  end,
})
