-- Plugin commands and autocommands for nvim-todo
-- This file is automatically loaded by Neovim when the plugin is in the pack path

-- Prevent loading twice
if vim.g.loaded_nvim_todo then
    return
end
vim.g.loaded_nvim_todo = 1

-- Lazy load the plugin modules
local function get_todo()
    return require("nvim-todo")
end

-- Command definitions
vim.api.nvim_create_user_command("TodoAdd", function(opts)
    local todo_plugin = get_todo()
    if opts.args and opts.args ~= "" then
        local success, message = todo_plugin.add_todo(opts.args)
        print(success and "✓ " .. message or "✗ " .. message)
    else
        require("nvim-todo.todo").add_interactive()
    end
end, {
    nargs = "?",
    desc = "Add a new todo item",
})

vim.api.nvim_create_user_command("TodoList", function()
    get_todo().toggle_ui()
end, {
    desc = "Show todo list in floating window",
})

vim.api.nvim_create_user_command("TodoToggle", function()
    get_todo().toggle_ui()
end, {
    desc = "Toggle todo list window",
})

vim.api.nvim_create_user_command("TodoComplete", function(opts)
    local todo_plugin = get_todo()
    if opts.args and opts.args ~= "" then
        local id = tonumber(opts.args)
        if id then
            local success, message = todo_plugin.complete_todo(id)
            print(success and "✓ " .. message or "✗ " .. message)
        else
            print("✗ Invalid todo ID")
        end
    else
        require("nvim-todo.todo").complete_interactive()
    end
end, {
    nargs = "?",
    desc = "Complete a todo item by ID",
})

vim.api.nvim_create_user_command("TodoDelete", function(opts)
    if not opts.args or opts.args == "" then
        print("✗ Please provide a todo ID")
        return
    end
    
    local id = tonumber(opts.args)
    if not id then
        print("✗ Invalid todo ID")
        return
    end
    
    local success, message = get_todo().delete_todo(id)
    print(success and "✓ " .. message or "✗ " .. message)
end, {
    nargs = 1,
    desc = "Delete a todo item by ID",
})

vim.api.nvim_create_user_command("TodoClear", function()
    vim.ui.input({ prompt = "Clear all todos? (y/N): " }, function(input)
        if input and input:lower() == "y" then
            local success, message = require("nvim-todo.todo").clear_all()
            print(success and "✓ " .. message or "✗ " .. message)
        end
    end)
end, {
    desc = "Clear all todos (with confirmation)",
})

vim.api.nvim_create_user_command("TodoSave", function()
    local success, message = require("nvim-todo.todo").save()
    print(success and "✓ " .. message or "✗ " .. message)
end, {
    desc = "Manually save todos to file",
})

vim.api.nvim_create_user_command("TodoInfo", function()
    local storage = require("nvim-todo.storage")
    local info = storage.get_info()
    local todos = require("nvim-todo.todo").list()
    local pending = require("nvim-todo.todo").get_pending()
    local completed = require("nvim-todo.todo").get_completed()
    
    print("=== Todo Info ===")
    print("Storage path: " .. info.path)
    print("File exists: " .. (info.exists and "Yes" or "No"))
    if info.exists then
        print("File size: " .. info.size .. " bytes")
        print("Last modified: " .. (info.modified or "Unknown"))
    end
    print("Total todos: " .. #todos)
    print("Pending: " .. #pending)
    print("Completed: " .. #completed)
end, {
    desc = "Show todo plugin information",
})

-- Autocommands
local augroup = vim.api.nvim_create_augroup("NvimTodo", { clear = true })

-- Auto-save on VimLeavePre
vim.api.nvim_create_autocmd("VimLeavePre", {
    group = augroup,
    callback = function()
        -- Only save if the plugin has been loaded
        if package.loaded["nvim-todo.todo"] then
            require("nvim-todo.todo").save()
        end
    end,
    desc = "Auto-save todos on Vim exit",
})

-- Set up filetype for todo files
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "nvim-todo",
    callback = function()
        -- Set buffer-local options for todo UI
        vim.opt_local.wrap = false
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
        vim.opt_local.foldcolumn = "0"
        vim.opt_local.colorcolumn = ""
    end,
    desc = "Set options for nvim-todo buffers",
})

-- Optional: Set up highlights if not already defined
vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    callback = function()
        -- Define default highlights if they don't exist
        local highlights = {
            todo_pending = "Normal",
            todo_completed = "Comment",
            todo_priority_high = "ErrorMsg",
            todo_priority_medium = "WarningMsg", 
            todo_priority_low = "Directory",
        }
        
        for name, link in pairs(highlights) do
            if vim.fn.hlexists(name) == 0 then
                vim.api.nvim_set_hl(0, name, { link = link })
            end
        end
    end,
    desc = "Set up todo highlights",
})
