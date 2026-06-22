local vim = vim

local M = {
    name = "tmux",
    scope = "session",
}

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

local function claude_pid_under(pane_pid)
    local out = vim.fn.system({ "pgrep", "-P", pane_pid, "-f", "claude" })
    if vim.v.shell_error ~= 0 then return nil end
    out = vim.trim(out)
    if out == "" then return nil end
    return out:match("[^\n]+")
end

-- Claude panes within a given tmux session. Shared with the wezterm backend,
-- which scopes the session set to the focused wezterm tab.
function M.claude_panes(session)
    local out = run({
        "tmux", "list-panes", "-s", "-t", session,
        "-F", "#{pane_id}\t#{pane_pid}\t#{window_name}\t#{pane_current_path}",
    })
    if not out then return {} end

    local targets = {}
    for line in out:gmatch("[^\n]+") do
        local pane, pid, win, cwd = line:match("([^\t]+)\t([^\t]+)\t([^\t]*)\t(.+)")
        if pane and pid and claude_pid_under(pid) then
            local main = (win and win ~= "" and win)
                or (cwd and vim.fn.fnamemodify(cwd, ":~"))
                or pane
            table.insert(targets, {
                id = pane,
                pane = pane,
                session = session,
                window_name = win,
                cwd = cwd,
                label = string.format("%s  (%s)", main, pane),
            })
        end
    end
    return targets
end

function M.list()
    local sess = current_session()
    if not sess then return {} end
    return M.claude_panes(sess)
end

function M.send(target, text, press_enter)
    local pane = target.pane
    local buffer = "agentic-" .. pane

    if not run({ "tmux", "load-buffer", "-b", buffer, "-" }, text) then return end
    if not run({ "tmux", "paste-buffer", "-b", buffer, "-d", "-r", "-t", pane }) then return end
    if press_enter then
        run({ "tmux", "send-keys", "-t", pane, "Enter" })
    end
    run({ "tmux", "select-pane", "-t", pane })
end

return M
