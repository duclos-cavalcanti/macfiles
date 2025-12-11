local M = {}

function M.fillWindow()
    local app = hs.application.frontmostApplication()
    if app then
        app:selectMenuItem({"Window", "Fill"})
    end
end

function M.MoveWindowLeft()
    local app = hs.application.frontmostApplication()
    if app then
        app:selectMenuItem({"Window", "Move & Resize", "Left"})
    end
end

function M.MoveWindowRight()
    local app = hs.application.frontmostApplication()
    if app then
        app:selectMenuItem({"Window", "Move & Resize", "Right"})
    end
end

function M.MoveWindowTop()
    local app = hs.application.frontmostApplication()
    if app then
        app:selectMenuItem({"Window", "Move & Resize", "Top"})
    end
end

function M.MoveWindowBottom()
    local app = hs.application.frontmostApplication()
    if app then
        app:selectMenuItem({"Window", "Move & Resize", "Bottom"})
    end
end

return M
