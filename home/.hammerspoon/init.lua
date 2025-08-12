function focusOrLaunch(app_name)
  local app = hs.application.get(app_name)
  if app then
    app:activate()
  else
    hs.application.launchOrFocus(app_name)
  end
end

function moveMouseToScreen(screen)
  local rect = screen:fullFrame()
  local center = hs.geometry.rectMidPoint(rect)
  hs.mouse.absolutePosition(center)
end

function focusFirstWindowOnScreen(screen)
  local windows = hs.window.orderedWindows()
  for _, win in ipairs(windows) do
    if win:screen() == screen and win:isStandard() and win:isVisible() then
      win:focus()
      return true
    end
  end
  return false
end

function focusWorkspace(screen)
  local didFocus = focusFirstWindowOnScreen(screen)
  moveMouseToScreen(screen)
  return didFocus
end

local toggleAppState = nil
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

function notification(text)
  hs.notify.new({title="Hammerspoon", informativeText=text}):send()
end

-- hs.hotkey.bind({"cmd"}, "0", function()
--   focusOrLaunch('Wezterm')
-- end)
--
-- hs.hotkey.bind({"cmd", "shift"}, "0", function()
--   focusOrLaunch('ChatGPT')
-- end)

hs.hotkey.bind({"cmd"}, "0", function()
  toggleWindows("WezTerm", "Google Chrome")
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
  hs.notify.new({title = "Hammerspoon", informativeText = "Config reloaded"}):send()
end)
