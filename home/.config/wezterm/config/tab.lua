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
    local user = os.getenv("USER") or "user"

    window:set_left_status(wezterm.format({
      { Foreground = { Color = colors.base08 } },
      { Text = " " .. workspace .. ':' .. " " },
    }))

    window:set_right_status(wezterm.format({
      { Foreground = { Color = colors.base0C } },
      { Text = " " ..  user  .. " " },
    }))
end

return M
