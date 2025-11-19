local config = require("config")

local utils  = config.utils
local apps   = config.apps
local screen = config.screen

-- Launch
hs.hotkey.bind({'cmd', 'shift'}, '1', function() focusOrLaunch("Wezterm") end)
hs.hotkey.bind({'cmd', 'shift'}, '2', function() focusOrLaunch("Safari") end)

utils.bind({"cmd", "shift"},    "p",    screen.FocusNextScreen)
utils.bind({"cmd", "ctrl"},     "p",    screen.MoveToNextScreen)
utils.bind({"cmd", "ctrl"},     "h",    apps.SafariMoveToPreviousTabGroup)
utils.bind({"cmd", "ctrl"},     "l",    apps.SafariMoveToNextTabGroup)
utils.bind({"cmd", "shift"},    "f",    apps.fillWindowApp)
utils.bind({"cmd", "shift"},    "c",    utils.lazy(utils.task, "/usr/sbin/screencapture", {"-i", "-c"}))
