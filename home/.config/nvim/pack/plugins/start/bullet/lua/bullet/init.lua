local vim = vim

local config = require("bullet.config")
local core = require("bullet.bullet")

local M = {}

function M.setup(opts)
    config.setup(opts or {})

    core.bootstrap(config.get())

    vim.api.nvim_create_user_command('BulletLaunch', core.show, { desc = 'Launch bullet projet buffer' })
    vim.api.nvim_create_user_command('BulletSticky', core.sticky, { desc = 'Launch bullet sticky buffer' })
    vim.api.nvim_create_user_command('BulletList', core.list, { desc = 'Select bullet notes' })
end

return M
