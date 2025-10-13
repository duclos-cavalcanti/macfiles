
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

-- Terminal: Focus or Launch
hs.hotkey.bind({'cmd', 'shift'}, '0', function()
    focusOrLaunch("Terminal")
end)

-- Safari: Move to the next tab group
hs.hotkey.bind({"cmd", "ctrl"}, "l", function()
    local app = hs.application.frontmostApplication()
    if app:title() == "Safari" then
        app:selectMenuItem({"Window", "Go to Next Tab Group"})
    end
end)

-- Safari: Move to the prev tab group
hs.hotkey.bind({"cmd", "ctrl"}, "h", function()
    local app = hs.application.frontmostApplication()
    if app:title() == "Safari" then
        app:selectMenuItem({"Window", "Go to Previous Tab Group"})
    end
end)

-- Use screencapture to copy a screenshot to the clipboard
hs.hotkey.bind({'cmd', 'shift'}, 'C', function()
  hs.task.new("/usr/sbin/screencapture", nil, {"-i", "-c"}):start()
end)
