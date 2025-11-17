local wezterm = require("wezterm")
local theme = require("theme")

local F = require("functions")

local config = wezterm.config_builder()

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

-- misc settings
config.scrollback_lines = 3500

-- keys
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
  { key = "R", mods = 'LEADER', action = wezterm.action.RotatePanes("Clockwise") },
  { key = 'PageUp', mods = 'CTRL|SHIFT', action = wezterm.action.MoveTabRelative(-1) },
  { key = 'PageDown', mods = 'CTRL|SHIFT', action = wezterm.action.MoveTabRelative(1) },
  { key = '$', mods = 'LEADER|SHIFT', action = F.RenameWorkspace() },
  { key = ',', mods = 'LEADER', action = F.RenameTab() },
  { key = 'w', mods = 'LEADER', action = F.ActionAndEmit(wezterm.action.ShowLauncherArgs { flags = 'WORKSPACES' }, "set-previous-workspace") },
  { key = 'W', mods = 'LEADER|SHIFT', action = F.CallbackAndEmit(F.LaunchWorkspaceManager, "set-previous-workspace") },
  { key = '(', mods = 'LEADER', action = F.ActionAndEmit(wezterm.action.SwitchWorkspaceRelative(-1), 'set-previous-workspace')},
  { key = ')', mods = 'LEADER', action = F.ActionAndEmit(wezterm.action.SwitchWorkspaceRelative(1), 'set-previous-workspace')},
  { key = 'z', mods = 'CTRL', action = wezterm.action.TogglePaneZoomState },
  { key = 'L', mods = 'LEADER|SHIFT', action = F.CallbackAndEmit(F.SwitchToPreviousWorkspace, 'set-previous-workspace') },
}

config.key_tables = {
  copy_mode = wezterm.gui.default_key_tables().copy_mode,
  search_mode = wezterm.gui.default_key_tables().search_mode,
}

-- events
wezterm.on('update-status', F.StatusLine)
wezterm.on('set-previous-workspace', F.SetPreviousWorkspace)

return config
