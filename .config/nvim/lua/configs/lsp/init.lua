require("nvchad.configs.lspconfig").defaults()

-- Define default capabilities and on_attach
local default_capabilities = vim.lsp.protocol.make_client_capabilities()
local default_on_attach = function(client, bufnr)
  vim.notify("LSP attached: " .. client.name, vim.log.levels.INFO)
end

-- Store defaults for use by individual server configs
vim.g.lsp_defaults = {
  capabilities = default_capabilities,
  on_attach = default_on_attach,
}

-- Load all LSP configs
local lsp_dir = vim.fn.stdpath "config" .. "/lua/configs/lsp"

for _, file in ipairs(vim.fn.globpath(lsp_dir, "*.lua", false, true)) do
  local filename = vim.fn.fnamemodify(file, ":t")
  if filename ~= "init.lua" then
    local name = vim.fn.fnamemodify(file, ":t:r")
    local ok, err = pcall(require, "configs.lsp." .. name)

    if not ok then
      vim.notify("Failed to load LSP config: " .. name .. "\n" .. err, vim.log.levels.WARN)
    end
  end
end

-- List of LSP servers
-- All LSP servers should be installed via Mason
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
