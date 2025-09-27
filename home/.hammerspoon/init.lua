local toggleAppState = nil

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

function toggleWindows(option_a, option_b)
    local frontmostApp = hs.application.frontmostApplication()
    local frontmostAppName = frontmostApp:name()
    -- hs.notify.new({title = "Hammerspoon", informativeText = "Name " .. frontmostAppName}):send()

    if frontmostAppName == option_a then
        focusOrLaunch(option_b)
        toggleAppState = option_b
    elseif frontmostAppName == option_b then
        focusOrLaunch(option_a)
        toggleAppState = option_a
    else
        if toggleAppState ~= nil then
            focusOrLaunch(toggleAppState)
        else
            focusOrLaunch(option_a)
            toggleAppState = option_a
        end
    end
end

-- Switch between terminal and browser
hs.hotkey.bind({"cmd"}, "0", function()
  toggleWindows("WezTerm", "Google Chrome")
end)

-- Use screencapture to copy a screenshot to the clipboard
hs.hotkey.bind({'cmd', 'shift'}, 'C', function()
  hs.task.new("/usr/sbin/screencapture", nil, {"-i", "-c"}):start()
end)
