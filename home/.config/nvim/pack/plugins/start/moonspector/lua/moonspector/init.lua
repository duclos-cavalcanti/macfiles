-- Moonspector: Minimal Lua debugging plugin for Neovim
local M = {}

local core = require('moonspector.moonspector')

function M.setup()
    vim.api.nvim_create_user_command('MoonLaunch', M.toggle, { desc = 'Toggle Moonspector debug buffer' })
    vim.api.nvim_create_user_command('MoonExecute', M.execute, { desc = 'Execute Moonspector buffer' })
end

function M.toggle()
    core.toggle()
end

function M.execute()
    core.execute()
end

return M
