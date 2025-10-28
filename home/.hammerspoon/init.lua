
function notification(text)
  hs.notify.new({title="Hammerspoon", informativeText=text}):send()
end

function focusOrLaunch(app_name)
    local app = hs.application.get(app_name)
    if app then
        app:activate()
    else
        hs.application.launchOrFocus(app_name)
  end
end

hs.hotkey.bind({"cmd", "shift"}, "1", function()
    local currentWindow = hs.window.focusedWindow()
    if not currentWindow then return end
    hs.spaces.moveWindowToSpace(currentWindow, 1)
end)

hs.hotkey.bind({"cmd", "shift"}, "2", function()
    local currentWindow = hs.window.focusedWindow()
    if not currentWindow then return end
    hs.spaces.moveWindowToSpace(currentWindow, 2)
end)

hs.hotkey.bind({"cmd", "shift"}, "3", function()
    local currentWindow = hs.window.focusedWindow()
    if not currentWindow then return end
    hs.spaces.moveWindowToSpace(currentWindow, 3)
end)

hs.hotkey.bind({"cmd", "shift"}, "4", function()
    local currentWindow = hs.window.focusedWindow()
    if not currentWindow then return end
    hs.spaces.moveWindowToSpace(currentWindow, 4)
end)

-- Safari: Move to the next tab group
hs.hotkey.bind({"cmd", "ctrl"}, "k", function()
    local app = hs.application.frontmostApplication()
    if app:title() ~= "Safari" then return end
    app:selectMenuItem({"Window", "Go to Next Tab Group"})
end)

-- Safari: Move to the prev tab group
hs.hotkey.bind({"cmd", "ctrl"}, "j", function()
    local app = hs.application.frontmostApplication()
    if app:title() ~= "Safari" then return end
    app:selectMenuItem({"Window", "Go to Previous Tab Group"})
end)

hs.hotkey.bind({"cmd", "ctrl"}, "p", function()
    local screens = hs.screen.allScreens()
    if #screens <= 1 then 
        return
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

hs.hotkey.bind({"cmd", "shift"}, "p", function()
    local screens = hs.screen.allScreens()
    if #screens <= 1 then return end

    local currentWindow = hs.window.focusedWindow()
    if not currentWindow then return end

    local currentScreen = currentWindow:screen()
    local currentIndex = 1

    for i, screen in ipairs(screens) do
        if screen:id() == currentScreen:id() then
            currentIndex = i
            break
        end
    end

    local nextIndex = (currentIndex % #screens) + 1
    local nextScreen = screens[nextIndex]

    currentWindow:moveToScreen(nextScreen)
end)

-- Use screencapture to copy a screenshot to the clipboard
hs.hotkey.bind({'cmd', 'shift'}, 'C', function()
    hs.task.new("/usr/sbin/screencapture", nil, {"-i", "-c"}):start()
end)
