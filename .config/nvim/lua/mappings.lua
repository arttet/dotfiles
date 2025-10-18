-- Keybindings and shortcuts configuration
-- Extends NvChad default mappings with custom keybindings for:
-- - Terminal management
-- - Git integration (lazygit, gitui)
-- - AI integration (copilot, gemini)
-- - Custom editor shortcuts
-- - DAP debugging controls
--
-- Default NvChad mappings:
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvchad/mappings.lua

require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", {
  desc = "cmd enter command mode",
})

map("n", "<C-q>", ":q<CR>", {
  silent = true,
  desc = "close window/tab",
})

map("n", "<leader>ph", function()
  require("noice").cmd "pick"
end, { desc = "telescope pick the message history" })

-- ====================
-- Terminal
-- ====================

map("t", "<Esc>", "<C-\\><C-n>", {
  noremap = true,
  desc = "exit terminal mode",
})

map("n", "<A-t>", function()
  vim.cmd "terminal"
end, { desc = "terminal new buffer term" })

map("t", "<C-q>", "<C-\\><C-n>:q<CR>", {
  silent = true,
  desc = "close terminal",
})

-- Terminal
map("n", "<leader>tt", ":tabnew | term <CR>i", { desc = "open terminal" })

-- LazyGit (https://github.com/jesseduffield/lazygit)
map("n", "<leader>tl", ":tabnew | term lazygit<CR>i", { desc = "open lazy git" })

-- GitUI (https://github.com/gitui-org/gitui)
map("n", "<leader>tu", ":tabnew | term gitui<CR>i", { desc = "open gitui" })

-- LazyDocker (https://github.com/jesseduffield/lazydocker)
map("n", "<leader>td", ":tabnew | term lazydocker<CR>i", { desc = "󰏗 open lazydocker" })

-- GitHub Copilot CLI (https://github.com/github/copilot-cli)
map("n", "<leader>tc", ":tabnew | term copilot<CR>i", { desc = "✦ open copilot" })

-- Gemini CLI (https://github.com/google-gemini/gemini-cli)
map("n", "<leader>tg", ":tabnew | term gemini<CR>i", { desc = "✦ open gemini" })

-- ====================
-- Editor
-- ====================

map("i", "jk", "<ESC>", { desc = "Escape insert mode" })

map("n", "<leader>gf", function()
  require("gitsigns").blame_line { full = true }
end, { noremap = true, desc = "show full git commit message" })

-- ====================
-- DAP UI Keybindings
-- ====================

-- DAP lazy load helper
local function ensure_dap_loaded()
  if not package.loaded["dap"] then
    local ok = pcall(require("lazy").load, { plugins = { "nvim-dap" } })
    if not ok then
      vim.notify("Failed to load nvim-dap", vim.log.levels.ERROR)
      return false
    end
  end
  return true
end

-- DAP UI Keybindings
map("n", "<F5>", function()
  if ensure_dap_loaded() then
    require("dap").continue()
  end
end, { desc = "start/continue debugging" })

map("n", "<F6>", function()
  if ensure_dap_loaded() then
    require("dap").run_last()
  end
end, { desc = "run last debug configuration" })

map("n", "<F7>", function()
  if ensure_dap_loaded() then
    require("dapui").toggle()
  end
end, { desc = "toggle DAP UI" })

map("n", "<F8>", function()
  if ensure_dap_loaded() then
    require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ")
  end
end, { desc = "set conditional breakpoint" })

map("n", "<F9>", function()
  if ensure_dap_loaded() then
    require("dap").toggle_breakpoint()
  end
end, { desc = "toggle Breakpoint" })

map("n", "<F10>", function()
  if ensure_dap_loaded() then
    require("dap").step_over()
  end
end, { desc = "step over" })

map("n", "<F11>", function()
  if ensure_dap_loaded() then
    require("dap").step_into()
  end
end, { desc = "step into" })

map("n", "<F12>", function()
  if ensure_dap_loaded() then
    require("dap").step_out()
  end
end, { desc = "step out" })

map("n", "<leader>dc", function()
  if ensure_dap_loaded() then
    require("telescope").extensions.dap.configurations()
  end
end, { desc = "select debug configuration" })
