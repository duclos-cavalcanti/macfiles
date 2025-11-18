local wezterm = require("wezterm")
local colors = require("theme").get_colors()

local M = {}

function M.Prompt(description, callback)
    local action = wezterm.action.PromptInputLine {
        description = description,
        action = wezterm.action_callback(function(window, pane, line)
            callback(window, pane, line) 
        end),
    }
    return action
end

function M.Callback(callback)
    local action = wezterm.action_callack(callback)
    return action
end

function M.ActionAndEmit(action, event)
    local actions = {}
    table.insert(actions, action)
    table.insert(actions, wezterm.action.EmitEvent(event))
    return wezterm.action.Multiple(actions)
end

function M.CallbackAndEmit(callback, event)
    local actions = {}
    table.insert(actions, wezterm.action_callback(callback))
    table.insert(actions, wezterm.action.EmitEvent(event))
    return wezterm.action.Multiple(actions)
end

function M.LaunchWorkspaceManager(window, pane)
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

function M.LaunchNewWorkspace(window, pane)
    window:perform_action(
        wezterm.action.PromptInputLine {
            description = 'Enter workspace name',
            action = wezterm.action_callback(function(window, pane, line)
                if line then
                    window:perform_action(
                        wezterm.action.SwitchToWorkspace { name = line },
                        pane
                    )
                end
            end),
        },
        pane
    )
end

function M.SetPreviousWorkspace(window, pane)
    local current_workspace = window:active_workspace()
    if wezterm.GLOBAL.previous_workspace ~= current_workspace then
        wezterm.GLOBAL.previous_workspace = current_workspace
    end
end

function M.SwitchToPreviousWorkspace(window, pane)
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

function M.RenameWorkspace()
    return M.Prompt('Enter new workspace name', function(window, pane, line)
        if line then
            wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
        end
    end)
end

function M.RenameTab()
    return M.Prompt('Enter new tab name', function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
    end)
end

function M.StatusLine(window, pane)
    local workspace = window:active_workspace()
    local user = os.getenv("USER") or "user"

    window:set_left_status(wezterm.format({
      { Foreground = { Color = colors.base08 } },
      { Text = " " .. '[' .. workspace .. ']' .. " " },
    }))

    window:set_right_status(wezterm.format({
      { Foreground = { Color = colors.base0C } },
      { Text = " " .. '[' .. user .. ']' .. " " },
    }))
end

return M
