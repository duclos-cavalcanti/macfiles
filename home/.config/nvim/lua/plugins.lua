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
    { -- copilot
        "github/copilot.vim",
        config = function() 
            -- 
        end,
    },
    { -- chatgpt
        "robitx/gp.nvim",
        config = function()
            local conf = {
                -- For customization, refer to Install > Configuration in the Documentation/Readme
            }
            require("gp").setup(conf)
    
            -- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
        end,
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
    { -- git
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
            'nvim-lua/plenary.nvim',
        },
        config = function() require('ex.telescope') end,
    },
    { -- auto pairs
        "windwp/nvim-autopairs",
        config = function() require('nvim-autopairs').setup({}) end
    }, 
    { -- comment
        "numToStr/Comment.nvim",
        config = function() require('ex.comment') end,
    },
    { -- themes/ui
        "ellisonleao/gruvbox.nvim",
        "nvim-lualine/lualine.nvim",
        'fei6409/log-highlight.nvim',
        dependencies = {
                'kyazdani42/nvim-web-devicons', 
                {
                    'norcalli/nvim-colorizer.lua',
                    config  = function() require('colorizer').setup() end,
                }
        },
        config = function()
            require('log-highlight').setup {}
        end,
    },
}

local opts = {

}

require("lazy").setup(plugins, opts)
