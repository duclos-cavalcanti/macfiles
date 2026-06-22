local wezterm = require("wezterm")

local utils = require("config.utils")
local colors = require("config.theme").get_colors()

local M = {}

function M.Rename()
    return utils.Prompt('Enter new tab name', function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
    end)
end

function M.Tabline(window, pane)
    local workspace = window:active_workspace()

    -- Workspace indicator on the RIGHT of the tab bar. This is the status area,
    -- not a tab — default tab titles are untouched (no format-tab-title).
    window:set_left_status(wezterm.format({}))
    window:set_right_status(wezterm.format({
      { Foreground = { Color = colors.base08 } },
      { Text = " " .. workspace .. " " },
    }))
end

return M
