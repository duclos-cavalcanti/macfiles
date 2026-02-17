local M = {}

function M.print(v)
    print(vim.inspect(v))
    return v
end

function M.float(cmd)
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
    })

    vim.cmd(cmd)
    local _buf = vim.api.nvim_win_get_buf(win)
end

function M.pick_dir(callback)
    local home = vim.fn.expand('~')
    require('telescope.builtin').find_files({
        prompt_title = "Select Directory",
        cwd = home,
        find_command = {'fd', '--type', 'd', '--hidden', '--exclude', '.git', '--max-depth', '5'},
        attach_mappings = function(prompt_bufnr, map)
            local actions = require('telescope.actions')
            local action_state = require('telescope.actions.state')

            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)

                if selection then
                    local dir = selection.path or selection.value
                    if callback then callback(dir) end
                end
            end)

            return true
        end,
    })
end

function M.term_color(idx)
    return vim.g['terminal_color_' .. idx]
end

return M
