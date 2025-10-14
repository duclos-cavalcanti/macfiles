
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

-- Terminal: Focus or Launch
hs.hotkey.bind({'cmd', 'shift'}, '1', function()
    focusOrLaunch("Terminal")
end)

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

-- Move the current Safari tab to the left
hs.hotkey.bind({"cmd", "ctrl"}, "[", function()
    local app = hs.application.frontmostApplication()
    if app:title() ~= "Safari" then return end
    local moveTabScript = [[
        tell application "Safari"
            if not (exists front window) then return
            tell front window
                set currentTabIndex to index of current tab
                if currentTabIndex > 1 then
                    move current tab to before tab (currentTabIndex - 1)
                end if
            end tell
        end tell
    ]]
    hs.osascript.applescript(moveTabScript)
end)

-- Move the current Safari tab to the right
hs.hotkey.bind({"cmd", "ctrl"}, "]", function()
    local app = hs.application.frontmostApplication()
    if app:title() == "Safari" then
        local moveTabScript = [[
            tell application "Safari"
                if not (exists front window) then return
                tell front window
                    set tabCount to count of tabs
                    set currentTabIndex to index of current tab
                    if currentTabIndex < tabCount then
                        move current tab to after tab (currentTabIndex)
                    end if
                end tell
            end tell
        ]]
        hs.osascript.applescript(moveTabScript)
    end
end)
