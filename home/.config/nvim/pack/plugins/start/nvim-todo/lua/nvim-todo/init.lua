local config = require("nvim-todo.config")
local ui = require("nvim-todo.ui")

local M = {}

function M.setup(opts)
    config.setup(opts or {})
    
    print("nvim-todo loaded successfully!")
end

return M
