local config = require("config")

local apps   = config.apps
local screen = config.screen
local utils  = config.utils
local bind   = utils.bind
local task   = utils.task
local lazy   = utils.lazy

local terminal="WezTerm"
local browser="Safari"

bind({"cmd"},               "0",        lazy(apps.focusBetweenApps, terminal, browser))
bind({"cmd", "shift"},      "c",        lazy(task, "/usr/sbin/screencapture", {"-i", "-c"}))
bind({"cmd", "shift"},      "p",        screen.FocusNextScreen)
bind({"cmd", "ctrl"},       "p",        screen.MoveToNextScreen)
bind({"cmd", "ctrl"},       "h",        apps.SafariMoveToPreviousTabGroup)
bind({"cmd", "ctrl"},       "l",        apps.SafariMoveToNextTabGroup)
