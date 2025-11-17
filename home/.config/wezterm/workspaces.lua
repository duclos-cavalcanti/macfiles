local wezterm = require("wezterm")

local M = {}

-- Define our custom workspaces
local custom_workspaces = {
    {
        id = "macfiles",
        label = "macfiles - ~/Documents/macfiles",
        cwd = wezterm.home_dir .. "/Documents/macfiles",
    },
    {
        id = "vault", 
        label = "vault - ~/Documents/work/vault-releases",
        cwd = wezterm.home_dir .. "/Documents/work/vault-releases",
    },
    {
        id = "notes",
        label = "notes - ~/Documents/notes", 
        cwd = wezterm.home_dir .. "/Documents/notes",
    },
}

-- Get choices for the workspace switcher
function M.list()
    local choices = {}
    
    -- Add our custom workspace definitions
    for _, workspace in ipairs(custom_workspaces) do
        table.insert(choices, {
            id = workspace.id,
            label = workspace.label,
        })
    end
    
    return choices
end

-- Macfiles workspace function
function M.macfiles()
    return wezterm.action.SwitchToWorkspace({
        name = "macfiles",
        spawn = {
            cwd = wezterm.home_dir .. "/Documents/macfiles",
        },
    })
end

return M
