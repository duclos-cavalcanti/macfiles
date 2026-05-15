local vim = vim

local M = {}

local function any_claude(node)
    if type(node) ~= "table" then return false end
    if node.kind == "process" then
        local path = node.path or ""
        if path:find("/claude/", 1, true) then return true end
    end
    for _, v in pairs(node) do
        if type(v) == "table" and any_claude(v) then return true end
    end
    return false
end

local function find_agent_surface()
    local out = vim.fn.system({ "cmux", "--id-format", "both", "top", "--processes", "--json" })
    if vim.v.shell_error ~= 0 then return nil end

    local ok, data = pcall(vim.json.decode, out)
    if not ok or type(data) ~= "table" then return nil end

    local current_workspace = vim.env.CMUX_WORKSPACE_ID
    local current_surface = vim.env.CMUX_SURFACE_ID

    for _, window in ipairs(data.windows or {}) do
        for _, ws in ipairs(window.workspaces or {}) do
            if not current_workspace or ws.id == current_workspace then
                for _, pane in ipairs(ws.panes or {}) do
                    for _, surface in ipairs(pane.surfaces or {}) do
                        if surface.id and surface.id ~= current_surface and any_claude(surface) then
                            return { ref = surface.ref, id = surface.id }
                        end
                    end
                end
            end
        end
    end
    return nil
end

function M.send(text, press_enter)
    local surface = find_agent_surface()
    if not surface then
        vim.notify("agentic.cmux: no claude surface found in current workspace", vim.log.levels.WARN)
        return
    end

    -- cmux send interprets the two-char sequence "\n" as Enter, so append it to auto-submit
    local payload = press_enter and (text .. "\\n") or text
    local out = vim.fn.system({ "cmux", "send", "--surface", surface.ref, "--", payload })
    if vim.v.shell_error ~= 0 then
        vim.notify("agentic.cmux: send failed: " .. out, vim.log.levels.ERROR)
        return
    end

    local params = vim.json.encode({ surface_id = surface.id })
    out = vim.fn.system({ "cmux", "rpc", "surface.focus", params })
    if vim.v.shell_error ~= 0 then
        vim.notify("agentic.cmux: focus failed: " .. out, vim.log.levels.WARN)
    end
end

return M
