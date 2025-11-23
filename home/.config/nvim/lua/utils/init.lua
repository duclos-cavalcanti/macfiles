local M = {}

function M.print(v)
    print(vim.inspect(v))
    return v
end

return M
