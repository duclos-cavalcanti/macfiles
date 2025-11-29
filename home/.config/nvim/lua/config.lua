vim.g.mapleader = " "
vim.g.maplocalleader = " "

local options = {
    backup = false,                                     -- creates a backup file
    path = ".,**",
    tags = "./tags,tags;/",
    clipboard = "unnamedplus",                          -- allows neovim to access the system clipboard
    cmdheight = 2,                                      -- more space in the neovim command line for displaying messages
    completeopt = { "menuone","noinsert","noselect" },  -- mostly just for cmp
    conceallevel = 0,                                   -- so that `` is visible in markdown files
    fileencoding = "utf-8",                             -- the encoding written to a file
    hlsearch = false,                                   -- highlight all matches on previous search pattern
    incsearch = true,                                   -- show Search hit as you type
    ignorecase = true,                                  -- ignore case in search patterns
    mouse = "a",                                        -- allow the mouse to be used in neovim
    pumheight = 10,                                     -- pop up menu height
    showcmd = false,                                    -- dont Show commands while they are being typed
    showmode = false,                                   -- don't need to see modes
    showtabline = 2,                                    -- always show tabs
    smartcase = true,                                   -- smart case
    smartindent = true,                                 -- make indenting smarter again
    splitbelow = true,                                  -- force all horizontal splits to go below current window
    splitright = true,                                  -- force all vertical splits to go to the right of current window
    swapfile = false,                                   -- creates a swapfile
    termguicolors = true,                               -- set term gui colors (most terminals support this)
    timeoutlen = 500,                                   -- time to wait for a mapped sequence to complete (in milliseconds)
    undofile = true,                                    -- enable persistent undo
    updatetime = 300,                                   -- faster completion (4000ms default)
    writebackup = false,                                -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
    expandtab = true,                                   -- convert tabs to spaces
    shiftwidth = 4,                                     -- the number of spaces inserted for each indentation
    tabstop = 4,                                        -- insert 2 spaces for a tab
    softtabstop = 4,                                    -- insert 2 spaces for a tab
    number = true,                                      -- set numbered lines
    relativenumber = true,                              -- set relative numbered lines
    numberwidth = 4,                                    -- set number column width to 2 {default 4}
    cursorline = true,
    cursorcolumn = false,
    colorcolumn = "80",
    signcolumn = "yes",                                 -- always show the sign column, otherwise it would shift the text each time
    wrap = false,                                       -- display lines as one long line
    wrapscan = false,                                   -- dont Wrap Searches
    scrolloff = 8,                                      -- minimal number of screen lines to keep above and below cursor
    sidescrolloff = 8,
    hidden = true,
    spell = false,
    spelllang = "en_us",
    wildmode = "longest:full,full",
    confirm = false,
    autoread = true,
    lazyredraw = true,
}

vim.opt.shortmess:append "a"
vim.opt.shortmess:append "c"

for k, v in pairs(options) do
    vim.opt[k] = v
end

-- En/Disable inline error messages
vim.diagnostic.config {
    virtual_text = true,
    underline = true,            -- Keep error underline
    signs = true,                -- Keep gutter signs
}

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
vim.api.nvim_set_keymap("n", "<leader><space>", ":split <BAR> term<CR>i", {noremap=true, silent=true})
vim.api.nvim_set_keymap("n", "<leader>t", ":split <BAR> :resize 20 <BAR> term<CR>i", {noremap=true, silent=true})

-- scratchpad
vim.api.nvim_set_keymap('n', '<C-m>t', '<cmd>tabnew | setl buftype=nofile bufhidden=hide ft=markdown | file Scratchpad<CR>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', '<C-m>v', '<cmd>vnew | setl buftype=nofile bufhidden=hide ft=markdown | file Scratchpad<CR>', {noremap=true, silent=true})
vim.api.nvim_set_keymap('n', '<C-m>o', '<cmd>enew | setl buftype=nofile bufhidden=hide ft=markdown | file Scratchpad<CR>', {noremap=true, silent=true})

-- Netrw
vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>lua require("utils").float("Explore")<CR>', {noremap=true, silent=true})

-- Autocommands
vim.cmd [[ autocmd Signal SIGWINCH wincmd = ]]
vim.cmd [[ autocmd TermEnter term://* setlocal scl=no | setlocal nohidden | setlocal norelativenumber | setlocal nonu ]]
vim.cmd [[ autocmd BufHidden term://* q! ]]
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.lua",
    callback = function()
        local cursor_pos = vim.api.nvim_win_get_cursor(0)

        -- Remove trailing whitespace
        vim.cmd([[%s/\s\+$//e]])

        -- Remove blank lines at end of file
        vim.cmd([[%s/\n\+\%$//e]])

        -- Restore cursor position
        pcall(vim.api.nvim_win_set_cursor, 0, cursor_pos)
    end,
    desc = "Remove trailing whitespace and blank lines at EOF for Lua files"
})
