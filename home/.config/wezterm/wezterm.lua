local wezterm = require("wezterm")
local config = wezterm.config_builder()
local theme = require("theme")

-- theme
config = theme.setup(config)

-- fonts
config.font = wezterm.font("Hack Nerd Font Mono")
config.font_size = 11.0

-- tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

-- window
-- config.window_decorations = "TITLE | RESIZE"
config.window_decorations = "RESIZE"
config.window_background_opacity = 1.0
config.macos_window_background_blur = 10
config.window_padding = {
  left = 20,
  right = 20,
  top = 20,
  bottom = 20,
}

-- scrollback
config.scrollback_lines = 3500

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
      { key = 'w', mods = 'LEADER', action = wezterm.action.ShowLauncherArgs { flags = 'WORKSPACES' } },
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
    }
    
    config.key_tables = {
      copy_mode = wezterm.gui.default_key_tables().copy_mode,
      search_mode = wezterm.gui.default_key_tables().search_mode,
    }
end

return config
