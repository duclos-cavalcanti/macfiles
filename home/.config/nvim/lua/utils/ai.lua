local M = {}

local sidekick = require('sidekick')
local cli = require('sidekick.cli')

local function jump_to_agent()
    vim.fn.system('~/.tmux/agentic/jump-to-agent.sh')
end

function M.select()
    cli.select()
end

function M.show()
    cli.show()
end

function M.jump_or_apply()
    if not sidekick.nes_jump_or_apply() then
        return '<Tab>'
    end
end

function M.send_this()
    cli.send({ msg = '{this}' })
    jump_to_agent()
end

function M.send_file()
    cli.send({ msg = '{file}' })
    jump_to_agent()
end

function M.prompt()
    cli.prompt()
end

function M.accept()
    cli.accept()
end

function M.select_in_dir()
    local origin = vim.fn.getcwd()
    require('utils').pick_dir(function(dir)
        vim.cmd('cd ' .. vim.fn.fnameescape(dir))
        cli.select()
        vim.schedule(function()
            vim.cmd('cd ' .. vim.fn.fnameescape(origin))
        end)
    end)
end

return M
