local M = {
    base00 = '#000000', -- Background (Editor) -> ANSI 0 (Black)
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

return M
