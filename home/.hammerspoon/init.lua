local F = require("functions")

-- Launch
hs.hotkey.bind({'cmd', 'shift'}, '1', function() focusOrLaunch("Wezterm") end)
hs.hotkey.bind({'cmd', 'shift'}, '2', function() focusOrLaunch("Safari") end)

-- Safari: Move to the next tab group
hs.hotkey.bind({"cmd", "ctrl"}, "l", function()
    local app = hs.application.frontmostApplication()
    if app:title() ~= "Safari" then return end
    app:selectMenuItem({"Window", "Go to Next Tab Group"})
end)

-- Safari: Move to the prev tab group
hs.hotkey.bind({"cmd", "ctrl"}, "h", function()
    local app = hs.application.frontmostApplication()
    if app:title() ~= "Safari" then return end
    app:selectMenuItem({"Window", "Go to Previous Tab Group"})
end)

-- Move to next screen
hs.hotkey.bind({"cmd", "ctrl"}, "p", function()
    local currentWindow = hs.window.focusedWindow()
    local screens, currentIndex, nextIndex = getScreens()

    if currentIndex == -1 then return end
    if not currentWindow then return end

    local nextScreen = screens[nextIndex]
    currentWindow:moveToScreen(nextScreen)
end)

-- Fill Window
hs.hotkey.bind({"cmd", "shift"}, "f", function()
    local app = hs.application.frontmostApplication()
    if app then 
        app:selectMenuItem({"Window", "Fill"})
    end
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

-- Screencapture
hs.hotkey.bind({'cmd', 'shift'}, 'C', function()
    hs.task.new("/usr/sbin/screencapture", nil, {"-i", "-c"}):start()
    hs.notify.new({title="Hammerspoon", informativeText="Screenshot!"}):send()
end)
