local vim = vim

local ref = require("agentic.ref")
local tmux = require("agentic.tmux")

local M = {}

-- A registered session name overrides the current session for future sends.
local registered = nil

local function pick(targets, prompt, callback)
    if #targets == 0 then
        vim.notify("agentic: nothing to select", vim.log.levels.WARN)
        return
    end
    if #targets == 1 then
        return callback(targets[1])
    end
    vim.ui.select(targets, {
        prompt = prompt,
        format_item = function(t) return t.label end,
    }, function(choice)
        if choice then callback(choice) end
    end)
end

-- Decide which session to act in (registered override, else nvim's current
-- tmux session), then pick a claude pane within it.
local function resolve(callback)
    local session = registered
    if session and not tmux.has_session(session) then
        registered = nil -- registered session is gone; fall back to current
        session = nil
    end
    session = session or tmux.current_session()
    if not session then
        vim.notify("agentic: not in a tmux session (use :AgenticRegister)", vim.log.levels.WARN)
        return
    end
    local targets = tmux.claude_panes(session)
    if #targets == 0 then
        vim.notify(("agentic: no claude in session '%s' (try :AgenticRegister)"):format(session), vim.log.levels.WARN)
        return
    end
    pick(targets, "agentic: select claude", callback)
end

function M.send(text, press_enter)
    resolve(function(t) tmux.send(t, text, press_enter) end)
end

function M.send_file(press_enter)
    local text = ref.file()
    if text then M.send(text, press_enter) end
end

function M.send_selection(press_enter)
    local text = ref.selection()
    if text then M.send(text, press_enter) end
end

-- Register against ANY session on the server (works even if nvim isn't in
-- tmux). Future sends look for claude in that session. Sticky until
-- re-registered or the session dies.
function M.register()
    pick(tmux.sessions(), "agentic: register session", function(choice)
        registered = choice.session
        vim.notify("agentic: registered session " .. choice.session, vim.log.levels.INFO)
    end)
end

function M.current()
    return registered
end

function M.setup(_)
    vim.api.nvim_create_user_command("AgenticSendFile", function() M.send_file() end, {
        desc = "Send current file reference to claude",
    })
    vim.api.nvim_create_user_command("AgenticSendSelection", function() M.send_selection() end, {
        desc = "Send visual selection reference to claude",
        range = true,
    })
    vim.api.nvim_create_user_command("AgenticRegister", function() M.register() end, {
        desc = "Register any tmux session (overrides current-session targeting)",
    })
end

return M
