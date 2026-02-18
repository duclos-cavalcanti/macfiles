local config = require("config")

local apps   = config.apps
local screen = config.screen
local utils  = config.utils

local bind   = utils.bind
local task   = utils.task
local lazy   = utils.lazy

bind({"cmd", "shift"},      "c",        lazy(task, "/usr/sbin/screencapture", {"-i", "-c"}))

bind({"cmd", "shift"},      "p",        screen.FocusNextScreen)
bind({"cmd", "ctrl"},       "p",        screen.MoveToNextScreen)

bind({"cmd", "ctrl"},       "f",        lazy(apps.executeOnApp, function(app) app:selectMenuItem({"Window", "Fill"}) end))

bind({"cmd", "ctrl"},       "h",        lazy(apps.executeOnTitle, "Safari", function(app) app:selectMenuItem({"Window", "Go to Previous Tab Group"}) end))
bind({"cmd", "ctrl"},       "l",        lazy(apps.executeOnTitle, "Safari", function(app) app:selectMenuItem({"Window", "Go to Next Tab Group"}) end))
