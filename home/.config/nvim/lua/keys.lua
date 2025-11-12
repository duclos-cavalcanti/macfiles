vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- buffer
vim.api.nvim_set_keymap("n", "z.", "zszH", {noremap=true, silent=true})

-- tabs
vim.api.nvim_set_keymap("n", "<M-k>", ":tabnext<CR>", {noremap=true, silent=true})
vim.api.nvim_set_keymap("n", "<M-j>", ":tabprev<CR>", {noremap=true, silent=true})
vim.api.nvim_set_keymap("n", "<M-S-k>", ":tabmove +1<CR>", {noremap=true, silent=true})
vim.api.nvim_set_keymap("n", "<M-S-j>", ":tabmove -1<CR>", {noremap=true, silent=true})

-- terminal
vim.api.nvim_set_keymap("t", "<ESC>", "<C-\\><C-n>", {noremap=true, silent=true})
vim.api.nvim_set_keymap("t", "<C-w>", "<C-\\><C-N><C-w>", {noremap=true, silent=true})
vim.api.nvim_set_keymap("n", "<leader><space>", ":split <BAR> :resize 20 <BAR> term<CR>i", {noremap=true, silent=true})

-- scratchpad
vim.api.nvim_set_keymap('n', '<C-m>t', '<cmd>tabnew | setl buftype=nofile bufhidden=hide ft=markdown | file Scratchpad<CR>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', '<C-m>v', '<cmd>vnew | setl buftype=nofile bufhidden=hide ft=markdown | file Scratchpad<CR>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', '<C-m>o', '<cmd>enew | setl buftype=nofile bufhidden=hide ft=markdown | file Scratchpad<CR>', {noremap=true, silent=true})
