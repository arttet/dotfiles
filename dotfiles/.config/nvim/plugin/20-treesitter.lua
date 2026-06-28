-- Treesitter (nvim-treesitter `main` rewrite). Eager: highlighting is wanted at
-- first draw. Parsers are compiled locally (needs `cc` + `tree-sitter` CLI on
-- PATH -- see `just nvim-doctor`).
--
-- The `master` branch is frozen/archived; `main` has no `configs.setup()`:
-- parsers are installed via `require('nvim-treesitter').install()` and features
-- are enabled with native `vim.treesitter.*`.

local parsers = require("configs.treesitter").ensure_installed

-- Resolve the install API across the slightly different module names the main
-- branch has shipped, so this keeps working across updates.
local function ts_mod()
  local ok, ts = pcall(require, "nvim-treesitter")
  if ok and type(ts) == "table" and ts.install then
    return ts
  end
  return nil
end

local function installed_set()
  for _, name in ipairs { "nvim-treesitter.config", "nvim-treesitter.configs" } do
    local ok, cfg = pcall(require, name)
    if ok and cfg.get_installed then
      local set = {}
      for _, p in ipairs(cfg.get_installed()) do
        set[p] = true
      end
      return set
    end
  end
  return nil
end

local _ts_install_future = nil

local function ensure_parsers()
  -- CI/validation can skip the (network + compile) parser install.
  if vim.env.NVIM_TS_NO_INSTALL then
    return
  end
  local ts = ts_mod()
  if not ts then
    return
  end

  local function install_async(targets)
    -- Defer so the first redraw is not blocked by network/compile work, and do
    -- NOT `:wait()` here -- that would block the UI thread for the whole compile.
    -- Keep a reference to the future so it is not garbage-collected before the
    -- async install finishes (the headless `just nvim ts-install` does its own
    -- `:wait()`).
    vim.defer_fn(function()
      _ts_install_future = ts.install(targets)
    end, 100)
  end

  local have = installed_set()
  if not have then
    install_async(parsers)
    return
  end
  local missing = {}
  for _, p in ipairs(parsers) do
    if not have[p] then
      missing[#missing + 1] = p
    end
  end
  if #missing > 0 then
    install_async(missing)
  end
end

-- Install/update hook -- registered BEFORE add() so it fires on fresh bootstrap.
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("core_treesitter_pack", { clear = true }),
  callback = function(ev)
    local d = ev.data
    if d.spec.name ~= "nvim-treesitter" or (d.kind ~= "install" and d.kind ~= "update") then
      return
    end
    if not d.active then
      pcall(vim.cmd.packadd, "nvim-treesitter")
    end
    pcall(vim.cmd, "TSUpdate")
    ensure_parsers()
  end,
})

vim.pack.add {
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
}

ensure_parsers()

-- Enable highlight + folding per filetype when a parser is available.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("core_treesitter_ft", { clear = true }),
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local lang = vim.treesitter.language.get_lang(ft) or ft
    -- `vim.treesitter.start` loads the parser itself; this pcall is the only
    -- guard needed (it returns early when no parser is available for `lang`).
    if not pcall(vim.treesitter.start, args.buf, lang) then
      return
    end
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end,
})
