local vim = vim

-- The zellij backend handles the case where nvim runs in a *regular zellij
-- pane* (no tmux) while claude runs inside a tmux session in another pane.
-- nvim there has no $TMUX, so the tmux backend never engages -- but the tmux
-- *server* is reachable from any shell.
--
-- Discovery: zellij's CLI exposes no pane pid/tty, so we can't structurally map
-- a tmux session to a zellij pane. Instead we correlate on the *project*: nvim
-- and its claude work the same repo, so we keep only claude panes whose git
-- root matches nvim's, among *attached* sessions (drops detached/background
-- sessions like the MADY swarm).
--
-- Focus: after sending we move zellij focus to claude's pane. zellij's
-- list-panes reports `pane_command` (e.g. "tmux attach -t power-user"), so we
-- find the pane attached to the target session and focus it by id.
local tmux = require("agentic.tmux")

local M = {
    name = "zellij",
    scope = "repo",
}

local function run(cmd)
    local out = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then return nil end
    return out
end

local function json(out)
    if not out then return nil end
    local ok, val = pcall(vim.json.decode, out)
    if ok then return val end
    return nil
end

-- git toplevel for a path, or the path itself if it's not in a repo.
local function git_root(path)
    if not path or path == "" then return path end
    local out = run({ "git", "-C", path, "rev-parse", "--show-toplevel" })
    if not out then return path end
    return vim.trim(out)
end

-- Names of tmux sessions that currently have a client attached.
local function attached_sessions()
    local out = run({ "tmux", "list-sessions", "-F", "#{session_attached} #{session_name}" })
    if not out then return {} end
    local sessions = {}
    for line in out:gmatch("[^\n]+") do
        local att, name = line:match("^(%d+)%s+(.+)$")
        if att and tonumber(att) > 0 then
            table.insert(sessions, name)
        end
    end
    return sessions
end

-- Move zellij focus to the pane attached to `session`.
local function focus_session_pane(session)
    local panes = json(run({ "zellij", "action", "list-panes", "--all", "--json" }))
    if type(panes) ~= "table" then return end
    for _, p in ipairs(panes) do
        local cmd = p.pane_command
        if not p.is_plugin and type(cmd) == "string" and cmd:find("tmux", 1, true) then
            local arg = cmd:match("%-t%s*(%S+)")
            if arg == session or cmd:find(session, 1, true) then
                run({ "zellij", "action", "focus-pane-id", "terminal_" .. tostring(p.id) })
                return
            end
        end
    end
end

function M.list()
    if (vim.env.ZELLIJ or "") == "" then return {} end
    local root = git_root(vim.fn.getcwd())
    local targets = {}
    for _, sess in ipairs(attached_sessions()) do
        for _, t in ipairs(tmux.claude_panes(sess)) do
            if git_root(t.cwd) == root then
                t.label = string.format("%s  [%s]", t.label, sess)
                table.insert(targets, t)
            end
        end
    end
    return targets
end

function M.send(target, text, press_enter)
    tmux.send(target, text, press_enter)
    if target.session then
        focus_session_pane(target.session)
    end
end

return M
