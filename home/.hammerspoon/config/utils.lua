local M = {}

function M.bind(mods, key, action)
    hs.hotkey.bind(mods, key, function() action() end)
end

return M
