
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

-- Switch between terminal and browser
hs.hotkey.bind({'cmd', 'shift'}, '0', function()
    focusOrLaunch("WezTerm")
end)

-- Use screencapture to copy a screenshot to the clipboard
hs.hotkey.bind({'cmd', 'shift'}, 'C', function()
  hs.task.new("/usr/sbin/screencapture", nil, {"-i", "-c"}):start()
end)
