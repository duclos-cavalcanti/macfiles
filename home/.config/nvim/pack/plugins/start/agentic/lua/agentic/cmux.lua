local vim = vim

local M = {
    name = "cmux",
    scope = "workspace",
}

local function find_claude_pid(node)
    if type(node) ~= "table" then return nil end
    local name = type(node.name) == "string" and node.name or ""
    local path = type(node.path) == "string" and node.path or ""
    if node.kind == "process" and (name == "claude" or path:match("/claude$") or path:find("/claude/", 1, true)) then
        return node.pid
    end
    for _, v in pairs(node) do
        if type(v) == "table" then
            local pid = find_claude_pid(v)
            if pid then return pid end
        end
    end
    return nil
end

local function lsof_cwd(pid)
    if not pid then return nil end
    local out = vim.fn.system({ "lsof", "-p", tostring(pid), "-a", "-d", "cwd", "-Fn" })
    if vim.v.shell_error ~= 0 then return nil end
    for line in out:gmatch("[^\n]+") do
        local cwd = line:match("^n(.+)$")
        if cwd then return cwd end
    end
    return nil
end

local function workspace_of_surface(data, surface_id)
    if not surface_id then return nil end
    for _, window in ipairs(data.windows or {}) do
        for _, ws in ipairs(window.workspaces or {}) do
            for _, pane in ipairs(ws.panes or {}) do
                for _, surface in ipairs(pane.surfaces or {}) do
                    if surface.id == surface_id then return ws.id end
                end
            end
        end
    end
    return nil
end

function M.list()
    local out = vim.fn.system({ "cmux", "--id-format", "both", "top", "--processes", "--json" })
    if vim.v.shell_error ~= 0 then return {} end

    local ok, data = pcall(vim.json.decode, out)
    if not ok or type(data) ~= "table" then return {} end

    local env_workspace = vim.env.CMUX_WORKSPACE_ID
    local current_surface = vim.env.CMUX_SURFACE_ID

    -- Env var can be stale if the surface was moved between workspaces.
    -- Derive workspace from current_surface; fall back to env var.
    local current_workspace = workspace_of_surface(data, current_surface) or env_workspace

    local targets = {}
    for _, window in ipairs(data.windows or {}) do
        for _, ws in ipairs(window.workspaces or {}) do
            if not current_workspace or ws.id == current_workspace then
                for _, pane in ipairs(ws.panes or {}) do
                    for _, surface in ipairs(pane.surfaces or {}) do
                        if surface.id and surface.id ~= current_surface then
                            local pid = find_claude_pid(surface)
                            if pid then
                                local title = surface.title or ""
                                local cwd = lsof_cwd(pid)
                                local main = (title ~= "" and title)
                                    or (cwd and vim.fn.fnamemodify(cwd, ":~"))
                                    or surface.ref
                                table.insert(targets, {
                                    id = surface.id,
                                    ref = surface.ref,
                                    title = title,
                                    cwd = cwd,
                                    label = string.format("%s  (%s)", main, surface.ref),
                                })
                            end
                        end
                    end
                end
            end
        end
    end
    return targets
end

function M.preview(path)
    local out = vim.fn.system({ "cmux", "markdown", "open", path, "--focus", "false" })
    if vim.v.shell_error ~= 0 then
        vim.notify("agentic.cmux: markdown open failed: " .. out, vim.log.levels.ERROR)
    end
end

function M.send(target, text, press_enter)
    -- cmux send interprets the two-char sequence "\n" as Enter, so append it to auto-submit
    local payload = press_enter and (text .. "\\n") or text
    local out = vim.fn.system({ "cmux", "send", "--surface", target.ref, "--", payload })
    if vim.v.shell_error ~= 0 then
        vim.notify("agentic.cmux: send failed: " .. out, vim.log.levels.ERROR)
        return
    end

    local params = vim.json.encode({ surface_id = target.id })
    out = vim.fn.system({ "cmux", "rpc", "surface.focus", params })
    if vim.v.shell_error ~= 0 then
        vim.notify("agentic.cmux: focus failed: " .. out, vim.log.levels.WARN)
    end
end

return M
