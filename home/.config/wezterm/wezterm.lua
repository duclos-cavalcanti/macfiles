local wezterm = require("wezterm")
local config = require("config")

local workspace = config.workspace
local theme     = config.theme
local tab       = config.tab

local c = wezterm.config_builder()

-- theme/font
c.colors = theme.setup()
c.font = wezterm.font("Iosevka Nerd Font Mono")
c.font_size = 11.0
c.bold_brightens_ansi_colors = false
c.inactive_pane_hsb = {
    saturation = 1.0,
    brightness = 1.0,
}

-- tab bar
c.enable_tab_bar = true
c.hide_tab_bar_if_only_one_tab = false
c.tab_bar_at_bottom = true
c.use_fancy_tab_bar = false

-- window
c.window_decorations = "RESIZE | TITLE" -- "TITLE | RESIZE"
c.window_background_opacity = 1.0
c.macos_window_background_blur = 10
c.window_padding = {
  left = 30,
  right = 20,
  top = 30,
  bottom = 20,
}

-- misc settings
c.scrollback_lines = 3500

-- keys
c.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
c.keys = {
    { key = 'a',        mods = 'LEADER|CTRL',       action = wezterm.action.SendKey { key = 'a', mods = 'CTRL' } },
    { key = 'b',        mods = 'LEADER|SHIFT',      action = wezterm.action.SendKey { key = 'b', mods = 'CTRL' } },
    { key = 'q',        mods = 'LEADER',            action = wezterm.action.PaneSelect { alphabet = 'hjklgui', mode = 'Activate', }},
    { key = 'v',        mods = 'LEADER',            action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 's',        mods = 'LEADER',            action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = 'x',        mods = 'LEADER',            action = wezterm.action.CloseCurrentPane { confirm = true } },
    { key = 'X',        mods = 'LEADER|SHIFT',      action = wezterm.action.CloseCurrentTab { confirm = true } },
    { key = 'c',        mods = 'LEADER',            action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
    { key = 'y',        mods = 'LEADER',            action = wezterm.action.ActivateCopyMode },
    { key = 'Y',        mods = 'LEADER|SHIFT',      action = wezterm.action.Search 'CurrentSelectionOrEmptyString' },
    { key = 'p',        mods = 'LEADER',            action = wezterm.action.PasteFrom 'Clipboard' },
    { key = 'h',        mods = 'ALT',               action = wezterm.action.ActivateTabRelative(-1) },
    { key = 'l',        mods = 'ALT',               action = wezterm.action.ActivateTabRelative(1) },
    { key = 'h',        mods = 'ALT|SHIFT',         action = wezterm.action.MoveTabRelative(-1) },
    { key = 'l',        mods = 'ALT|SHIFT',         action = wezterm.action.MoveTabRelative(1) },
    { key = 'h',        mods = 'LEADER',            action = wezterm.action.ActivatePaneDirection 'Left' },
    { key = 'j',        mods = 'LEADER',            action = wezterm.action.ActivatePaneDirection 'Down' },
    { key = 'k',        mods = 'LEADER',            action = wezterm.action.ActivatePaneDirection 'Up' },
    { key = 'l',        mods = 'LEADER',            action = wezterm.action.ActivatePaneDirection 'Right' },
    { key = "R",        mods = 'LEADER',            action = wezterm.action.RotatePanes("Clockwise") },
    { key = 'PageUp',   mods = 'CTRL|SHIFT',        action = wezterm.action.MoveTabRelative(-1) },
    { key = 'PageDown', mods = 'CTRL|SHIFT',        action = wezterm.action.MoveTabRelative(1) },
    { key = '{',        mods = 'LEADER',            action = wezterm.action.PaneSelect { mode = 'SwapWithActive', alphabet='hjklgui' } },
    { key = '}',        mods = 'LEADER',            action = wezterm.action.PaneSelect { mode = 'SwapWithActive', alphabet='hjklgui' } },
    { key = '!',        mods = 'LEADER|SHIFT',      action = wezterm.action.PaneSelect { mode = 'MoveToNewTab', alphabet='hjklgui' } },
    { key = 'z',        mods = 'CTRL',              action = wezterm.action.TogglePaneZoomState },
    { key = '0',        mods = 'LEADER',            action = wezterm.action.TogglePaneZoomState },
    { key = ',',        mods = 'LEADER',            action = tab.Rename() },
    { key = '$',        mods = 'LEADER|SHIFT',      action = workspace.Rename() },
    { key = 'w',        mods = 'LEADER',            action = workspace.Manager() },
    { key = 'n',        mods = 'LEADER',            action = workspace.Launch() },
    { key = 'd',        mods = 'LEADER',            action = workspace.Delete() },
    { key = '(',        mods = 'LEADER',            action = workspace.SwitchToPrevious()},
    { key = ')',        mods = 'LEADER',            action = workspace.SwitchToNext()},
    { key = 'L',        mods = 'LEADER|SHIFT',      action = workspace.SwitchToLast() },
}

c.key_tables = {
    copy_mode = wezterm.gui.default_key_tables().copy_mode,
    search_mode = wezterm.gui.default_key_tables().search_mode,
}

-- events
wezterm.on('update-status',       tab.Tabline)
wezterm.on('set-last-workspace',  workspace.SetLastWorkspace)

return c
