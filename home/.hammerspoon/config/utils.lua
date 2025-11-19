local M = {}

function M.notification(text)
    hs.notify.new({title="Hammerspoon", informativeText=text}):send()
end

function M.bind(mods, key, action)
    hs.hotkey.bind(mods, key, function() action() end)
end

function M.task(program, args)
    hs.task.new(program, nil, args):start()
end

function M.taskWithCallback(program, args, callback)
    hs.task.new(program, callback, args):start()
end

function M.lazy(fn, ...)
    local args = {...}
    return function()
        return fn(table.unpack(args))
    end
end

return M
