local vim = vim

-- The wezterm backend doesn't deliver text itself: it discovers which tmux
-- sessions live in the *focused wezterm tab*, then reuses the tmux backend's
-- per-session claude discovery and paste-based send. Correlation chain:
--   focused pane (wezterm cli) -> its tab -> sibling panes' tty_name
--   -> tmux client_tty -> session -> claude panes.
-- Each target also carries the wezterm pane id showing that session, so after
-- sending we can move the GUI focus there.
local tmux = require("agentic.tmux")

local M = {
    name = "wezterm",
    scope = "tab",
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

-- The GUI-focused pane id (robust, no env staleness), falling back to $WEZTERM_PANE.
local function focused_pane_id()
    local clients = json(run({ "wezterm", "cli", "list-clients", "--format", "json" }))
    if type(clients) == "table" and clients[1] and clients[1].focused_pane_id then
        return clients[1].focused_pane_id
    end
    return tonumber(vim.env.WEZTERM_PANE or "")
end

-- { [tty_name] = pane_id } for every wezterm pane sharing the focused pane's tab.
local function focused_tab_panes()
    local panes = json(run({ "wezterm", "cli", "list", "--format", "json" }))
    if type(panes) ~= "table" then return {} end

    local focus = focused_pane_id()
    local tab_id
    for _, p in ipairs(panes) do
        if focus and p.pane_id == focus then tab_id = p.tab_id break end
    end
    if not tab_id then -- fallback: first active pane
        for _, p in ipairs(panes) do
            if p.is_active then tab_id = p.tab_id break end
        end
    end
    if not tab_id then return {} end

    local by_tty = {}
    for _, p in ipairs(panes) do
        if p.tab_id == tab_id and p.tty_name then by_tty[p.tty_name] = p.pane_id end
    end
    return by_tty
end

-- { { session, pane = <wezterm pane id> }, ... } for sessions shown in the focused tab.
local function sessions_in_focused_tab()
    local by_tty = focused_tab_panes()
    local out = run({ "tmux", "list-clients", "-F", "#{client_tty}\t#{client_session}" })
    if not out then return {} end

    local result, seen = {}, {}
    for line in out:gmatch("[^\n]+") do
        local tty, sess = line:match("([^\t]+)\t(.+)")
        if tty and sess and by_tty[tty] and not seen[sess] then
            seen[sess] = true
            table.insert(result, { session = sess, pane = by_tty[tty] })
        end
    end
    return result
end

function M.list()
    if (vim.env.WEZTERM_CONFIG_DIR or "") == "" then return {} end
    local targets = {}
    for _, s in ipairs(sessions_in_focused_tab()) do
        for _, t in ipairs(tmux.claude_panes(s.session)) do
            t.label = string.format("%s  [%s]", t.label, s.session)
            t.wezterm_pane = s.pane -- the wezterm pane showing this tmux session
            table.insert(targets, t)
        end
    end
    return targets
end

function M.send(target, text, press_enter)
    -- tmux paste + select the claude pane inside its session.
    tmux.send(target, text, press_enter)
    -- then move the wezterm GUI focus to the pane showing that session.
    if target.wezterm_pane then
        run({ "wezterm", "cli", "activate-pane", "--pane-id", tostring(target.wezterm_pane) })
    end
end

return M
