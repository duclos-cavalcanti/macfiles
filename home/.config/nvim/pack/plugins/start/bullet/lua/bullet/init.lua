local vim = vim

local config = require("bullet.config")
local core = require("bullet.bullet")

local M = {}

function M.setup(opts)
    config.setup(opts or {})

    core.bootstrap(config.get())

    vim.api.nvim_create_user_command('BulletLaunch', M.show, { desc = 'Launch bullet buffer' })
end

function M.show()
    core.show()
end

return M
