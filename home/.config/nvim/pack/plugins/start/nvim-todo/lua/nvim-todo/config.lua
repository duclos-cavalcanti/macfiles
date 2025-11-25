-- Configuration management for nvim-todo

local M = {}

-- Default configuration
local defaults = {
    -- Storage settings
    storage_path = vim.fn.stdpath("data") .. "/nvim-todo.json",
    auto_save = true,
    
    -- UI settings
    ui = {
        width = 60,
        height = 20,
        border = "rounded",
        title = " Todo List ",
        position = "center", -- center, top, bottom
    },
    
    -- Keybindings (set to false to disable)
    keybindings = {
        toggle_ui = "<leader>tt",
        add_todo = "<leader>ta",
        complete_todo = "<leader>tc",
        delete_todo = "<leader>td",
    },
    
    -- Todo settings
    todo = {
        max_todos = 100,
        show_completed = true,
        auto_archive_completed = false,
        date_format = "%Y-%m-%d %H:%M",
    },
    
    -- Appearance
    highlights = {
        todo_pending = "Normal",
        todo_completed = "Comment",
        todo_priority_high = "ErrorMsg",
        todo_priority_medium = "WarningMsg",
        todo_priority_low = "Directory",
    },
}

-- Current configuration
M.options = {}

-- Setup function to merge user config with defaults
function M.setup(user_config)
    M.options = vim.tbl_deep_extend("force", defaults, user_config or {})
    
    -- Validate configuration
    M.validate()
    
    -- Create storage directory if it doesn't exist
    local storage_dir = vim.fn.fnamemodify(M.options.storage_path, ":h")
    if vim.fn.isdirectory(storage_dir) == 0 then
        vim.fn.mkdir(storage_dir, "p")
    end
end

-- Validate configuration options
function M.validate()
    -- Validate storage path
    if not M.options.storage_path or M.options.storage_path == "" then
        error("nvim-todo: storage_path cannot be empty")
    end
    
    -- Validate UI dimensions
    if M.options.ui.width < 20 or M.options.ui.width > 200 then
        M.options.ui.width = 60
    end
    
    if M.options.ui.height < 5 or M.options.ui.height > 50 then
        M.options.ui.height = 20
    end
    
    -- Validate position
    local valid_positions = { "center", "top", "bottom" }
    if not vim.tbl_contains(valid_positions, M.options.ui.position) then
        M.options.ui.position = "center"
    end
end

-- Get current configuration
function M.get()
    return M.options
end

-- Update configuration at runtime
function M.update(new_config)
    M.options = vim.tbl_deep_extend("force", M.options, new_config)
    M.validate()
end

return M
