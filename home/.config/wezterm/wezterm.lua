local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font = wezterm.font("Hack Nerd Font Mono")
config.font_size = 12.2

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true

config.window_decorations = "RESIZE"
config.window_background_opacity = 1.0
config.macos_window_background_blur = 10

-- https://github.com/mbadolato/iTerm2-Color-Schemes/blob/master/wezterm/Builtin%20Dark.toml
-- https://github.com/mbadolato/iTerm2-Color-Schemes/blob/master/wezterm/Hardcore.toml
-- config.color_scheme = '3024 (base16)'

config.colors = {
  foreground = "#ffffff",      -- base05 (fg)
  background = "#000000",      -- base00 (bg)

  cursor_bg = "#ffffff",       -- same as fg
  cursor_border = "#ffffff",
  cursor_fg = "#000000",       -- contrasting with white cursor

  selection_bg = "#333333",    -- base02 (selection)
  selection_fg = "#ffffff",    -- readable selected text

  ansi = {
    "#000000", -- black        (base00)
    "#ff0000", -- red          (base08)
    "#00ff00", -- green        (base0B)
    "#ffff00", -- yellow       (base0A)
    "#0000ff", -- blue         (base0D)
    "#ff00ff", -- magenta      (base0E)
    "#00ffff", -- cyan         (base0C)
    "#ffffff", -- white        (base05)
  },

  brights = {
    "#555555", -- bright black (base03)
    "#ff0000", -- bright red   (same as base08)
    "#00ff00", -- bright green (same as base0B)
    "#ffff00", -- bright yellow
    "#0000ff", -- bright blue
    "#ff00ff", -- bright magenta
    "#00ffff", -- bright cyan
    "#ffffff", -- bright white (base07)
  },
}

return config
