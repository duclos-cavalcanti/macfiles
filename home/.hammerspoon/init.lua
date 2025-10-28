
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

-- Use screencapture to copy a screenshot to the clipboard
hs.hotkey.bind({'cmd', 'shift'}, 'C', function()
  hs.task.new("/usr/sbin/screencapture", nil, {"-i", "-c"}):start()
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

hs.hotkey.bind({"cmd", "ctrl"}, "o", function()
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
    local nextSpace = hs.spaces.activeSpaceOnScreen(nextScreen)

    hs.mouse.setAbsolutePosition(hs.geometry.rectMidPoint(nextScreenFrame))

    local windows = hs.window.orderedWindows()
    for _, window in ipairs(windows) do
        if window:screen():id() == nextScreen:id() and window:isStandard() then
            window:focus()
            break
        end
    end
end)

-- Rule
local zoomWatcher = hs.window.filter.new("Zoom.us")
zoomWatcher:subscribe(hs.window.filter.windowCreated, function(window, appName)
    if not window:isStandard() then
        return
    end

    local app = hs.application.get(appName)
    if not app then return end

    local targetSpaceUUID = nil

    for _, otherWindow in ipairs(app:allWindows()) do
        if otherWindow:isStandard() and otherWindow:id() ~= window:id() then
            targetSpaceUUID = hs.spaces.spaceForWindow(otherWindow)
            if targetSpaceUUID then
                hs.spaces.moveWindowToSpace(window, targetSpaceUUID)
                return
            end
        end
    end
end)
