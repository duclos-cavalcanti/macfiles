local vim = vim

local M = {}

function M.create_buffer()
    local buf = vim.api.nvim_create_buf(false, false)

    vim.api.nvim_set_option_value('filetype', 'markdown', { buf = buf })
    vim.api.nvim_set_option_value('buftype', '', { buf = buf })

    return buf
end

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
        title = opts.title or 'Bullet Notes',
        title_pos = 'center',
    })

    vim.api.nvim_win_set_option(win, 'number', true)
    vim.api.nvim_win_set_option(win, 'relativenumber', false)

    return win
end

return M
