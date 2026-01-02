local config = require("config")

local apps   = config.apps
local ctrl   = config.ctrl
local screen = config.screen
local utils  = config.utils
local bind   = utils.bind
local task   = utils.task
local lazy   = utils.lazy

local terminal="Wezterm"
local browser="Safari"

bind({"cmd", "shift"},      "p",        screen.FocusNextScreen)
bind({"cmd", "ctrl"},       "p",        screen.MoveToNextScreen)
bind({"cmd", "shift"},      "f",        ctrl.fillWindow)
bind({"cmd", "shift"},      "Left",     ctrl.MoveWindowLeft)
bind({"cmd", "shift"},      "Up",       ctrl.MoveWindowTop)
bind({"cmd", "shift"},      "Down",     ctrl.MoveWindowBottom)
bind({"cmd", "shift"},      "Right",    ctrl.MoveWindowRight)
bind({"cmd", "ctrl"},       "h",        apps.SafariMoveToPreviousTabGroup)
bind({"cmd", "ctrl"},       "l",        apps.SafariMoveToNextTabGroup)
bind({"cmd", "shift"},      "c",        lazy(task, "/usr/sbin/screencapture", {"-i", "-c"}))
bind({"cmd"},               "0",        lazy(apps.focusOrLaunchApp, terminal))
bind({"cmd"},               "1",        lazy(apps.focusOrLaunchApp, browser))
