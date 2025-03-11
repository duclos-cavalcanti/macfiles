-- FUNCTIONS
local function map(mode, lhs, rhs)
    vim.api.nvim_set_keymap(mode, lhs, rhs, {silent =  true})
end

local function noremap(mode, lhs, rhs)
    vim.api.nvim_set_keymap(mode, lhs, rhs, {noremap = true, silent = true})
end

local function exprnoremap(mode, lhs, rhs)
    vim.api.nvim_set_keymap(mode, lhs, rhs, {noremap = true, silent = true, expr = true})
end

local function nmap(lhs, rhs) map('n', lhs, rhs) end
local function xmap(lhs, rhs) map('x', lhs, rhs) end
local function nnoremap(lhs, rhs) noremap('n', lhs, rhs) end
local function vnoremap(lhs, rhs) noremap('v', lhs, rhs) end
local function xnoremap(lhs, rhs) noremap('x', lhs, rhs) end
local function inoremap(lhs, rhs) noremap('i', lhs, rhs) end
local function tnoremap(lhs, rhs) noremap('t', lhs, rhs) end
local function exprnnoremap(lhs, rhs) exprnoremap('n', lhs, rhs) end
local function exprinoremap(lhs, rhs) exprnoremap('i', lhs, rhs) end

-------------------
-- KEY MAPPINGS
-------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Utils
nnoremap("z.", "zszH")

-- Tabs
-- nnoremap("<M-j>", ":tabp<CR>")
-- nnoremap("<M-k>", ":tabn<CR>")
-- nnoremap("<M-J>", ":tabmove -1<CR>")
-- nnoremap("<M-K>", ":tabmove +1<CR>")

-- Terminal
tnoremap("<ESC>", "<C-\\><C-n>")
tnoremap("<C-w>", "<C-\\><C-N><C-w>")
nnoremap("<leader><space>", ":split <BAR> :resize 20 <BAR> term<CR>i")

-- File explorer
nnoremap("<leader>e", ":Telescope file_browser<CR>")

-- Telescope
nnoremap("<leader>sf", "<cmd>lua require('telescope.builtin').find_files({})<CR>")
nnoremap("<leader>sF", "<cmd>lua require('telescope.builtin').find_files({cwd=vim.fn.input('Path: ')})<CR>")
nnoremap("<leader>si", "<cmd>lua require('telescope.builtin').find_files({no_ignore=true})<CR>")

nnoremap("<leader>sb", "<cmd>lua require('telescope.builtin').buffers()<CR>")
nnoremap("<leader>sl", "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>")
nnoremap("<leader>sr", "<cmd>lua require('telescope.builtin').live_grep()<CR>")

nnoremap("<leader>sh", "<cmd>lua require('telescope.builtin').help_tags()<CR>")
nnoremap("<leader>sm", "<cmd>lua require('telescope.builtin').man_pages({sections={'ALL'}})<CR>")

vim.cmd([[command!  Scratch vsplit | enew | setlocal buftype=nofile bufhidden=wipe]])

vim.api.nvim_create_user_command('Scratch', function()
    vim.cmd('tabnew')
    vim.cmd('setlocal buftype=nofile')
    vim.cmd('setfiletype markdown')
end, {})

vim.api.nvim_create_user_command('PrettyPrintJson', function()
    local f = vim.fn.expand('%')
    vim.cmd('vnew')
    vim.cmd('setlocal buftype=nofile')
    vim.cmd('setfiletype json')
    vim.cmd('read !cat ' .. f .. ' | jq .')
end, {})
