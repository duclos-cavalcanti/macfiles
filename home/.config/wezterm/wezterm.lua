local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font = wezterm.font("Hack Nerd Font Mono")
config.font_size = 12.2

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true

config.window_decorations = "RESIZE"
config.window_background_opacity = 1.0
config.macos_window_background_blur = 10

config.color_scheme = 'carbonfox'
return config
