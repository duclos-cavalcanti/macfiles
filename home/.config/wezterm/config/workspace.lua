local wezterm = require("wezterm")

local utils = require("config.utils")

local M = {}

function M.Rename()
    return utils.Prompt('Enter new workspace name', function(window, pane, line)
        wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
    end)
end

function M.Launch()
    local event  = wezterm.action.EmitEvent("set-previous-workspace")
    local action = utils.Prompt('Enter workspace name', function(window, pane, line)
        window:perform_action(
            wezterm.action.SwitchToWorkspace { name = line },
            pane
        )
    end)
    return wezterm.action.Multiple({event, action})
end

function M.Manager()
    local fn = function(window, pane)
        local workspaces = wezterm.mux.get_workspace_names()
        local choices = {}
        for _, name in ipairs(workspaces) do
            table.insert(choices, { label = name })
        end

        window:perform_action(
            wezterm.action.InputSelector {
                title = 'Select Workspace',
                choices = choices,
                fuzzy = true,
                action = wezterm.action_callback(function(window, pane, id, label)
                    if label then
                        window:perform_action(
                          wezterm.action.SwitchToWorkspace { name = label },
                          pane
                        )
                    end
                end),
            },
            pane
        )
    end

    local event  = wezterm.action.EmitEvent("set-previous-workspace")
    local action = wezterm.action_callback(fn)

    return wezterm.action.Multiple({event, action})
end


function M.SetPreviousWorkspace(window, pane)
    local current_workspace = window:active_workspace()
    if wezterm.GLOBAL.previous_workspace ~= current_workspace then
        wezterm.GLOBAL.previous_workspace = current_workspace
    end
end

function M.SwitchToNext()
    local event  = wezterm.action.EmitEvent("set-previous-workspace")
    local action = wezterm.action.SwitchWorkspaceRelative(1)
    return wezterm.action.Multiple({event, action})
end

function M.SwitchToPrevious()
    local event  = wezterm.action.EmitEvent("set-previous-workspace")
    local action = wezterm.action.SwitchWorkspaceRelative(-1)
    return wezterm.action.Multiple({event, action})
end

function M.SwitchToLast()
    local fn = function(window, pane)
        local current_workspace = window:active_workspace()
        local target_workspace = wezterm.GLOBAL.previous_workspace

        if current_workspace == target_workspace or wezterm.GLOBAL.previous_workspace == nil then
            return
        end

        window:perform_action(
            action.SwitchToWorkspace({
              name = target_workspace,
            }),
            pane
        )
        wezterm.GLOBAL.previous_workspace = current_workspace
    end
    return wezterm.action_callback(fn)
end

return M
