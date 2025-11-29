local vim = vim 

local M = {}

local state = require('moonspector.state')
local ui    = require('moonspector.ui')

function M.create()
    state.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(state.buf, 'filetype', 'lua')
    vim.api.nvim_buf_set_option(state.buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_name(state.buf, '[Moonspector]')
end

function M.execute()
    -- validate buffer
    if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
        return
    end

    local lines = vim.api.nvim_buf_get_lines(state.buf, 0, -1, false)
    local code = table.concat(lines, '\n')

    -- empty buffer check  
    if code:match('^%s*$') then
        return
    end

    local func, err = loadstring(code)
    if not func then
        print("Moonspector Error: " .. err)
        return
    end

    local success, result = pcall(func)
    if not success then
        print("Moonspector Runtime Error: " .. result)
    else
        if result ~= nil then
            print("Moonspector Result: " .. vim.inspect(result))
        else
            print("Moonspector: Code executed successfully")
        end
    end

end

function M.toggle()
    -- close window if open
    if ui.is_win(state.win) then
        M.hide()
        return
    end

    -- create buffer if doesn't exist
    if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
        M.create()
    end

    M.show()
end

function M.show()
    if not state.win then
        state.win = ui.create_win(state.buf, {})
    end
end

function M.hide()
    if state.win then
        ui.close_win(state.win)
        state.win = nil
    end
end

return M
