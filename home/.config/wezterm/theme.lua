local M = {}

local wezterm = require("wezterm")

function M.get_colors()
    local base = os.getenv("MACFILES") or (wezterm.home_dir .. "/.macfiles")
    return dofile(base .. "/theme.lua")
end

function M.setup()
    local colors = M.get_colors()
    print(colors)
    local ret =  {
        foreground = colors.base05,
        background = colors.base00,

        cursor_bg = colors.base07,
        cursor_fg = colors.base07,
        cursor_border = colors.base0D,

        selection_bg = colors.base02,
        selection_fg = colors.base05,

        ansi = {
            colors.base00, -- ANSI 0 (Black)
            colors.base08, -- ANSI 1 (Red)
            colors.base0B, -- ANSI 2 (Green)
            colors.base0A, -- ANSI 3 (Yellow)
            colors.base0D, -- ANSI 4 (Blue)
            colors.base0E, -- ANSI 5 (Magenta)
            colors.base0C, -- ANSI 6 (Cyan)
            colors.base05, -- ANSI 7 (White)
        },

        brights = {
            colors.base03, -- ANSI 8  (Bright Black)
            colors.base09, -- ANSI 9  (Bright Red)
            colors.base01, -- ANSI 10 (Bright Green)
            colors.base02, -- ANSI 11 (Bright Yellow)
            colors.base04, -- ANSI 12 (Bright Blue)
            colors.base06, -- ANSI 13 (Bright Magenta)
            colors.base07, -- ANSI 14 (Bright Cyan)
            colors.base0F, -- ANSI 15 (Bright White)
        },

        tab_bar = {
            background = colors.base00,
            active_tab = {
                bg_color = colors.base00,
                fg_color = colors.base05,
            },
            inactive_tab = {
                bg_color = colors.base00,
                fg_color = colors.base03,
            },
            new_tab = {
                bg_color = colors.base00,
                fg_color = colors.base0F,
            },
            new_tab_hover = {
                bg_color = colors.base02,
                fg_color = colors.base05,
            },
        },

        copy_mode_active_highlight_bg = { Color = colors.base07 },
        copy_mode_active_highlight_fg = { Color = colors.base0F },
        copy_mode_inactive_highlight_bg = { Color = colors.base04 },
        copy_mode_inactive_highlight_fg = { Color = colors.base0F },
    }

    return ret
end


return M
