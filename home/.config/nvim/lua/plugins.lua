local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

local plugins = {
    { -- treesitter
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "windwp/nvim-ts-autotag",
        },
        config = function() require('ex.treesitter') end,
    },
    { -- lsp and completion
        "neovim/nvim-lspconfig",
        -- event = "InsertEnter",
        dependencies = {
            -- "mrcjkb/rustaceanvim",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lua",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function() 
            require('ex.completion') 
            require('ex.lspconfig')
        end,
    },
    { -- tags
      'stevearc/aerial.nvim',
      opts = {},
      dependencies = {
         "nvim-treesitter/nvim-treesitter",
         "nvim-tree/nvim-web-devicons"
      },
        config = function() 
            require("aerial").setup({ })
        end,
    },
    { -- snippets
        "L3MON4D3/LuaSnip",
        config = function() 
            local s = require('ex.luasnip')
            s.config()
            s.setup()
        end,
    },
    { -- fuzzy finder
        'nvim-telescope/telescope.nvim',
        dependencies = {
            {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
            'nvim-telescope/telescope-ui-select.nvim',
            'nvim-lua/plenary.nvim',
        },
        config = function() require('ex.telescope') end,
    },
    { -- utils
        { "windwp/nvim-autopairs", config = function() require('nvim-autopairs').setup({}) end, },
        { "numToStr/Comment.nvim", config = function() require('ex.comment') end, },
        { "lukas-reineke/indent-blankline.nvim", config = function() require("ibl").setup() end, },
        { "fei6409/log-highlight.nvim", config = function() require("log-highlight").setup {} end, },
        { 'ruifm/gitlinker.nvim', dependencies = 'nvim-lua/plenary.nvim', config = function() require"gitlinker".setup() end, },
        {
            'MeanderingProgrammer/render-markdown.nvim',
            dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },
            ---@module 'render-markdown'
            ---@type render.md.UserConfig
            opts = {},
            config = function()
                local group = vim.api.nvim_create_augroup('RenderMarkdownKeymap', { clear = true })
            
                vim.api.nvim_create_autocmd('FileType', {
                  group = group,
                  pattern = 'markdown',
                  callback = function(args)
                    vim.keymap.set('n', '<C-m>', function()
                      local render_md = require('render-markdown')
                      render_md.set(not render_md.get())
                    end, { 
                      desc = 'Toggle Markdown Rendering',
                      buffer = args.buf -- This makes the keymap buffer-local
                    })
                  end,
                })
              end,
        },
        {
            "iamcco/markdown-preview.nvim",
            cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
            build = "cd app && yarn install",
            init = function()
                vim.g.mkdp_filetypes = { "markdown" }
                vim.cmd[[ 
                    function OpenMarkdownPreview (url)
                        echo "Markdown Preview URL: " . a:url
                        let @+ = a:url
                    endfunction
                    let g:mkdp_browserfunc = 'OpenMarkdownPreview'
                ]]
            end,
            ft = { "markdown" },
        },
    },
    { -- themes/ui
        "RRethy/base16-nvim",
        lazy = false,
        dependencies = {
                "nvim-lualine/lualine.nvim",
                'kyazdani42/nvim-web-devicons', 
                {'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons'},
                {
                    'norcalli/nvim-colorizer.lua',
                    config  = function() require('colorizer').setup() end,
                },
        },
        config = function() 
            require("bufferline").setup {
                options = {
                    mode = "tabs"
                }
            }

            vim.opt.termguicolors = true

            M = {
                base00 = '#131313', -- Background (Editor) -> ANSI 0 (Black)
                base01 = '#363447', -- Lighter Background/UI elements (Editor) -> ANSI 10 (Bright Green)
                base02 = '#44475a', -- Selection/Highlight (Editor) -> ANSI 11 (Bright Yellow)
                base03 = '#606366', -- Comments/Faint Foreground (Editor) -> ANSI 8 (Bright Black/Dark Gray)
                base04 = '#9ea8c7', -- Darker Foreground (Editor) -> ANSI 12 (Bright Blue)
                base05 = '#f8f8f2', -- Main Foreground (Editor) -> ANSI 7 (White)
                base06 = '#f0f1f4', -- Lighter Foreground/Delimiters (Editor) -> ANSI 13 (Bright Magenta)
                base07 = '#ffffff', -- Highest Contrast UI (Editor) -> ANSI 14 (Bright Cyan)

                base08 = '#fb4934', -- Red Accent (Errors, Constants) (Editor) -> ANSI 1 (Red)
                base09 = '#ffb86c', -- Orange Accent (Warnings, Numbers) (Editor) -> ANSI 9 (Bright Red)
                base0A = '#f1fa8c', -- Yellow Accent (Strings, Types) (Editor) -> ANSI 3 (Yellow)
                base0B = '#50fa7b', -- Green Accent (Success, Function Names) (Editor) -> ANSI 2 (Green)
                base0C = '#8be9fd', -- Cyan Accent (Control Flow, Macros) (Editor) -> ANSI 6 (Cyan)
                base0D = '#74b2ff', -- Blue Accent (Keywords, Classes) (Editor) -> ANSI 4 (Blue)
                base0E = '#ff79c6', -- Magenta Accent (Storage, Special Chars) (Editor) -> ANSI 5 (Magenta)
                base0F = '#bd93f9'  -- Violet Accent (User Types, Exceptions) (Editor) -> ANSI 15 (Bright White)
            }
            require('base16-colorscheme').setup(M)

            -- statusline
            require('lualine').setup {
                options = {
                    theme = 'auto',
                    component_separators = {left = '', right = ''},
                    section_separators = {left = '', right = ''},
                    disabled_filetypes = {},
                    always_divide_middle = true,
                },
                sections = {
                    lualine_a = {'mode'},
                    lualine_b = { {'filename', path = 1}, 'diff'},
                    lualine_c = {'branch'},
                    lualine_x = {'location'},
                    lualine_y = {'progress'},
                    lualine_z = {'filetype'}
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {'filename'},
                    lualine_x = {'location'},
                    lualine_y = {},
                    lualine_z = {}
                },
                tabline = {},
                extensions = {}
            }
        end,
    },
}

