local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font = wezterm.font("Hack Nerd Font Mono")
config.font_size = 12.5

config.enable_tab_bar = false

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.75
config.macos_window_background_blur = 10

return config
