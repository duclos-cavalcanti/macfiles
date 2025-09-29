local M = {}
-- ANSIBlackColor:          #1F1F1F, Black (0)
-- ANSIBlueColor:           #2A84D2, Blue (4)
-- ANSICyanColor:           #0F81D6, Cyan (6)
-- ANSIGreenColor:          #2DC55E, Green (2)
-- ANSIMagentaColor:        #4E5AB7, Magenta (5)
-- ANSIRedColor:            #F81118, Red (1)
-- ANSIWhiteColor:          #D6D9E5, White (7)
-- ANSIYellowColor:         #ECCB0F, Yellow (3)
--
-- ANSIBrightBlackColor:    #D6D9E5, BrightBlack (8)  -- Note: This is often rendered as White/Light Gray
-- ANSIBrightBlueColor:     #0F81D6, BrightBlue (12)
-- ANSIBrightCyanColor:     #0E7DC4, BrightCyan (14)
-- ANSIBrightGreenColor:    #1DD361, BrightGreen (10)
-- ANSIBrightMagentaColor:  #5350B9, BrightMagenta (13)
-- ANSIBrightRedColor:      #DE352E, BrightRed (9)
-- ANSIBrightWhiteColor:    #FFFFFF, BrightWhite (15)
-- ANSIBrightYellowColor:   #F3BC09, BrightYellow (11)

local colors = {
  bg              = { gui = "#131313",  cterm = "Black" },       -- BackgroundColor
  fg              = { gui = "#d6dbe5",  cterm = "White" },       -- TextColor (Foreground)
  black_ansi      = { gui = "#1f1f1f",  cterm = "Black" },       -- ANSIBlackColor (for non-bg black areas)
  line_nr_fg      = { gui = "#5d6f92",  cterm = "Grey" },        -- LineNr FG (custom hex, setting cterm to a standard Grey)
  grey_comment    = { gui = "#6e6f70",  cterm = "DarkGrey" },    -- Comment FG (your custom grey)

  red             = { gui = "#f81118",  cterm = "Red" },         -- ANSIRedColor
  bright_red      = { gui = "#de352e",  cterm = "Red" },         -- ANSIBrightRedColor (Mapped to Red, as BrightRed can be harsh)
  green           = { gui = "#2dc55e",  cterm = "Green" },       -- ANSIGreenColor
  bright_yellow   = { gui = "#f3bd09",  cterm = "Yellow" },      -- ANSIBrightYellowColor (Mapped to Yellow)
  bright_magenta  = { gui = "#5350b9",  cterm = "Magenta" },     -- ANSIBrightMagentaColor
  cyan_func       = { gui = "#1081d6",  cterm = "Cyan" },        -- Close to ANSICyanColor
  cyan_op         = { gui = "#0f7ddb",  cterm = "Cyan" },        -- Close to ANSIBrightCyanColor
}

local function hi(group, foreground, background, style)
    local cmd = "highlight " .. group
    local guiOn = vim.opt.termguicolors:get() -- Check if termguicolors is enabled[]
    if guiOn then
        if foreground then cmd = cmd .. " guifg=" .. foreground.gui end
        if background then cmd = cmd .. " guibg=" .. background.gui end
        if style then cmd = cmd .. " gui=" .. style end
    else 
        if foreground then cmd = cmd .. " ctermfg=" .. foreground.cterm end
        if background then cmd = cmd .. " ctermbg=" .. background.cterm end
        if style then cmd = cmd .. " cterm=" .. style end
    end
    vim.cmd(cmd)
end

hi("clear")
vim.opt.background = "dark"

-- Main Highlights
hi("Normal", colors.fg, colors.bg, "NONE")
hi("SignColumn", nil, colors.bg) -- Same background as Normal
hi("LineNr", colors.line_nr_fg, colors.bg)
hi("NonText", colors.bright_red, colors.bg)
hi("CursorLine", nil, colors.black_ansi)
hi("Visual", nil, colors.line_nr_fg)

-- Statusline/Tabline
hi("Pmenu", colors.fg, colors.black_ansi)
hi("TabLineFill", nil, colors.black_ansi, "NONE")
hi("TabLine", colors.line_nr_fg, colors.black_ansi, "NONE")
hi("StatusLine", colors.fg, colors.black_ansi, "bold")
hi("StatusLineNC", colors.fg, colors.bg, "NONE")
hi("VertSplit", colors.black_ansi, nil, "NONE")
hi("Search", colors.fg, colors.bright_red)
hi("MatchParen", colors.bright_yellow, nil)


local red_groups = {
  "DiffText", "ErrorMsg", "WarningMsg", "PreProc", "Exception", "Error",
  "DiffDelete", "GitGutterDelete", "GitGutterChangeDelete", "cssIdentifier",
  "cssImportant", "Type", "Identifier",
}
for _, group in ipairs(red_groups) do
  hi(group, colors.red)
end
hi("Comment", colors.grey, nil, "italic")
hi("SpecialComment", colors.grey, nil, "italic")

local green_groups = {
  "PMenuSel", "Constant", "Repeat", "DiffAdd", "GitGutterAdd", "cssIncludeKeyword", "Keyword"
}
for _, group in ipairs(green_groups) do
  hi(group, colors.green)
end

local yellow_groups = {
  "IncSearch", "Title", "PreCondit", "Debug", "SpecialChar", "Conditional",
  "Todo", "Special", "Label", "Delimiter", "Number", "CursorLineNR",
  "Define", "MoreMsg", "Tag", "String", "Macro", "DiffChange",
  "GitGutterChange", "cssColor"
}
for _, group in ipairs(yellow_groups) do
  hi(group, colors.bright_yellow)
end

hi("Function", colors.cyan_func)

local magenta_groups = {
  "Directory", "markdownLinkText", "javaScriptBoolean", "Include", "Storage",
  "cssClassName", "cssClassNameDot"
}
for _, group in ipairs(magenta_groups) do
  hi(group, colors.bright_magenta)
end

local op_groups = {
  "Statement", "Operator", "cssAttr"
}
for _, group in ipairs(op_groups) do
  hi(group, colors.cyan_op)
end

return M
