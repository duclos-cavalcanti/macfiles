local M = {}

local function getScreens()
    local screens = hs.screen.allScreens()
    if #screens <= 1 then 
        return screens, -1, -1
    end

    local currentScreen = hs.mouse.getCurrentScreen()
    local currentIndex = 1

    for i, screen in ipairs(screens) do
        if screen:id() == currentScreen:id() then
            currentIndex = i
            break
        end
    end

    local nextIndex = (currentIndex % #screens) + 1
    return screens, currentIndex, nextIndex
end

function M.FocusNextScreen()
    local screens, currentIndex, nextIndex = getScreens()

    if currentIndex == -1 then return end

    local nextScreen = screens[nextIndex]
    local nextScreenFrame = nextScreen:frame()

    hs.mouse.absolutePosition(hs.geometry.rectMidPoint(nextScreenFrame))

    local windows = hs.window.orderedWindows()
    for _, window in ipairs(windows) do
        if window:screen():id() == nextScreen:id() and window:isStandard() then
            window:focus()
            break
        end
    end
end

return M
