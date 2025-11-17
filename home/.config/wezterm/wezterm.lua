local wezterm = require("wezterm")
local theme = require("theme")


local config = wezterm.config_builder()
local colors = theme.get_colors()

local current_workspace = nil
local prev_workspace = nil

-- theme/font
config.font = wezterm.font("Hack Nerd Font Mono")
config.font_size = 11.0
config = theme.setup(config)

-- tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

-- window
config.window_decorations = "RESIZE" -- "TITLE | RESIZE"
config.window_background_opacity = 1.0
config.macos_window_background_blur = 10
config.window_padding = {
  left = 30,
  right = 20,
  top = 30,
  bottom = 20,
}

-- keys
if false then
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
      { key = 'u', mods = 'ALT', action = wezterm.action.SwitchWorkspaceRelative(-1) },
      { key = 'i', mods = 'ALT', action = wezterm.action.SwitchWorkspaceRelative(1) },
      { key = 'z', mods = 'CTRL', action = wezterm.action.TogglePaneZoomState },
      { key = 'L', mods = 'LEADER|SHIFT', action = wezterm.action_callback(function(window, pane)
        if prev_workspace then
          window:perform_action(wezterm.action.SwitchToWorkspace({ name = prev_workspace }), pane)
        end
      end) },
    }
    
    config.key_tables = {
      copy_mode = wezterm.gui.default_key_tables().copy_mode,
      search_mode = wezterm.gui.default_key_tables().search_mode,
    }
    
    -- misc settings
    config.scrollback_lines = 3500
    
    -- status update
    wezterm.on('update-status', function(window, pane)
        local workspace = window:active_workspace()
        local user = os.getenv("USER") or "user"
    
        if current_workspace and current_workspace ~= workspace then
           prev_workspace = current_workspace
         end
    
         current_workspace = workspace
    
        window:set_left_status(wezterm.format({
          { Foreground = { Color = colors.base08 } },
          { Text = " " .. '[' .. workspace .. ']' .. " " },
        }))
    
        window:set_right_status(wezterm.format({
          { Foreground = { Color = colors.base0C } },
          { Text = " " .. '[' .. user .. ']' .. " " },
        }))
    end)
end

return config
