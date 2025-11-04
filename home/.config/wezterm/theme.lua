local M = {}

local colors = {
    base00 = '#131313', -- Background (Editor) -> ANSI 0 (Black)
    base01 = '#363447', -- Lighter Background/UI elements (Editor) -> ANSI 10 (Bright Green)
    base02 = '#44475a', -- Selection/Highlight (Editor) -> ANSI 11 (Bright Yellow)
    base03 = '#606366', -- Comments/Faint Foreground (Editor) -> ANSI 8 (Bright Black/Dark Gray)
    base04 = '#9ea8c7', -- Darker Foreground (Editor) -> ANSI 12 (Bright Blue)
    base05 = '#f8f8f2', -- Main Foreground (Editor) -> ANSI 7 (White)
    base06 = '#f0f1f4', -- Lighter Foreground/DelimitERS (Editor) -> ANSI 13 (Bright Magenta)
    base07 = '#ffffff', -- Highest Contrast UI (Editor) -> ANSI 14 (Bright Cyan)

    base08 = '#fb4934', -- Red Accent (Errors, Constants) (Editor) -> ANSI 1 (Red)
    base09 = '#ffb86c', -- Orange Accent (Warnings, Numbers) (Editor) -> ANSI 9 (Bright Red)
    base0A = '#f1fa8c', -- Yellow Accent (Strings, Types) (Editor) -> ANSI 3 (Yellow)
    base0B = '#50fa7b', -- Green Accent (Success, Function Names) (Editor) -> ANSI 2 (Green)
    base0C = '#8be9fd', -- Cyan Accent (Control Flow, Macros) (Editor) -> ANSI 6 (Cyan)
    base0D = '#74b2ff', -- Blue Accent (Keywords, Classes) (Editor) -> ANSI 4 (Blue)
    base0E = '#ff79c6', -- Magenta Accent (Storage, Special Chars) (Editor) -> ANSI 5 (Magenta)
    base0F = '#bd93f9'  -- Violet Accent (User Types, Exceptions) (Editor) -> ANSI 15 (Bright White)
}

function M.get_colors()
    return colors
end

function M.setup(config)
    config.bold_brightens_ansi_colors = false
    config.colors = {
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

    config.inactive_pane_hsb = {
        saturation = 0.9,
        brightness = 0.8,
    }

    return config
end


return M
