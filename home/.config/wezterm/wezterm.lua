local wezterm = require("wezterm")
local theme = require("theme")
local keys = require("keys")


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

-- keys
if false then 
    config = keys.setup(config)
end

-- misc settings
config.scrollback_lines = 3500

return config
