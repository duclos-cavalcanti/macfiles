local vim = vim

local M = {}

-- In-memory registration: { backend = "tmux"|"cmux", target = { id, label, ... } }
local registered = nil

local function active_backend()
    if (vim.env.TMUX or "") ~= "" then
        return require("agentic.tmux")
    end
    if vim.fn.executable("cmux") == 1 then
        vim.fn.system({ "cmux", "ping" })
        if vim.v.shell_error == 0 then
            return require("agentic.cmux")
        end
    end
    return nil
end

local function find_cached(backend)
    if not registered or registered.backend ~= backend.name then return nil end
    for _, t in ipairs(backend.list()) do
        if t.id == registered.target.id then return t end
    end
    registered = nil
    return nil
end

local function pick(backend, callback)
    local targets = backend.list()
    if #targets == 0 then
        vim.notify(("agentic: no claude found in current %s"):format(backend.scope), vim.log.levels.WARN)
        return
    end
    if #targets == 1 then
        registered = { backend = backend.name, target = targets[1] }
        return callback(targets[1])
    end
    vim.ui.select(targets, {
        prompt = "agentic: select claude",
        format_item = function(t) return t.label end,
    }, function(choice)
        if choice then
            registered = { backend = backend.name, target = choice }
            callback(choice)
        end
    end)
end

function M.send(text, press_enter)
    local backend = active_backend()
    if not backend then
        vim.notify("agentic: no tmux or cmux session detected", vim.log.levels.WARN)
        return
    end
    local cached = find_cached(backend)
    if cached then
        return backend.send(cached, text, press_enter)
    end
    pick(backend, function(target)
        backend.send(target, text, press_enter)
    end)
end

function M.register()
    local backend = active_backend()
    if not backend then
        vim.notify("agentic: no tmux or cmux session detected", vim.log.levels.WARN)
        return
    end
    registered = nil
    pick(backend, function(target)
        vim.notify(("agentic: registered %s"):format(target.label), vim.log.levels.INFO)
    end)
end

function M.current()
    return registered
end

return M
