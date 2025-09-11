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
    { -- augment AI
        'augmentcode/augment.vim',
        config = function() 
            require('ex.ai')
        end,
    },
    { -- git utilities
        'ruifm/gitlinker.nvim',
        dependencies = 'nvim-lua/plenary.nvim',
        config = function() 
            require"gitlinker".setup()
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
        { "iamcco/markdown-preview.nvim", cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" }, ft = { "markdown" }, build = "cd app && yarn install",}
    },
    { -- themes/ui
        "EdenEast/nightfox.nvim",
        lazy = false,
        dependencies = {
                'kyazdani42/nvim-web-devicons', 
                "nvim-lualine/lualine.nvim",
                {'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons'},
                {
                    'norcalli/nvim-colorizer.lua',
                    config  = function() require('colorizer').setup() end,
                },
        },
        config = function() 
            -- vim.g.termguicolors=true

            require("bufferline").setup {
                options = {
                    mode = "tabs"
                }
            }

            local scheme="carbonfox"
            vim.cmd('colorscheme ' .. scheme)

            -- statusline
            require('lualine').setup {
                options = {
                    theme = require('lualine.themes.' .. scheme),
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

local opts = {

}

require("lazy").setup(plugins, opts)
