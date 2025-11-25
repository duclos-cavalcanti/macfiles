-- Storage functionality for nvim-todo
-- Handles saving and loading todos to/from JSON file

local config = require("nvim-todo.config")

local M = {}

-- Save todos to file
function M.save(todos)
    local storage_path = config.get().storage_path
    
    if not storage_path then
        return false, "No storage path configured"
    end
    
    -- Ensure directory exists
    local dir = vim.fn.fnamemodify(storage_path, ":h")
    if vim.fn.isdirectory(dir) == 0 then
        local success = vim.fn.mkdir(dir, "p")
        if success == 0 then
            return false, "Failed to create storage directory: " .. dir
        end
    end
    
    -- Convert todos to JSON
    local json_data = vim.fn.json_encode(todos or {})
    if not json_data then
        return false, "Failed to encode todos to JSON"
    end
    
    -- Write to file
    local file = io.open(storage_path, "w")
    if not file then
        return false, "Failed to open file for writing: " .. storage_path
    end
    
    file:write(json_data)
    file:close()
    
    return true, "Todos saved successfully"
end

-- Load todos from file
function M.load()
    local storage_path = config.get().storage_path
    
    if not storage_path then
        return {}
    end
    
    -- Check if file exists
    if vim.fn.filereadable(storage_path) == 0 then
        return {}
    end
    
    -- Read file
    local file = io.open(storage_path, "r")
    if not file then
        vim.notify("Failed to open todos file: " .. storage_path, vim.log.levels.WARN)
        return {}
    end
    
    local content = file:read("*all")
    file:close()
    
    if not content or content == "" then
        return {}
    end
    
    -- Parse JSON
    local success, todos = pcall(vim.fn.json_decode, content)
    if not success then
        vim.notify("Failed to parse todos file: " .. storage_path, vim.log.levels.ERROR)
        return {}
    end
    
    -- Validate and sanitize loaded data
    return M.validate_todos(todos or {})
end

-- Validate and sanitize loaded todos
function M.validate_todos(todos)
    if type(todos) ~= "table" then
        return {}
    end
    
    local valid_todos = {}
    
    for _, todo in ipairs(todos) do
        if M.is_valid_todo(todo) then
            table.insert(valid_todos, todo)
        end
    end
    
    return valid_todos
end

-- Check if a todo item is valid
function M.is_valid_todo(todo)
    if type(todo) ~= "table" then
        return false
    end
    
    -- Required fields
    if not todo.id or type(todo.id) ~= "number" then
        return false
    end
    
    if not todo.text or type(todo.text) ~= "string" or todo.text == "" then
        return false
    end
    
    if todo.completed == nil or type(todo.completed) ~= "boolean" then
        return false
    end
    
    if not todo.created_at or type(todo.created_at) ~= "number" then
        return false
    end
    
    -- Optional fields with defaults
    if not todo.priority then
        todo.priority = "medium"
    end
    
    local valid_priorities = { "low", "medium", "high" }
    if not vim.tbl_contains(valid_priorities, todo.priority) then
        todo.priority = "medium"
    end
    
    -- Validate completed_at if present
    if todo.completed_at and type(todo.completed_at) ~= "number" then
        todo.completed_at = nil
    end
    
    return true
end

-- Create backup of current todos file
function M.backup()
    local storage_path = config.get().storage_path
    
    if vim.fn.filereadable(storage_path) == 0 then
        return false, "No todos file to backup"
    end
    
    local backup_path = storage_path .. ".backup." .. os.date("%Y%m%d_%H%M%S")
    
    -- Copy file
    local success = vim.fn.system(string.format("cp '%s' '%s'", storage_path, backup_path))
    if vim.v.shell_error ~= 0 then
        return false, "Failed to create backup"
    end
    
    return true, "Backup created: " .. backup_path
end

-- Get storage file info
function M.get_info()
    local storage_path = config.get().storage_path
    
    local info = {
        path = storage_path,
        exists = vim.fn.filereadable(storage_path) == 1,
        size = 0,
        modified = nil,
    }
    
    if info.exists then
        local stat = vim.loop.fs_stat(storage_path)
        if stat then
            info.size = stat.size
            info.modified = os.date("%Y-%m-%d %H:%M:%S", stat.mtime.sec)
        end
    end
    
    return info
end

-- Clear storage file
function M.clear()
    local storage_path = config.get().storage_path
    
    if vim.fn.filereadable(storage_path) == 0 then
        return true, "No file to clear"
    end
    
    -- Create backup first
    local backup_success, backup_msg = M.backup()
    if not backup_success then
        return false, "Failed to backup before clearing: " .. backup_msg
    end
    
    -- Remove file
    local success = os.remove(storage_path)
    if not success then
        return false, "Failed to remove storage file"
    end
    
    return true, "Storage cleared (backup created)"
end

return M
