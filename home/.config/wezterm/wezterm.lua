local wezterm = require("wezterm")
local config = require("config")

local workspace = config.workspace
local theme     = config.theme
local tab       = config.tab

local c = wezterm.config_builder()

-- theme/font
c.colors = theme.setup()
c.font = wezterm.font("Iosevka Nerd Font Mono")
c.font_size = 12.0
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
c.window_decorations = "RESIZE | INTEGRATED_BUTTONS" -- "TITLE | RESIZE"
c.window_background_opacity = 1.0
c.macos_window_background_blur = 10
c.window_padding = {
  left = 30,
  right = 20,
  top = 40,
  bottom = 20,
}

-- misc settings
c.scrollback_lines = 3500

-- keys
c.keys = {
    { key = 's',        mods = 'CMD|SHIFT',         action = wezterm.action.PaneSelect { alphabet = 'hjklgui', mode = 'Activate', }},

    { key = 'd',        mods = 'CMD',               action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 'd',        mods = 'CMD|SHIFT',         action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },

    { key = 'w',        mods = 'CMD',               action = wezterm.action.CloseCurrentPane { confirm = true } },
    { key = 'w',        mods = 'CMD|SHIFT',         action = wezterm.action.CloseCurrentTab { confirm = true } },

    { key = 't',        mods = 'CMD',               action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
    { key = 'l',        mods = 'CMD',               action = tab.Rename() },

    { key = 'Tab',      mods = 'CMD|SHIFT',         action = wezterm.action.ActivateTabRelative(-1) },
    { key = 'Tab',      mods = 'CMD',               action = wezterm.action.ActivateTabRelative(1) },
    { key = 'Tab',      mods = 'ALT',               action = wezterm.action.MoveTabRelative(-1) },
    { key = 'Tab',      mods = 'ALT|SHIFT',         action = wezterm.action.MoveTabRelative(1) },

    { key = 'h',        mods = 'CMD|SHIFT',         action = wezterm.action.ActivatePaneDirection 'Left' },
    { key = 'j',        mods = 'CMD|SHIFT',         action = wezterm.action.ActivatePaneDirection 'Down' },
    { key = 'k',        mods = 'CMD|SHIFT',         action = wezterm.action.ActivatePaneDirection 'Up' },
    { key = 'l',        mods = 'CMD|SHIFT',         action = wezterm.action.ActivatePaneDirection 'Right' },

    { key = "r",        mods = 'CMD|SHIFT',         action = wezterm.action.RotatePanes("Clockwise") },
    { key = 'r',        mods = 'CMD',               action = wezterm.action.PaneSelect { mode = 'SwapWithActive', alphabet='hjklgui' } },
    { key = '1',        mods = 'CMD|SHIFT',         action = wezterm.action.PaneSelect { mode = 'MoveToNewTab', alphabet='hjklgui' } },

    { key = 'z',        mods = 'CMD|SHIFT',         action = wezterm.action.TogglePaneZoomState },

    { key = 'n',        mods = 'CMD',               action = workspace.Launch() },
    { key = '4',        mods = 'CMD|SHIFT',         action = workspace.Rename() },
    { key = 's',        mods = 'CMD',               action = workspace.Manager() },
    { key = 'd',        mods = 'CMD|CTRL',          action = workspace.Delete() },

    { key = '9',        mods = 'CMD|SHIFT',         action = workspace.SwitchToPrevious()},
    { key = '0',        mods = 'CMD|SHIFT',         action = workspace.SwitchToNext()},

    { key = 'r',        mods = 'CMD',               action = wezterm.action.ReloadConfiguration },

    { key = 'y',        mods = 'CMD',               action = wezterm.action.ActivateCopyMode },
    { key = 'y',        mods = 'CMD|SHIFT',         action = wezterm.action.Search 'CurrentSelectionOrEmptyString' },
    { key = 'v',        mods = 'CMD',               action = wezterm.action.PasteFrom 'Clipboard' },

}

c.key_tables = {
    copy_mode = wezterm.gui.default_key_tables().copy_mode,
    search_mode = wezterm.gui.default_key_tables().search_mode,
}

-- events
wezterm.on('update-status', tab.Tabline)

return c
