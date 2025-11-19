local M = {}

function M.focusOrLaunchApp(name)
    local app = hs.application.get(name)
    if app then app:activate()
    else        hs.application.launchOrFocus(name)
    end
end

function M.fillWindowApp()
    local app = hs.application.frontmostApplication()
    if app then 
        app:selectMenuItem({"Window", "Fill"})
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
