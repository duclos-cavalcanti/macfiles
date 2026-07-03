vim.cmd([[setlocal syntax=markdown]])
vim.cmd([[setlocal wrap]])
vim.cmd([[setlocal spell spelllang=en_us]])

vim.cmd [[setlocal expandtab ]]
vim.cmd [[setlocal tabstop=2 ]]
vim.cmd [[setlocal softtabstop=2]]
vim.cmd [[setlocal shiftwidth=2]]
vim.cmd [[setlocal nowrap]]
-- Hard-wrap at 80: insert a real newline once a line crosses the threshold.
vim.opt_local.textwidth = 80
vim.opt_local.formatoptions:append("t") -- auto-wrap text using textwidth
vim.opt_local.colorcolumn = "80"        -- visual guide at the limit

-- render-markdown: edit RAW here; <leader>mp toggles a live rendered vsplit.
-- Only touch real file buffers — the preview split is a nofile markdown buffer
-- that reruns this ftplugin, and it MUST stay rendered.
if vim.bo.buftype == "" then
    local buf = vim.api.nvim_get_current_buf()
    local function raw()
        vim.schedule(function()
            if vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_call(buf, function() vim.cmd("silent! RenderMarkdown buf_disable") end)
            end
        end)
    end
    raw() -- start raw (attach also happens on FileType)
    -- preview re-enables rendering on the source when it closes; re-disable after each toggle
    vim.keymap.set("n", "<leader>mp", function()
        vim.cmd("RenderMarkdown preview")
        raw()
    end, { buffer = true, desc = "Markdown preview (rendered vsplit)" })
end
