local vim = vim

local utils = require("bullet.utils")
local ui = require("bullet.ui")

local M = {
    win = nil,
    buf = nil,
    file_path = nil,
    opts = {},
}

function M.bootstrap(opts)
    M.opts = opts
end

function M.filename()
    local path = utils.git_path()
    if path then
        return utils.basename(path) .. ".md"
    else
        return utils.basename(vim.fn.getcwd()) .. ".md"
    end
end

function M.show()
    if not M.file_path then
        local name = M.filename()
        local path = M.opts.notes_dir .. name

        if not utils.is_file(path) then
            utils.err("Cannot access file: " .. path)
        end

        M.file_path = path

        if not utils.is_file_writable(M.file_path) then
            vim.fn.writefile({}, M.file_path)
            if not utils.is_file_writable(M.file_path) then
                utils.err("File is not writeable: " .. M.file_path)
            end
        end
    end

    if not M.buf or not vim.api.nvim_buf_is_valid(M.buf) then
        M.buf = ui.create_buffer()
    end

    if not M.win or not vim.api.nvim_win_is_valid(M.win) then
        M.win = ui.create_win(M.buf, M.opts.ui)
        vim.cmd('edit ' .. M.file_path)
    end
end

return M
