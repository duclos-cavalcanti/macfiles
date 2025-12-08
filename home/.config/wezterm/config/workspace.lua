local wezterm = require("wezterm")

local utils = require("config.utils")

local M = {}

function M.Rename()
    return utils.Prompt('Enter new workspace name', function(window, pane, line)
        wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
    end)
end

function M.Launch()
    local action = utils.Prompt('Enter workspace name', function(window, pane, line)
        wezterm.emit("set-last-workspace", window, pane, window:active_workspace())
        window:perform_action(
            wezterm.action.SwitchToWorkspace { name = line },
            pane
        )
    end)
    local event  = wezterm.action.EmitEvent("set-last-workspace")
    return wezterm.action.Multiple({event, action})
end

function M.Manager()
    local fn = function(window, pane)
        local workspaces = wezterm.mux.get_workspace_names()
        local choices = {}
        for _, name in ipairs(workspaces) do
            table.insert(choices, { label = name })
        end

        wezterm.emit("set-last-workspace", window, pane, window:active_workspace())

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

    local action = wezterm.action_callback(fn)
    return action
end

function M.Delete()
    local fn = function(window, pane)
        local workspaces = wezterm.mux.get_workspace_names()
        local current_workspace = window:active_workspace()
        local choices = {}

        for _, name in ipairs(workspaces) do
            if name ~= current_workspace then
                table.insert(choices, { label = name })
            end
        end

        if #choices == 0 then
            return
        end

        window:perform_action(
            wezterm.action.InputSelector {
                title = 'Delete Workspace',
                description = 'Select workspace to delete (current workspace excluded):',
                choices = choices,
                fuzzy = true,
                action = wezterm.action_callback(function(window, pane, id, label)
                    if label then
                        local workspace = {}
                        local state = utils.State()
                        if not state then return end

                        for _, v in ipairs(state) do
                            if v.workspace == label then
                                table.insert(workspace, v)
                            end
                        end

                        if workspace then
                            for _, v in ipairs(workspace) do
                                wezterm.log_info("PANE: " .. wezterm.to_string(v.pane_id))
                                wezterm.run_child_process({
				                    "/opt/homebrew/bin/wezterm",
				                    "cli",
				                    "kill-pane",
				                    "--pane-id=" .. v.pane_id,
			                    })
                            end
                        end
                    end
                end),
            },
            pane
        )
    end

    local action = wezterm.action_callback(fn)
    return action
end

function M.SetLastWorkspace(window, pane, workspace)
    local current_workspace = workspace or window:active_workspace()
    wezterm.GLOBAL.previous_workspace = current_workspace
end

function M.SwitchToNext()
    local fn = function(window, pane)
        local current_workspace = window:active_workspace()
        wezterm.emit("set-last-workspace", window, pane, current_workspace)
        window:perform_action(wezterm.action.SwitchWorkspaceRelative(1), pane)
    end
    return wezterm.action_callback(fn)
end

function M.SwitchToPrevious()
    local fn = function(window, pane)
        local current_workspace = window:active_workspace()
        wezterm.emit("set-last-workspace", window, pane, current_workspace)
        window:perform_action(wezterm.action.SwitchWorkspaceRelative(-1), pane)
    end
    return wezterm.action_callback(fn)
end

function M.SwitchToLast()
    local fn = function(window, pane)
        local current_workspace = window:active_workspace()
        local target_workspace = wezterm.GLOBAL.previous_workspace

        if current_workspace == target_workspace or wezterm.GLOBAL.previous_workspace == nil then
            return
        end

        window:perform_action(
            wezterm.action.SwitchToWorkspace({
              name = target_workspace,
            }),
            pane
        )
        wezterm.GLOBAL.previous_workspace = current_workspace
    end

    local action = wezterm.action_callback(fn)
    return action
end

function M.SwitchToWorkspace(target)
    local fn = function(window, pane)
        local current_workspace = window:active_workspace()
        local target_workspace = target
        wezterm.emit("set-last-workspace", window, pane, current_workspace)
        window:perform_action(
            wezterm.action.SwitchToWorkspace({
              name = target_workspace,
            }),
            pane
        )
    end

    local action = wezterm.action_callback(fn)
    return action
end

return M
