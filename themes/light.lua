local M = {
    base00 = '#ffffff', -- Background (Editor) -> ANSI 0 (Black) - Light background
    base01 = '#f0f1f4', -- Lighter Background/UI elements (Editor) -> ANSI 10 (Bright Green) - Very light gray
    base02 = '#e8e9ec', -- Selection/Highlight (Editor) -> ANSI 11 (Bright Yellow) - Light selection
    base03 = '#9ea8c7', -- Comments/Faint Foreground (Editor) -> ANSI 8 (Bright Black/Dark Gray) - Muted text
    base04 = '#606366', -- Darker Foreground (Editor) -> ANSI 12 (Bright Blue) - Medium gray text
    base05 = '#363447', -- Main Foreground (Editor) -> ANSI 7 (White) - Dark text on light bg
    base06 = '#2a2a2a', -- Lighter Foreground/Delimiters (Editor) -> ANSI 13 (Bright Magenta) - Darker text
    base07 = '#131313', -- Highest Contrast UI (Editor) -> ANSI 14 (Bright Cyan) - Darkest text

    base08 = '#d73a49', -- Red Accent (Errors, Constants) (Editor) -> ANSI 1 (Red) - Darker red for light bg
    base09 = '#e36209', -- Orange Accent (Warnings, Numbers) (Editor) -> ANSI 9 (Bright Red) - Darker orange
    base0A = '#b08800', -- Yellow Accent (Strings, Types) (Editor) -> ANSI 3 (Yellow) - Darker yellow/gold
    base0B = '#28a745', -- Green Accent (Success, Function Names) (Editor) -> ANSI 2 (Green) - Darker green
    base0C = '#17a2b8', -- Cyan Accent (Control Flow, Macros) (Editor) -> ANSI 6 (Cyan) - Darker cyan
    base0D = '#0366d6', -- Blue Accent (Keywords, Classes) (Editor) -> ANSI 4 (Blue) - Darker blue
    base0E = '#e1356f', -- Magenta Accent (Storage, Special Chars) (Editor) -> ANSI 5 (Magenta) - Darker magenta
    base0F = '#6f42c1'  -- Violet Accent (User Types, Exceptions) (Editor) -> ANSI 15 (Bright White) - Darker violet
}

return M
