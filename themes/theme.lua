local M = {
    base00 = '#000000', -- Background (Editor) -> ANSI 0 (Black) - Retro greyish background
    base01 = '#222222', -- Lighter Background/UI elements (Editor) -> ANSI 10 (Bright Green) - Lighter grey
    base02 = '#323232', -- Selection/Highlight (Editor) -> ANSI 11 (Bright Yellow) - Selection grey
    base03 = '#4f4f4f', -- Comments/Faint Foreground (Editor) -> ANSI 8 (Bright Black/Dark Gray) - Medium grey
    base04 = '#666666', -- Darker Foreground (Editor) -> ANSI 12 (Bright Blue) - Dark grey
    base05 = '#f8f8f2', -- Main Foreground (Editor) -> ANSI 7 (White)
    base06 = '#c6c6c6', -- Lighter Foreground/Delimiters (Editor) -> ANSI 13 (Bright Magenta) - Darker text
    base07 = '#e9e9e9', -- Highest Contrast UI (Editor) -> ANSI 14 (Bright Cyan) - Pure black

    base08 = '#ff29a8', -- Red Accent (Errors, Constants) (Editor) -> ANSI 1 (Red) - Bright coral red
    base09 = '#85ffe0', -- Orange Accent (Warnings, Numbers) (Editor) -> ANSI 9 (Bright Red) - Bright orange
    base0A = '#f0ffaa', -- Yellow Accent (Strings, Types) (Editor) -> ANSI 3 (Yellow) - Bright yellow
    base0B = '#0badff', -- Green Accent (Success, Function Names) (Editor) -> ANSI 2 (Green) - Bright green
    base0C = '#8265ff', -- Cyan Accent (Control Flow, Macros) (Editor) -> ANSI 6 (Cyan) - Bright cyan
    base0D = '#00eaff', -- Blue Accent (Keywords, Classes) (Editor) -> ANSI 4 (Blue) - Bright blue
    base0E = '#00f6d9', -- Magenta Accent (Storage, Special Chars) (Editor) -> ANSI 5 (Magenta) - Bright purple
    base0F = '#ff3d81'  -- Violet Accent (User Types, Exceptions) (Editor) -> ANSI 15 (Bright White) - Deep violet
}

return M
