local config = require("config")

local apps   = config.apps
local ctrl   = config.ctrl
local screen = config.screen
local utils  = config.utils
local bind   = utils.bind
local task   = utils.task
local lazy   = utils.lazy

bind({"cmd", "shift"},    "p",    screen.FocusNextScreen)
bind({"cmd", "ctrl"},     "p",    screen.MoveToNextScreen)
bind({"cmd", "shift"},    "f",    ctrl.fillWindow)
bind({"cmd", "shift"},    "h",    ctrl.MoveWindowLeft)
bind({"cmd", "shift"},    "k",    ctrl.MoveWindowTop)
bind({"cmd", "shift"},    "j",    ctrl.MoveWindowBottom)
bind({"cmd", "shift"},    "l",    ctrl.MoveWindowRight)
bind({"cmd", "ctrl"},     "h",    apps.SafariMoveToPreviousTabGroup)
bind({"cmd", "ctrl"},     "l",    apps.SafariMoveToNextTabGroup)
bind({"cmd", "shift"},    "c",    lazy(task, "/usr/sbin/screencapture", {"-i", "-c"}))
