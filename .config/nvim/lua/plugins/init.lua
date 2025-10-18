return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    cmd = { "MasonToolsInstall", "MasonToolsUpdate" },
    opts = require "configs.meson",
  },

  -- Development tools
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = require "configs.treesitter",
    desc = "Syntax highlighting and code parsing",
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
    desc = "Code formatting, analysis, and syntax checking",
  },

  -- Language Server Protocol
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "configs.lsp"
    end,
  },

  -- Debugger Components
  -- Debug Adapter Protocol (DAP) Configuration
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-telescope/telescope.nvim",
      "nvim-telescope/telescope-dap.nvim",
      "nvim-neotest/nvim-nio",
      {
        "Joakker/lua-json5",
        -- NOTE: You must have cargo installed and in your $PATH
        build = vim.fn.has "win32" == 1 and "powershell -ExecutionPolicy Bypass -File ./install.ps1" -- Windows
          or "./install.sh",
      },
    },
    cmd = { "DapContinue", "DapToggleBreakpoint" },
    config = function()
      require "configs.dap"
    end,
  },

  -- UI Plugins
  -- Plugins related to user interface enhancements
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    event = { "VeryLazy", "CmdlineEnter" },
    opts = {},
  },

  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPost",
    config = function()
      require "configs.gitsigns"
    end,
  },

  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
    init = function()
      require "configs.visual-multi"
    end,
  },

  {
    "folke/todo-comments.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy",
    opts = {},
  },

  {
    "wakatime/vim-wakatime",
    event = "VeryLazy",
    config = function()
      require "configs.wakatime"
    end,
  },
}
