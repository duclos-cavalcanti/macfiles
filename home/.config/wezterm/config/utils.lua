local wezterm = require("wezterm")

local M = {}

function M.Prompt(description, callback)
    local action = wezterm.action.PromptInputLine {
        description = description,
        action = wezterm.action_callback(function(window, pane, line)
            callback(window, pane, line) 
        end),
    }
    return action
end

function M.Callback(callback)
    local action = wezterm.action_callack(callback)
    return action
end


return M
