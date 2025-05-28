function focusOrLaunchTerminal()
  local app_name = "Terminal"
  local app = hs.application.get(app_name)

  if app then
    app:activate()
  else
    hs.application.launchOrFocus(app_name)
  end
end

function notification(text)
  hs.notify.new({title="Hammerspoon", informativeText=text}):send()
end

hs.hotkey.bind({"cmd"}, "1", function()
  focusOrLaunchTerminal()
end)
