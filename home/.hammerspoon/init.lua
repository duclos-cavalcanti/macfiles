
function notification(text)
  hs.notify.new({title="Hammerspoon", informativeText=text}):send()
end

function getScreens()
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

-- Move to next screen
hs.hotkey.bind({"cmd", "ctrl"}, "p", function()
    local currentWindow = hs.window.focusedWindow()
    local screens, currentIndex, nextIndex = getScreens()

    if currentIndex == -1 then return end
    if not currentWindow then return end

    local nextScreen = screens[nextIndex]
    currentWindow:moveToScreen(nextScreen)
end)

-- Focus on next screen
hs.hotkey.bind({"cmd", "shift"}, "p", function()
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
end)

-- Fill Window
hs.hotkey.bind({"cmd", "shift"}, "f", function()
    app:selectMenuItem({"Window", "Fill"})
end)

-- Screencapture
hs.hotkey.bind({'cmd', 'shift'}, 'C', function()
    hs.task.new("/usr/sbin/screencapture", nil, {"-i", "-c"}):start()
    hs.notify.new({title="Hammerspoon", informativeText="Screenshot!"}):send()
end)
