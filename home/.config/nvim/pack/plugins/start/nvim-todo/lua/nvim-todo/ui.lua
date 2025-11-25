-- UI components for nvim-todo

local config = require("nvim-todo.config")
local todo = require("nvim-todo.todo")

local M = {}

-- UI state
local ui_state = {
    buf = nil,
    win = nil,
    is_open = false,
}

-- Create the floating window
function M.create_window()
    local opts = config.get().ui
    
    -- Calculate window position
    local width = opts.width
    local height = opts.height
    local ui_width = vim.o.columns
    local ui_height = vim.o.lines
    
    local row, col
    if opts.position == "center" then
        row = math.floor((ui_height - height) / 2)
        col = math.floor((ui_width - width) / 2)
    elseif opts.position == "top" then
        row = 2
        col = math.floor((ui_width - width) / 2)
    elseif opts.position == "bottom" then
        row = ui_height - height - 3
        col = math.floor((ui_width - width) / 2)
    end
    
    -- Create buffer
    local buf = vim.api.nvim_create_buf(false, true)
    
    -- Window options
    local win_opts = {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = opts.border,
        title = opts.title,
        title_pos = "center",
        style = "minimal",
    }
    
    -- Create window
    local win = vim.api.nvim_open_win(buf, true, win_opts)
    
    -- Set buffer options
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "filetype", "nvim-todo")
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    
    -- Set window options
    vim.api.nvim_win_set_option(win, "wrap", false)
    vim.api.nvim_win_set_option(win, "cursorline", true)
    
    return buf, win
end

-- Render todos in the buffer
function M.render_todos()
    if not ui_state.buf or not vim.api.nvim_buf_is_valid(ui_state.buf) then
        return
    end
    
    local todos = todo.list()
    local lines = {}
    local highlights = {}
    
    -- Header
    table.insert(lines, "Todo List")
    table.insert(lines, string.rep("─", config.get().ui.width - 4))
    table.insert(lines, "")
    
    if #todos == 0 then
        table.insert(lines, "  No todos yet. Press 'a' to add one!")
    else
        -- Group todos by status
        local pending = todo.get_pending()
        local completed = todo.get_completed()
        
        -- Show pending todos
        if #pending > 0 then
            table.insert(lines, "📋 Pending (" .. #pending .. ")")
            table.insert(lines, "")
            
            for _, t in ipairs(pending) do
                local priority_icon = M.get_priority_icon(t.priority)
                local line = string.format("  %s [%d] %s", priority_icon, t.id, t.text)
                table.insert(lines, line)
                
                -- Add highlight for priority
                local hl_group = "todo_priority_" .. t.priority
                table.insert(highlights, {
                    line = #lines - 1,
                    col_start = 2,
                    col_end = 4,
                    hl_group = hl_group
                })
            end
            
            table.insert(lines, "")
        end
        
        -- Show completed todos if enabled
        if config.get().todo.show_completed and #completed > 0 then
            table.insert(lines, "✅ Completed (" .. #completed .. ")")
            table.insert(lines, "")
            
            for _, t in ipairs(completed) do
                local line = string.format("  ✓ [%d] %s", t.id, t.text)
                table.insert(lines, line)
                
                -- Add highlight for completed
                table.insert(highlights, {
                    line = #lines - 1,
                    col_start = 0,
                    col_end = -1,
                    hl_group = "todo_completed"
                })
            end
        end
    end
    
    -- Add help text
    table.insert(lines, "")
    table.insert(lines, string.rep("─", config.get().ui.width - 4))
    table.insert(lines, "Keys: a=add, d=delete, <CR>=toggle, q=quit")
    
    -- Set buffer content
    vim.api.nvim_buf_set_option(ui_state.buf, "modifiable", true)
    vim.api.nvim_buf_set_lines(ui_state.buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(ui_state.buf, "modifiable", false)
    
    -- Apply highlights
    for _, hl in ipairs(highlights) do
        vim.api.nvim_buf_add_highlight(
            ui_state.buf,
            -1,
            config.get().highlights[hl.hl_group] or hl.hl_group,
            hl.line,
            hl.col_start,
            hl.col_end
        )
    end
end

-- Get priority icon
function M.get_priority_icon(priority)
    local icons = {
        high = "🔴",
        medium = "🟡",
        low = "🟢",
    }
    return icons[priority] or "⚪"
end

-- Set up buffer keymaps
function M.setup_keymaps()
    if not ui_state.buf then return end
    
    local opts = { buffer = ui_state.buf, noremap = true, silent = true }
    
    -- Close window
    vim.keymap.set('n', 'q', M.hide, opts)
    vim.keymap.set('n', '<Esc>', M.hide, opts)
    
    -- Add todo
    vim.keymap.set('n', 'a', function()
        M.hide()
        todo.add_interactive()
        vim.defer_fn(function()
            if ui_state.is_open then
                M.render_todos()
            end
        end, 100)
    end, opts)
    
    -- Toggle todo completion
    vim.keymap.set('n', '<CR>', function()
        local line = vim.api.nvim_win_get_cursor(ui_state.win)[1]
        local content = vim.api.nvim_buf_get_lines(ui_state.buf, line - 1, line, false)[1]
        local id = content:match("%[(%d+)%]")
        
        if id then
            todo.complete(tonumber(id))
            M.render_todos()
        end
    end, opts)
end

-- Show the UI
function M.show()
    if ui_state.is_open then
        return
    end
    
    ui_state.buf, ui_state.win = M.create_window()
    ui_state.is_open = true
    
    M.setup_keymaps()
    M.render_todos()
    
    -- Auto-close on buffer leave
    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = ui_state.buf,
        once = true,
        callback = M.hide,
    })
end

-- Hide the UI
function M.hide()
    if ui_state.win and vim.api.nvim_win_is_valid(ui_state.win) then
        vim.api.nvim_win_close(ui_state.win, true)
    end
    
    ui_state.buf = nil
    ui_state.win = nil
    ui_state.is_open = false
end

-- Toggle the UI
function M.toggle()
    if ui_state.is_open then
        M.hide()
    else
        M.show()
    end
end

return M
