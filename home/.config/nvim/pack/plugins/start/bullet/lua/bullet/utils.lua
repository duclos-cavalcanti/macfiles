local vim = vim

local M = {}

function M.git_path()
    local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
    if not handle then
        return nil
    end

    local result = handle:read("*a")
    handle:close()

    if result and result ~= "" then
        return vim.trim(result)
    end

    return nil
end

function M.basename(path)
    return vim.fn.fnamemodify(path, ":t")
end

function M.is_file(path)
    local parent = vim.fn.fnamemodify(path, ":h")
    if not M.is_dir(parent) then
        return false
    else
        return true
    end
end

function M.is_file_writable(path)
    return (vim.fn.filewritable(path) == 1)
end

function M.is_file_readable(path)
    return (vim.fn.filereadable(path) == 1)
end

function M.is_dir(path)
    return not (vim.fn.isdirectory(path) == 0)
end

function M.err(text)
    local fmt = ("bullet: " .. text)
    error(fmt)
end

return M
