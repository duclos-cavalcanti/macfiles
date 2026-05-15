local vim = vim

local M = {}

local function run(cmd, stdin)
    local out = vim.fn.system(cmd, stdin)
    if vim.v.shell_error ~= 0 then
        vim.notify("agentic.tmux: " .. table.concat(cmd, " ") .. " failed: " .. out, vim.log.levels.ERROR)
        return nil
    end
    return out
end

local function current_session()
    local out = run({ "tmux", "display-message", "-p", "#{session_name}" })
    return out and vim.trim(out) or nil
end

local function find_agent_pane()
    local sess = current_session()
    if not sess then return nil end

    local out = run({ "tmux", "list-panes", "-s", "-t", sess, "-F", "#{pane_id}:#{pane_pid}" })
    if not out then return nil end

    for line in out:gmatch("[^\n]+") do
        local pane, pid = line:match("([^:]+):(%d+)")
        if pane and pid then
            vim.fn.system({ "pgrep", "-P", pid, "-f", "claude" })
            if vim.v.shell_error == 0 then
                return pane
            end
        end
    end
    return nil
end

function M.send(text, press_enter)
    local pane = find_agent_pane()
    if not pane then
        vim.notify("agentic.tmux: no claude pane found in current session", vim.log.levels.WARN)
        return
    end

    local buffer = "agentic-" .. pane
    if not run({ "tmux", "load-buffer", "-b", buffer, "-" }, text) then return end
    if not run({ "tmux", "paste-buffer", "-b", buffer, "-d", "-r", "-t", pane }) then return end
    if press_enter then
        run({ "tmux", "send-keys", "-t", pane, "Enter" })
    end
    run({ "tmux", "select-pane", "-t", pane })
end

return M
