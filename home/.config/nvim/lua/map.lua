vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Utils
vim.api.nvim_set_keymap("n", "z.", "zszH", {noremap=true, silent=true})

-- Tabs
vim.api.nvim_set_keymap("n", "<M-k>", ":tabnext<CR>", {noremap=true, silent=true})
vim.api.nvim_set_keymap("n", "<M-j>", ":tabprev<CR>", {noremap=true, silent=true})
vim.api.nvim_set_keymap("n", "<M-S-k>", ":tabmove +1<CR>", {noremap=true, silent=true})
vim.api.nvim_set_keymap("n", "<M-S-j>", ":tabmove -1<CR>", {noremap=true, silent=true})

-- Terminal
vim.api.nvim_set_keymap("t", "<ESC>", "<C-\\><C-n>", {noremap=true, silent=true})
vim.api.nvim_set_keymap("t", "<C-w>", "<C-\\><C-N><C-w>", {noremap=true, silent=true})
vim.api.nvim_set_keymap("n", "<leader><space>", ":split <BAR> :resize 20 <BAR> term<CR>i", {noremap=true, silent=true})

-- Tags 
vim.api.nvim_set_keymap("n", "<leader><tab>", "<cmd>AerialToggle left<CR>", {noremap=true, silent=true})

-- Telescope
vim.api.nvim_set_keymap("n", "<leader>sf", "<cmd>lua require('telescope.builtin').find_files({})<CR>", {noremap=true, silent=true})
vim.api.nvim_set_keymap("n", "<leader>sF", "<cmd>lua require('telescope.builtin').find_files({cwd=vim.fn.input('Path: ')})<CR>", {noremap=true, silent=true})
vim.api.nvim_set_keymap("n", "<leader>si", "<cmd>lua require('telescope.builtin').find_files({no_ignore=true})<CR>", {noremap=true, silent=true})
vim.api.nvim_set_keymap("n", "<leader>sb", "<cmd>lua require('telescope.builtin').buffers()<CR>", {noremap=true, silent=true})
vim.api.nvim_set_keymap("n", "<leader>sl", "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>", {noremap=true, silent=true})
vim.api.nvim_set_keymap("n", "<leader>sr", "<cmd>lua require('telescope.builtin').live_grep()<CR>", {noremap=true, silent=true})
vim.api.nvim_set_keymap("n", "<leader>sR", "<cmd>lua require('telescope.builtin').grep_string({search=''})<CR>", {noremap=true, silent=true})
vim.api.nvim_set_keymap("n", "<leader>sh", "<cmd>lua require('telescope.builtin').help_tags()<CR>", {noremap=true, silent=true})
vim.api.nvim_set_keymap("n", "<leader>sm", "<cmd>lua require('telescope.builtin').man_pages({sections={'ALL'}})<CR>", {noremap=true, silent=true})

vim.api.nvim_set_keymap('n', '<C-m>t', '<cmd>tabnew | setl buftype=nofile bufhidden=hide ft=markdown | file Scratchpad<CR>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', '<C-m>v', '<cmd>vnew | setl buftype=nofile bufhidden=hide ft=markdown | file Scratchpad<CR>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', '<C-m>o', '<cmd>enew | setl buftype=nofile bufhidden=hide ft=markdown | file Scratchpad<CR>', {noremap=true, silent=true})

-- Events
vim.cmd [[ autocmd Signal SIGWINCH wincmd = ]]
vim.cmd [[ autocmd TermEnter term://* setlocal scl=no | setlocal nohidden | setlocal norelativenumber | setlocal nonu ]]
vim.cmd [[ autocmd BufHidden term://* q! ]]
