local vim = vim 

local M = {
    win = nil,
    buf = nil,
}

function M.create_buffer()
    M.buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_option(M.buf, 'filetype', 'lua')
    vim.api.nvim_buf_set_option(M.buf, 'buftype', 'acwrite')
    vim.api.nvim_buf_set_name(M.buf, '[Moonspector]')

    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = M.buf,
        callback = function()
            vim.cmd('source')
        end,
        desc = "Moonspector: Source buffer on write attempt"
    })
end

function M.create_win(opts)
    local width = opts.width or math.floor(vim.o.columns * 0.8)
    local height = opts.height or math.floor(vim.o.lines * 0.8)
    local row = opts.row or math.floor((vim.o.lines - height) / 2)
    local col = opts.col or math.floor((vim.o.columns - width) / 2)

    M.win = vim.api.nvim_open_win(M.buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
        title = 'Moonspector',
        title_pos = 'center',
    })

    vim.api.nvim_win_set_option(M.win, 'number', true)
    vim.api.nvim_win_set_option(M.win, 'relativenumber', false)
end

function M.show()
    -- Create buffer if doesn't exist
    if not M.buf or not vim.api.nvim_buf_is_valid(M.buf) then
        M.create_buffer()
    end

    M.create_win({})
end

return M
