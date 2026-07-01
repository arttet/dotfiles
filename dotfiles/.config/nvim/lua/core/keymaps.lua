-- Keymaps.
--
-- Replaces `require "nvchad.mappings"`. NvChad's defaults vanish with the
-- distribution, so the commonly used ones are reimplemented here alongside the
-- repo's custom terminal / git / AI / DAP bindings (ported from lua/mappings.lua).
--
-- Native 0.12 LSP maps already provide grn/gra/grr/gri/grt/gO and <C-S>; only
-- convenience deltas are added below.

local map = vim.keymap.set

-- ============================================================================
-- General editor (former NvChad defaults)
-- ============================================================================

map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "clear search highlight" })
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr>", { desc = "save file" })
map("n", ";", ":", { desc = "enter command mode" })
map("i", "jk", "<Esc>", { desc = "escape insert mode" })
map("n", "<C-q>", "<cmd>q<cr>", { silent = true, desc = "close window" })

-- Window navigation: <C-h/j/k/l> is handled by vim-tmux-navigator
-- (plugin/30-tmux-navigator.lua), which also crosses into tmux panes.

-- Buffer navigation
map("n", "<Tab>", "<cmd>bnext<cr>", { desc = "next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "previous buffer" })
map("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "close buffer" })

-- Commenting (native gc/gcc in 0.10+)
map("n", "<leader>/", "gcc", { remap = true, desc = "toggle comment" })
map("v", "<leader>/", "gc", { remap = true, desc = "toggle comment" })

-- Toggles
map("n", "<leader>n", "<cmd>set nu!<cr>", { desc = "toggle line number" })
map("n", "<leader>rn", "<cmd>set rnu!<cr>", { desc = "toggle relative number" })

-- Diagnostics convenience (native [d / ]d already exist)
map("n", "<leader>ds", vim.diagnostic.open_float, { desc = "line diagnostics" })
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "diagnostics to loclist" })

-- ============================================================================
-- File tree (nvim-tree)
-- ============================================================================

map("n", "<C-n>", "<cmd>NvimTreeToggle<cr>", { desc = "toggle nvim-tree" })
map("n", "<leader>e", "<cmd>NvimTreeFocus<cr>", { desc = "focus nvim-tree" })

-- ============================================================================
-- Fuzzy finder (telescope)
-- ============================================================================

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "find files" })
map(
  "n",
  "<leader>fa",
  "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<cr>",
  { desc = "find all files" }
)
map("n", "<leader>fw", "<cmd>Telescope live_grep<cr>", { desc = "live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "help tags" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "recent files" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "find in buffer" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", { desc = "find diagnostics" })
map("n", "<leader>gt", "<cmd>Telescope git_status<cr>", { desc = "git status" })

-- ============================================================================
-- Git (gitsigns)
-- ============================================================================

map("n", "<leader>gf", function()
  local ok, gitsigns = pcall(require, "gitsigns")
  if ok then
    gitsigns.blame_line { full = true }
  end
end, { noremap = true, desc = "show full git commit message" })

-- ============================================================================
-- Theme toggle (gruvbox dark <-> light)
-- ============================================================================

map("n", "<leader>th", function()
  vim.o.background = vim.o.background == "dark" and "light" or "dark"
end, { desc = "toggle light/dark theme" })

-- ============================================================================
-- Noice
-- ============================================================================

map("n", "<leader>ph", function()
  local ok, noice = pcall(require, "noice")
  if ok then
    noice.cmd "pick"
  end
end, { desc = "pick message history" })

-- ============================================================================
-- Terminal (tab-based, ported verbatim)
-- ============================================================================

map("n", "<A-t>", function()
  vim.cmd "terminal"
end, { desc = "terminal new buffer" })
map("t", "<C-q>", "<C-\\><C-n><cmd>q<cr>", { silent = true, desc = "close terminal" })
map("n", "<leader>tt", ":tabnew | term <CR>i", { desc = "open terminal" })
map("n", "<leader>tl", ":tabnew | term lazygit<CR>i", { desc = "open lazygit" })
map("n", "<leader>tu", ":tabnew | term gitui<CR>i", { desc = "open gitui" })
map("n", "<leader>td", ":tabnew | term lazydocker<CR>i", { desc = "󰏗 open lazydocker" })
map("n", "<leader>tc", ":tabnew | term copilot<CR>i", { desc = "✦ open copilot" })
map("n", "<leader>tg", ":tabnew | term gemini<CR>i", { desc = "✦ open gemini" })

-- ============================================================================
-- DAP (F5-F12, lazy-loaded on first use)
-- ============================================================================

local function with_dap(fn)
  return function()
    if require("core.dap").ensure() then
      fn()
    end
  end
end

local dap_maps = {
  {
    "<F5>",
    function()
      require("dap").continue()
    end,
    "start/continue debugging",
  },
  {
    "<F6>",
    function()
      require("dap").run_last()
    end,
    "run last debug configuration",
  },
  {
    "<F7>",
    function()
      require("dapui").toggle()
    end,
    "toggle DAP UI",
  },
  {
    "<F8>",
    function()
      require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ")
    end,
    "set conditional breakpoint",
  },
  {
    "<F9>",
    function()
      require("dap").toggle_breakpoint()
    end,
    "toggle breakpoint",
  },
  {
    "<F10>",
    function()
      require("dap").step_over()
    end,
    "step over",
  },
  {
    "<F11>",
    function()
      require("dap").step_into()
    end,
    "step into",
  },
  {
    "<F12>",
    function()
      require("dap").step_out()
    end,
    "step out",
  },
  {
    "<leader>dc",
    function()
      require("telescope").extensions.dap.configurations()
    end,
    "select debug configuration",
  },
}

for _, m in ipairs(dap_maps) do
  map("n", m[1], with_dap(m[2]), { desc = m[3] })
end
