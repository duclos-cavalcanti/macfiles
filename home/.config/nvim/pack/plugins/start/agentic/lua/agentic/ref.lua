local vim = vim

local M = {}

local function git_root(dir)
    local out = vim.fn.system({ "git", "-C", dir, "rev-parse", "--show-toplevel" })
    if vim.v.shell_error ~= 0 then return nil end
    out = vim.trim(out)
    return out ~= "" and out or nil
end

local function relpath()
    local fname = vim.api.nvim_buf_get_name(0)
    if fname == "" then return nil end

    local dir = vim.fn.fnamemodify(fname, ":h")
    local root = git_root(dir) or vim.fn.getcwd()

    local ok, rel = pcall(vim.fs.relpath, root, fname)
    if ok and rel and rel ~= "" then return rel end
    return fname
end

function M.file()
    local rel = relpath()
    if not rel then
        vim.notify("agentic: buffer has no file", vim.log.levels.WARN)
        return nil
    end
    return "@" .. rel
end

function M.selection()
    local rel = relpath()
    if not rel then
        vim.notify("agentic: buffer has no file", vim.log.levels.WARN)
        return nil
    end

    local from = vim.api.nvim_buf_get_mark(0, "<")[1]
    local to = vim.api.nvim_buf_get_mark(0, ">")[1]
    if from == 0 or to == 0 then
        vim.notify("agentic: no visual selection", vim.log.levels.WARN)
        return nil
    end
    if from > to then from, to = to, from end

    if from == to then
        return string.format("@%s#L%d", rel, from)
    end
    return string.format("@%s#L%d-%d", rel, from, to)
end

return M
