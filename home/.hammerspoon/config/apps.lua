local M = {}

local utils = require("config.utils")

function M.focusBetweenApps(name_a, name_b)
    local app = hs.application.frontmostApplication()
    local title = string.lower(app:title())

    name_a = string.lower(name_a)
    name_b = string.lower(name_b)

    if title == name_a then
        M.focusOrLaunchApp(name_b)
        return
    end

    if title == name_b then
        M.focusOrLaunchApp(name_a)
        return
    end

    M.focusOrLaunchApp(name_a)
end

function M.focusOrLaunchApp(name)
    local app = hs.application.get(name)
    if app then app:activate()
    else        hs.application.launchOrFocus(name)
    end
end

function M.SafariMoveToNextTabGroup()
    local app = hs.application.frontmostApplication()
    if app:title() ~= "Safari" then
        return
    end
    app:selectMenuItem({"Window", "Go to Next Tab Group"})
end

function M.SafariMoveToPreviousTabGroup()
    local app = hs.application.frontmostApplication()
    if app:title() ~= "Safari" then
        return
    end
    app:selectMenuItem({"Window", "Go to Previous Tab Group"})
end

return M
