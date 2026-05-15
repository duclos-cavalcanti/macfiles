local vim = vim

local M = {}

local function in_tmux()
    return (vim.env.TMUX or "") ~= ""
end

local function in_cmux()
    if vim.fn.executable("cmux") ~= 1 then return false end
    vim.fn.system({ "cmux", "ping" })
    return vim.v.shell_error == 0
end

function M.send(text, press_enter)
    if in_tmux() then
        return require("agentic.tmux").send(text, press_enter)
    end
    if in_cmux() then
        return require("agentic.cmux").send(text, press_enter)
    end
    vim.notify("agentic: no tmux or cmux session detected", vim.log.levels.WARN)
end

return M
