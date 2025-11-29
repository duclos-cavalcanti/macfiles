local M = {}

local core = require('moonspector.moonspector')

function M.setup()
    vim.api.nvim_create_user_command('MoonLaunch', M.show, { desc = 'Launch Moonspector buffer' })
end

function M.show()
    core.show()
end

return M
