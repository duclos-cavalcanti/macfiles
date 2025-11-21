local wezterm = require("wezterm")

local M = {}

function M.Prompt(description, callback)
    local action = wezterm.action.PromptInputLine {
        description = description,
        action = wezterm.action_callback(function(window, pane, line)
            if line then
                callback(window, pane, line)
            end
        end),
    }
    return action
end

return M
