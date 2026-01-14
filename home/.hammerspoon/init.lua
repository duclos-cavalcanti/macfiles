local config = require("config")

local apps   = config.apps
local screen = config.screen
local utils  = config.utils
local bind   = utils.bind
local task   = utils.task
local lazy   = utils.lazy

local terminal="WezTerm"
local browser="Safari"
local slack="Slack"
local postman="Postman"

bind({"cmd"},               "0",        lazy(apps.focusOrLaunchApp, terminal))
bind({"cmd"},               "1",        lazy(apps.focusOrLaunchApp, browser))
bind({"cmd"},               "2",        lazy(apps.focusOrLaunchApp, slack))
bind({"cmd"},               "3",        lazy(apps.focusOrLaunchApp, postman))

bind({"cmd", "shift"},      "c",        lazy(task, "/usr/sbin/screencapture", {"-i", "-c"}))
bind({"cmd", "shift"},      "p",        screen.FocusNextScreen)
bind({"cmd", "ctrl"},       "p",        screen.MoveToNextScreen)
bind({"cmd", "ctrl"},       "h",        lazy(apps.executeOnApp, "Safari", function(app) app:selectMenuItem({"Window", "Go to Previous Tab Group"}) end))
bind({"cmd", "ctrl"},       "l",        lazy(apps.executeOnApp, "Safari", function(app) app:selectMenuItem({"Window", "Go to Next Tab Group"}) end))
