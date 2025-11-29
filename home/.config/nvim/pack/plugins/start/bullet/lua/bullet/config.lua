local vim = vim

local utils = require("bullet.utils")

local M = {
    options = {},
}

local defaults = {
    notes_dir = vim.fn.stdpath("data") .. "/bullet-notes/",

    ui = {
        border = "rounded",
        title = " Bullet Notes ",
        position = "center",
    },
}

function M.setup(user_config)
    M.options = vim.tbl_deep_extend("force", defaults, user_config or {})

    M.validate()
end

function M.validate()
    local notes_dir = M.options.notes_dir

    if not utils.is_dir(notes_dir) then
        utils.err("Invalid notes directory: " .. notes_dir)
    end
end

function M.update(new_config)
    M.options = vim.tbl_deep_extend("force", M.options, new_config)
    M.validate()
end

function M.get()
    return M.options
end

return M
