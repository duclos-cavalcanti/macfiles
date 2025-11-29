local vim = vim

local M = {}

function M.create_win(buf, opts)
    local width = opts.width or math.floor(vim.o.columns * 0.8)
    local height = opts.height or math.floor(vim.o.lines * 0.8)
    local row = opts.row or math.floor((vim.o.lines - height) / 2)
    local col = opts.col or math.floor((vim.o.columns - width) / 2)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
    })

    return win
end

function M.is_win(win)
    return (win and vim.api.nvim_win_is_valid(win))
end

function M.close_win(win)
    vim.api.nvim_win_close(win, true)
end

return M
