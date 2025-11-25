-- Core todo functionality for nvim-todo

local config = require("nvim-todo.config")
local storage = require("nvim-todo.storage")

local M = {}

-- Todo item structure:
-- {
--   id = unique_id,
--   text = "todo text",
--   completed = false,
--   priority = "medium", -- low, medium, high
--   created_at = timestamp,
--   completed_at = timestamp or nil,
-- }

-- Internal todo list
local todos = {}
local next_id = 1

-- Initialize the todo system
function M.init()
    todos = storage.load() or {}
    
    -- Find the next available ID
    next_id = 1
    for _, todo in ipairs(todos) do
        if todo.id >= next_id then
            next_id = todo.id + 1
        end
    end
end

-- Add a new todo
function M.add(text, priority)
    if not text or text:match("^%s*$") then
        return false, "Todo text cannot be empty"
    end
    
    priority = priority or "medium"
    local valid_priorities = { "low", "medium", "high" }
    if not vim.tbl_contains(valid_priorities, priority) then
        priority = "medium"
    end
    
    local todo = {
        id = next_id,
        text = text,
        completed = false,
        priority = priority,
        created_at = os.time(),
        completed_at = nil,
    }
    
    table.insert(todos, todo)
    next_id = next_id + 1
    
    -- Auto-save if enabled
    if config.get().auto_save then
        storage.save(todos)
    end
    
    return true, "Todo added successfully"
end

-- Interactive add todo (prompts user for input)
function M.add_interactive()
    vim.ui.input({ prompt = "Enter todo: " }, function(text)
        if text then
            local success, message = M.add(text)
            if success then
                print("✓ " .. message)
            else
                print("✗ " .. message)
            end
        end
    end)
end

-- Complete a todo by ID
function M.complete(id)
    for i, todo in ipairs(todos) do
        if todo.id == id then
            if todo.completed then
                return false, "Todo is already completed"
            end
            
            todos[i].completed = true
            todos[i].completed_at = os.time()
            
            -- Auto-save if enabled
            if config.get().auto_save then
                storage.save(todos)
            end
            
            return true, "Todo completed"
        end
    end
    
    return false, "Todo not found"
end

-- Interactive complete todo (shows list to choose from)
function M.complete_interactive()
    local pending_todos = M.get_pending()
    
    if #pending_todos == 0 then
        print("No pending todos to complete")
        return
    end
    
    local items = {}
    for _, todo in ipairs(pending_todos) do
        table.insert(items, string.format("[%d] %s", todo.id, todo.text))
    end
    
    vim.ui.select(items, { prompt = "Select todo to complete:" }, function(choice)
        if choice then
            local id = tonumber(choice:match("%[(%d+)%]"))
            if id then
                local success, message = M.complete(id)
                print(success and "✓ " .. message or "✗ " .. message)
            end
        end
    end)
end

-- Delete a todo by ID
function M.delete(id)
    for i, todo in ipairs(todos) do
        if todo.id == id then
            table.remove(todos, i)
            
            -- Auto-save if enabled
            if config.get().auto_save then
                storage.save(todos)
            end
            
            return true, "Todo deleted"
        end
    end
    
    return false, "Todo not found"
end

-- Get all todos
function M.list()
    return todos
end

-- Get pending todos only
function M.get_pending()
    local pending = {}
    for _, todo in ipairs(todos) do
        if not todo.completed then
            table.insert(pending, todo)
        end
    end
    return pending
end

-- Get completed todos only
function M.get_completed()
    local completed = {}
    for _, todo in ipairs(todos) do
        if todo.completed then
            table.insert(completed, todo)
        end
    end
    return completed
end

-- Save todos manually
function M.save()
    return storage.save(todos)
end

-- Clear all todos
function M.clear_all()
    todos = {}
    next_id = 1
    
    if config.get().auto_save then
        storage.save(todos)
    end
    
    return true, "All todos cleared"
end

return M
