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
    { -- ssh
        'nosduco/remote-sshfs.nvim',
        dependencies = { 'nvim-telescope/telescope.nvim' },
        config = function() 
            -- require('ex.ssh') 
            require('remote-sshfs').setup({})
            require('telescope').load_extension 'remote-sshfs'
        end
    },
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
            "mrcjkb/rustaceanvim",
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
            require("aerial").setup({
              -- optionally use on_attach to set keymaps when aerial has attached to a buffer
              -- on_attach = function(bufnr)
              --   -- Jump forwards/backwards with '{' and '}'
              --   vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
              --   vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
              -- end,
            })
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
    { -- file-browser
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
    },
    { -- markdown
        "iamcco/markdown-preview.nvim",
        config = function()
            vim.fn["mkdp#util#install"]()
            vim.cmd[[
            function OpenMarkdownPreview (url)
                execute "! open -a 'Google Chrome' -n --args --new-window " . a:url
            endfunction
            let g:mkdp_browserfunc = 'OpenMarkdownPreview'
            ]]
        end,
    },
    { -- filebrowser
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
        -- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
      }
    },
    { -- git
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",

            "nvim-telescope/telescope.nvim",
            "ibhagwan/fzf-lua",
      },
        config = function() 
            local neogit = require('neogit')
            neogit.setup {}
        end
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
        "https://github.com/Mofiqul/adwaita.nvim",
        "loctvl842/monokai-pro.nvim",
        "UtkarshVerma/molokai.nvim",
        "ellisonleao/gruvbox.nvim",
        "nvim-lualine/lualine.nvim",
        dependencies = {
                'kyazdani42/nvim-web-devicons', 
                {
                    'norcalli/nvim-colorizer.lua',
                    config  = function() require('colorizer').setup() end,
                }
        },
    },
    { -- logging
        'fei6409/log-highlight.nvim',
        config = function()
            require('log-highlight').setup {}
        end,
    },
}

local opts = {

}

require("lazy").setup(plugins, opts)
