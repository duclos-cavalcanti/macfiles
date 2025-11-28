local M = {
    options = {},
}

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
        title = " Notebook ",
        position = "center",
    },
}

function M.setup(user_config)
    M.options = vim.tbl_deep_extend("force", defaults, user_config or {})
    
    M.validate()
    
    local storage_dir = vim.fn.fnamemodify(M.options.storage_path, ":h")
    if vim.fn.isdirectory(storage_dir) == 0 then
        vim.fn.mkdir(storage_dir, "p")
    end
end

function M.update(new_config)
    M.options = vim.tbl_deep_extend("force", M.options, new_config)
    M.validate()
end

function M.validate()
    return nil
end


function M.get()
    return M.options
end

return M
