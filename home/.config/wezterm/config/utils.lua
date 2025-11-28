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

function M.State()
    local success, stdout = wezterm.run_child_process({ "/opt/homebrew/bin/wezterm", "cli", "list", "--format=json" })
    if success then 
        return wezterm.json_parse(stdout)
    else
        return nil
    end
end

return M
