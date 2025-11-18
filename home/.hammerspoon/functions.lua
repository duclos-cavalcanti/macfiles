local M = {}

function M.notification(text)
  hs.notify.new({title="Hammerspoon", informativeText=text}):send()
end

function M.getScreens()
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


return M
