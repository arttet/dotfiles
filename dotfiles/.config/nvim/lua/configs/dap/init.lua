local dap = require "dap"
local json5 = require "json5"
local telescope = require "telescope"
local vscode = require "dap.ext.vscode"

-- Override JSON decoder
vscode.json_decode = json5.parse

-- Load Telescope extension
telescope.load_extension "dap"

-- Load sub-modules
require "configs.dap.adapters"
require "configs.dap.ui"
require "configs.dap.watcher"

-- Export for use in other modules
return {
  reload_configs = function()
    require("configs.dap.adapters").load_configs()
  end,
}
