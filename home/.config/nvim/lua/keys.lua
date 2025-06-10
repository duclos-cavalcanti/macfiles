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
nnoremap("<M-k>", ":tabnext<CR>")
nnoremap("<M-j>", ":tabprev<CR>")
nnoremap("<M-S-k>", ":tabmove +1<CR>")
nnoremap("<M-S-j>", ":tabmove -1<CR>")

-- Terminal
tnoremap("<ESC>", "<C-\\><C-n>")
tnoremap("<C-w>", "<C-\\><C-N><C-w>")
nnoremap("<leader><space>", ":split <BAR> :resize 20 <BAR> term<CR>i")

-- Tags 
nnoremap("<leader><tab>", "<cmd>AerialToggle left<CR>")

-- Telescope
nnoremap("<leader>sf", "<cmd>lua require('telescope.builtin').find_files({})<CR>")
nnoremap("<leader>sF", "<cmd>lua require('telescope.builtin').find_files({cwd=vim.fn.input('Path: ')})<CR>")
nnoremap("<leader>si", "<cmd>lua require('telescope.builtin').find_files({no_ignore=true})<CR>")
nnoremap("<leader>sb", "<cmd>lua require('telescope.builtin').buffers()<CR>")
nnoremap("<leader>sl", "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>")
nnoremap("<leader>sr", "<cmd>lua require('telescope.builtin').live_grep()<CR>")
nnoremap("<leader>sR", "<cmd>lua require('telescope.builtin').grep_string({search=''})<CR>")
nnoremap("<leader>sh", "<cmd>lua require('telescope.builtin').help_tags()<CR>")
nnoremap("<leader>sm", "<cmd>lua require('telescope.builtin').man_pages({sections={'ALL'}})<CR>")

-- Copilot
nnoremap("<leader>c", "<cmd>CopilotChatToggle<CR>")

-- No-file buffer
vim.keymap.set("n", "<leader>o", function()
    vim.cmd('tabnew')
    vim.cmd('setlocal buftype=nofile')
    vim.cmd('setlocal nowrap')
    vim.cmd('setfiletype markdown')
end,
{ noremap = true, silent = true, desc = "Quickfix Prev if Open" })

function is_quickfix_open()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_get_option(buf, "buftype") == "quickfix" then
      return true
    end
  end
  return false
end

-- Quickfix list / Buffers
vim.keymap.set("n", "<leader>q", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_get_option(buf, "buftype") == "quickfix" then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  vim.cmd("copen")
end, 
{ noremap = true, silent = true, desc = "ToggleOrFocus Quickfixlist" })

vim.keymap.set("n", "<leader>l", function()
    vim.diagnostic.setloclist()
end, 
{ noremap = true, silent = true, desc = "Open Locallist"})

vim.keymap.set("n", "<C-n>", function()
  if is_quickfix_open() then
    vim.cmd("cnext")
    vim.cmd("normal! zz")
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-n>", true, false, true), "n", true)
  end
end, 
{ noremap = true, silent = true, desc = "Quickfix Next if Open" })

vim.keymap.set("n", "<C-p>", function()
  if is_quickfix_open() then
    vim.cmd("cprev")
    vim.cmd("normal! zz")
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-p>", true, false, true), "n", true)
  end
end,
{ noremap = true, silent = true, desc = "Quickfix Prev if Open" })
