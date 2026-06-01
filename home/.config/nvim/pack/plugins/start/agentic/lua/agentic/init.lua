local vim = vim

local ref = require("agentic.ref")
local backend = require("agentic.backend")

local M = {}

function M.send_file(press_enter)
    local text = ref.file()
    if text then backend.send(text, press_enter) end
end

function M.send_selection(press_enter)
    local text = ref.selection()
    if text then backend.send(text, press_enter) end
end

function M.register()
    backend.register()
end

function M.preview(path)
    if path and path ~= "" then
        path = vim.fn.fnamemodify(vim.fn.expand(path), ":p")
    else
        path = vim.api.nvim_buf_get_name(0)
    end
    if path == "" then
        vim.notify("agentic: no file to preview", vim.log.levels.WARN)
        return
    end
    backend.preview(path)
end

function M.setup(_)
    vim.api.nvim_create_user_command("AgenticSendFile", function() M.send_file() end, {
        desc = "Send current file reference to the running agent",
    })
    vim.api.nvim_create_user_command("AgenticSendSelection", function() M.send_selection() end, {
        desc = "Send visual selection reference to the running agent",
        range = true,
    })
    vim.api.nvim_create_user_command("AgenticRegister", function() M.register() end, {
        desc = "Force (re)registration against a chosen claude target",
    })
    vim.api.nvim_create_user_command("AgenticPreview", function(opts) M.preview(opts.args) end, {
        nargs = "?",
        complete = "file",
        desc = "Live-preview a markdown file in the cmux panel (cmux-only)",
    })
end

return M
