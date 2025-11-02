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
        config = function() 
            vim.opt.runtimepath:append("$HOME/.local/share/treesitter")
            require('nvim-treesitter.configs').setup({
                parser_install_dir = "$HOME/.local/share/treesitter",
            	highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                autotag = {
                    enable = true,
                    filetypes = {"js", "jsx", "javascript", "html", "xml", "markdown", "md"},
                },
            	ensure_installed = {
                "bash",
                "html",
                "javascript",
                "css",
                "c",
                "c_sharp",
                "cpp",
                "cmake",
                "make",
                "rust",
                "python",
                "lua",
                "commonlisp",
                "haskell",
                "go",
                "nix",
                "gomod",
                "gowork",
                "java",
                "json",
                "yaml",
                "vim",
                "vimdoc",
                "query",
                "latex"
            	},
            })
        end,
    },
    { -- lsp and completion
        "neovim/nvim-lspconfig",
        -- event = "InsertEnter",
        dependencies = {
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lua",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function() 
            require('plug.completion') 
            require('plug.lspconfig')
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
            vim.api.nvim_set_keymap("n", "<leader><tab>", "<cmd>AerialToggle left<CR>", {noremap=true, silent=true})
        end,
    },
    { -- snippets
        "L3MON4D3/LuaSnip",
        config = function() 
            local ls = require "luasnip"
            ls.config.set_config {
                history = true,
                updateevents = "TextChanged,TextChangedI",
                enable_autosnippets = true,
            }
            ls.cleanup()
            -- read snippets lazily from the snippets folder besides init.lua
            require("luasnip.loaders.from_snipmate").lazy_load()
            -- examples inspired by
            -- https://github.com/honza/vim-snippets/tree/master/snippets
        end,
    },
    {
        "folke/sidekick.nvim",
        lazy = true,
        cmd = "SidekickLoad",
        opts = {
          -- add any options here
          cli = {
            mux = {
              backend = "tmux",
              enabled = true,
            },
          },
        },
        keys = {
            {
                "<C-g>w",
                function() require("sidekick.cli").select() end,
                desc = "Sidekick Select",
                mode = { "n" },
            },
            {
                "<C-g>o",
                function() require("sidekick.cli").toggle() end,
                desc = "Sidekick Toggle",
                mode = { "n", "t", "i", "x" },
            },
            {
                "<C-g>n",
                function()
                  if not require("sidekick").nes_jump_or_apply() then
                    return "<Tab>"
                  end
                end,
                expr = true,
                desc = "Goto/Apply Next Edit Suggestion",
            },
            {
                "<C-g>i",
                function() require("sidekick.cli").send({ msg = "{this}" }) end,
                mode = { "x", "n" },
                desc = "Send This",
            },
            {
                "<C-g>f",
                function() require("sidekick.cli").send({ msg = "{file}" }) end,
                desc = "Send File",
            },
            {
                "<C-g>p",
                function() require("sidekick.cli").prompt() end,
                mode = { "n", "x" },
                desc = "Sidekick Select Prompt",
            },
            {
                "<C-g>a",
                function() require("sidekick.cli").accept() end,
                desc = "Sidekick Accept Suggestion",
            },
        },
        config = function()
            vim.api.nvim_create_user_command(
                "SidekickLoad",
                function()
                    require("sidekick.cli").toggle()
                end,
                { desc = "Load and Toggle Sidekick/Copilot" }
            )
            
            require("sidekick").setup({})
        end,
        dependencies = {
            {
                "zbirenbaum/copilot.lua",
                cmd = "Copilot",
                config = function()
                    require("copilot").setup({
                        suggestion = {
                            enabled = true,
                            auto_trigger = true,
                            keymap = {
                                accept = "<C-m>",
                                accept_word = false,
                                accept_line = false,
                                next = "<M-]>",
                                prev = "<M-[>",
                                dismiss = "<C-]>",
                            },
                        },
                        panel = { enabled = false },
                    })
                end,
            },
            { 'nvim-lua/plenary.nvim', }
        }
    },
    { -- fuzzy finder
        'nvim-telescope/telescope.nvim',
        dependencies = {
            {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
            'nvim-telescope/telescope-ui-select.nvim',
            'nvim-lua/plenary.nvim',
        },
        config = function() 
            local actions = require('telescope.actions')
            local action_state = require("telescope.actions.state")
            
            require('telescope').setup({
              defaults = {
                sorting_strategy = "ascending",
                mappings = {
                  i = {
                    ['<C-n>'] = actions.move_selection_next,
                    ['<C-p>'] = actions.move_selection_previous,
                    ['<C-c>'] = actions.close,
                    ["<C-a>"] = actions.send_to_qflist,
                    ["<C-q>"] = actions.send_selected_to_qflist,
                  },
                  n = {
                    ['<C-c>'] = actions.close,
                  },
                },
                layout_config = {
                  horizontal ={
                    height = 47,
                    prompt_position = "top",
                  }
                }
              },
              extensions ={
                  fzf = {
                    fuzzy = true,                    -- false will only do exact matching
                    override_generic_sorter = true,  -- override the generic sorter
                    override_file_sorter = true,     -- override the file sorter
                    case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                  },
              },
            })
            require('telescope').load_extension('fzf')
            require("telescope").load_extension("ui-select")

            vim.api.nvim_set_keymap("n", "<leader>sf", "<cmd>lua require('telescope.builtin').find_files({})<CR>", {noremap=true, silent=true})
            vim.api.nvim_set_keymap("n", "<leader>sF", "<cmd>lua require('telescope.builtin').find_files({cwd=vim.fn.input('Path: ')})<CR>", {noremap=true, silent=true})
            vim.api.nvim_set_keymap("n", "<leader>si", "<cmd>lua require('telescope.builtin').find_files({no_ignore=true})<CR>", {noremap=true, silent=true})
            vim.api.nvim_set_keymap("n", "<leader>sb", "<cmd>lua require('telescope.builtin').buffers()<CR>", {noremap=true, silent=true})
            vim.api.nvim_set_keymap("n", "<leader>sl", "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>", {noremap=true, silent=true})
            vim.api.nvim_set_keymap("n", "<leader>sr", "<cmd>lua require('telescope.builtin').live_grep()<CR>", {noremap=true, silent=true})
            vim.api.nvim_set_keymap("n", "<leader>sR", "<cmd>lua require('telescope.builtin').grep_string({search=''})<CR>", {noremap=true, silent=true})
            vim.api.nvim_set_keymap("n", "<leader>sh", "<cmd>lua require('telescope.builtin').help_tags()<CR>", {noremap=true, silent=true})
            vim.api.nvim_set_keymap("n", "<leader>sm", "<cmd>lua require('telescope.builtin').man_pages({sections={'ALL'}})<CR>", {noremap=true, silent=true})
        end,
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
    { -- utils
        { "windwp/nvim-autopairs", config = function() require('nvim-autopairs').setup({}) end, },
        { "numToStr/Comment.nvim", config = function() require('Comment').setup() end, },
        { "lukas-reineke/indent-blankline.nvim", config = function() require("ibl").setup() end, },
        { "fei6409/log-highlight.nvim", config = function() require("log-highlight").setup {} end, },
        { 'ruifm/gitlinker.nvim', dependencies = 'nvim-lua/plenary.nvim', config = function() require"gitlinker".setup() end, },
        { 'MeanderingProgrammer/render-markdown.nvim',
            dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },
            ---@module 'render-markdown'
            ---@type render.md.UserConfig
            opts = {},
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
}

local opts = {

}

require("lazy").setup(plugins, opts)
