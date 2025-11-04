local wezterm = require("wezterm")

local M = {}

function M.setup(config)
    config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }
    config.keys = {
      { key = 'v', mods = 'LEADER', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
      { key = 's', mods = 'LEADER', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
      { key = 'x', mods = 'LEADER', action = wezterm.action.CloseCurrentPane { confirm = true } },
      { key = 'X', mods = 'LEADER|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = true } },
      { key = 'c', mods = 'LEADER', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
      { key = 'y', mods = 'LEADER', action = wezterm.action.ActivateCopyMode },
      { key = 'Y', mods = 'LEADER|SHIFT', action = wezterm.action.Search 'CurrentSelectionOrEmptyString' },
      { key = 'p', mods = 'LEADER', action = wezterm.action.PasteFrom 'Clipboard' },
      { key = 'h', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Left' },
      { key = 'j', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Down' },
      { key = 'k', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Up' },
      { key = 'l', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Right' },
      { key = 'UpArrow', mods = 'CTRL|SHIFT', action = wezterm.action.MoveTabRelative(-1) },
      { key = 'DownArrow', mods = 'CTRL|SHIFT', action = wezterm.action.MoveTabRelative(1) },
      { key = '$', mods = 'LEADER|SHIFT', action = wezterm.action.PromptInputLine {
        description = 'Enter new workspace name',
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
          end
        end),
      }},
      { key = ',', mods = 'LEADER', action = wezterm.action.PromptInputLine {
        description = 'Enter new tab name',
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            window:active_tab():set_title(line)
          end
        end),
      }},
      { key = 'w', mods = 'LEADER', action = wezterm.action.ShowLauncherArgs { flags = 'WORKSPACES' } },
      { key = 'W', mods = 'LEADER|SHIFT', action = wezterm.action_callback(function(window, pane)
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
      end)},
      { key = 'h', mods = 'ALT', action = wezterm.action.SwitchWorkspaceRelative(-1) },
      { key = 'l', mods = 'ALT', action = wezterm.action.SwitchWorkspaceRelative(1) },
      { key = 'z', mods = 'CTRL', action = wezterm.action.TogglePaneZoomState },
    }
    
    config.key_tables = {
      copy_mode = wezterm.gui.default_key_tables().copy_mode,
      search_mode = wezterm.gui.default_key_tables().search_mode,
    }

    return config
end

return M