-- work config
if os.getenv("USER") == "dduclos-cavalcanti" then
    table.insert(plugins, {
        'augmentcode/augment.vim',
        cmd = { "AugmentLoad" },
        config = function()
            vim.g.augment_workspace_folders = {
                '/Users/dduclos-cavalcanti/Documents/macfiles',
                '/Users/dduclos-cavalcanti/Documents/work/clone/windowmanagerplus/',
                '/Users/dduclos-cavalcanti/Documents/work/clone/hs_workspaces.spoon/',
                '/Users/dduclos-cavalcanti/Documents/work/kms',
                '/Users/dduclos-cavalcanti/Documents/work/vault-releases/vault-bridge/',
                '/Users/dduclos-cavalcanti/Documents/work/vault-releases/vault-core/',
                '/Users/dduclos-cavalcanti/Documents/work/vault-releases/vault-cold-bridge/',
                '/Users/dduclos-cavalcanti/Documents/work/vault-releases/vault-cold/',
            }

            vim.api.nvim_set_keymap('n', "<C-g>g", "<cmd>Augment signin<CR>", {noremap=true, silent=true})
            vim.api.nvim_set_keymap('n', "<C-g>o", "<cmd>Augment chat-toggle<CR>", {noremap=true, silent=true})
            vim.api.nvim_set_keymap('n', "<C-g>i", "<cmd>Augment chat<CR>", {noremap=true, silent=true})
            vim.api.nvim_set_keymap('v', "<C-g>i", ":Augment chat<CR>", {noremap=true, silent=true})
            vim.api.nvim_set_keymap('n', '<C-g>I', 'ggVG:Augment chat<CR>', {noremap=true, silent=true})
            vim.api.nvim_set_keymap('n', "<C-g>n", "<cmd>Augment chat-new<CR>", {noremap=true, silent=true})
            vim.api.nvim_set_keymap('n', '<C-g>p', '', {
                noremap = true, 
                silent = true,
                callback = function() 
                    local buf = vim.api.nvim_get_current_buf()

                    vim.cmd('enew')
                    vim.bo.buftype = 'nofile'
                    vim.bo.bufhidden = 'hide'
                    vim.cmd('%delete')
                    vim.cmd('0put +')


                    vim.cmd('normal! ggVG')
                    vim.cmd('Augment chat')

                    vim.cmd('bdelete!')
                    vim.api.nvim_set_current_buf(buf)
                end
            })

            local augmentResizeGroup = vim.api.nvim_create_augroup("AugmentResize", { clear = true })
            vim.api.nvim_create_autocmd("BufWinEnter", {
                group = augmentResizeGroup,
                pattern = "AugmentChatHistory",
                command = "wincmd =",
            })
        end,
        init = function()
            vim.api.nvim_create_user_command('AugmentLoad', function()
                require('lazy').load({ plugins = { 'augment.vim' } })
            end, { desc = 'Load Augment plugin' })
        end,
    })
end

local opts = {

}

require("lazy").setup(plugins, opts)
