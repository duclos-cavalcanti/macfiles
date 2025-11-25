-- nvim-todo: A simple todo plugin for Neovim
-- Main entry point for the plugin

local config = require("nvim-todo.config")
local todo = require("nvim-todo.todo")
local ui = require("nvim-todo.ui")

local M = {}

-- Plugin setup function
function M.setup(opts)
    -- Merge user options with defaults
    config.setup(opts or {})
    
    -- Initialize storage
    todo.init()
    
    -- Set up keybindings if configured
    if config.options.keybindings then
        M.setup_keybindings()
    end
    
    print("nvim-todo loaded successfully!")
end

-- Set up keybindings
function M.setup_keybindings()
    local opts = { noremap = true, silent = true }
    local kb = config.options.keybindings
    
    if kb.toggle_ui then
        vim.keymap.set('n', kb.toggle_ui, ui.toggle, opts)
    end
    
    if kb.add_todo then
        vim.keymap.set('n', kb.add_todo, todo.add_interactive, opts)
    end
    
    if kb.complete_todo then
        vim.keymap.set('n', kb.complete_todo, todo.complete_interactive, opts)
    end
end

-- Expose main functions
M.add_todo = todo.add
M.list_todos = todo.list
M.complete_todo = todo.complete
M.delete_todo = todo.delete
M.toggle_ui = ui.toggle
M.show_ui = ui.show
M.hide_ui = ui.hide

return M
