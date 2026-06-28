-- Native LSP setup (0.12) -- no NvChad, no nvim-lspconfig wrapper.
--
-- Per-server presets live in sibling files (configs/lsp/<name>.lua) and call
-- `vim.lsp.config(name, {...})` directly. This file wires shared capabilities +
-- on-attach behavior via the `'*'` config and enables every server in `servers`.

-- Shared capabilities. blink.cmp enhances these when it is loaded; the static
-- base from make_client_capabilities() already advertises completion, so LSP is
-- correct regardless of completion-plugin load order.
local capabilities = vim.lsp.protocol.make_client_capabilities()

vim.lsp.config("*", {
  capabilities = capabilities,
})

-- Buffer-local LSP keymaps on attach (native gr* maps already exist globally).
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("core_lsp_attach", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local opts = function(desc)
      return { buffer = bufnr, desc = "LSP: " .. desc }
    end
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts "hover")
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts "definition")
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts "declaration")
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts "code action")
    vim.keymap.set("n", "<leader>ra", vim.lsp.buf.rename, opts "rename")
    vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, opts "signature help")
  end,
})

-- Load all per-server presets (each file registers itself via vim.lsp.config).
local lsp_dir = vim.fn.stdpath "config" .. "/lua/configs/lsp"
for _, file in ipairs(vim.fn.globpath(lsp_dir, "*.lua", false, true)) do
  local name = vim.fn.fnamemodify(file, ":t:r")
  if name ~= "init" then
    local ok, err = pcall(require, "configs.lsp." .. name)
    if not ok then
      vim.notify("Failed to load LSP config: " .. name .. "\n" .. err, vim.log.levels.WARN)
    end
  end
end

-- Servers to enable (installed via Mason; see configs/meson.lua).
local servers = {
  "ansiblels",
  "asm_lsp",
  "bashls",
  "buf_ls",
  "clangd",
  "cssls",
  "docker_compose_language_service",
  "dockerls",
  "eslint",
  "gh_actions_ls",
  "gitlab_ci_ls",
  "glsl_analyzer",
  "gopls",
  "graphql",
  "helm_ls",
  "html",
  "hyprls",
  "jsonls",
  "julials",
  "lemminx",
  "ltex",
  "lua_ls",
  "marksman",
  "neocmake",
  "postgres_lsp",
  "pyright",
  "ruff",
  "rust_analyzer",
  "solidity_ls",
  "sqls",
  "taplo",
  "terraformls",
  "ts_ls",
  "vimls",
  "yamlls",
  "zls",
}

vim.lsp.enable(servers)
