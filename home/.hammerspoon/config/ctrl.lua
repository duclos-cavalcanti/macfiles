local M = {}

function M.fillWindow()
    local app = hs.application.frontmostApplication()
    if app then 
        app:selectMenuItem({"Window", "Fill"})
    end
end

return M
