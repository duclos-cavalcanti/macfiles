local M = {}
-- ANSIBlackColor	        #1F1F1F
-- ANSIBlueColor	        #2A84D2
-- ANSICyanColor	        #0F81D6
-- ANSIGreenColor	        #2DC55E
-- ANSIMagentaColor	        #4E5AB7
-- ANSIRedColor	            #F81118
-- ANSIWhiteColor           #D6D9E5
-- ANSIYellowColor	        #ECCB0F
--
-- ANSIBrightBlackColor	    #D6D9E5
-- ANSIBrightBlueColor	    #0F81D6
-- ANSIBrightCyanColor	    #0E7DC4
-- ANSIBrightGreenColor	    #1DD361
-- ANSIBrightMagentaColor   #5350B9
-- ANSIBrightRedColor	    #DE352E
-- ANSIBrightWhiteColor	    #FFFFFF
-- ANSIBrightYellowColor	#F3BC09

local colors = {
  bg = "#131313",               -- BackgroundColor
  fg = "#d6dbe5",               -- TextColor (Foreground)
  black_ansi = "#1f1f1f",       -- ANSIBlackColor
  bright_red = "#de352e",       -- ANSIBrightRedColor (Used for ErrorMsg)
  green = "#2dc55e",            -- ANSIGreenColor (Used for Constants, Keywords)
  bright_yellow = "#f3bd09",    -- ANSIBrightYellowColor (Used for Strings, Numbers, Title)
  bright_magenta = "#5350b9",   -- ANSIBrightMagentaColor (Used for Directory, Storage)
  cyan_func = "#1081d6",        -- Close to ANSICyanColor (Used for Function)
  cyan_op = "#0f7ddb",          -- Close to ANSIBrightCyanColor (Used for Statement, Operator)
  grey = "#6e6f70",             -- Close to ANSIBrightCyanColor (Used for Statement, Operator)
}

local function hi(group, foreground, background, style)
  local cmd = "highlight " .. group
  if foreground then cmd = cmd .. " guifg=" .. foreground end
  if background then cmd = cmd .. " guibg=" .. background end
  if style then cmd = cmd .. " gui=" .. style end
  vim.cmd(cmd)
end

hi("clear")
vim.opt.background = "dark"
vim.opt.termguicolors = true

-- Main Highlights
hi("Normal", colors.fg, colors.bg, "NONE")
hi("SignColumn", nil, colors.bg) -- Same background as Normal
hi("LineNr", "#5d6f92", colors.bg)
hi("NonText", colors.bright_red, colors.bg)
hi("CursorLine", nil, colors.black_ansi)
hi("Visual", nil, colors.black_ansi)

-- Statusline/Tabline
hi("Pmenu", colors.fg, colors.black_ansi)
hi("TabLineFill", nil, colors.black_ansi, "NONE")
hi("TabLine", "#5d6f92", colors.black_ansi, "NONE")
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
  hi(group, "#f81118")
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

-- Cyan/Blue Group (Bright Cyan/Blue variants)
hi("Function", colors.cyan_func) -- #1081d6

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
  hi(group, colors.cyan_op) -- #0f7ddb
end

return M
