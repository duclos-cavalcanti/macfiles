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
    { -- lsp, completion, and snippets
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
            "L3MON4D3/LuaSnip",
        },
        config = function() 
            local cmp = require'cmp'
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
            
            cmp.setup({
                snippet = {
                    expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- luasnip users.
                  end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = {
                    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
                    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
                    ['<C-y>'] = cmp.config.disable,
                    ['<C-Space>'] = function(fallback)
                                        if cmp.visible() then
                                            cmp.close()
                                        else
                                            cmp.complete()
                                        end
                                     end,
                    ['<C-n>'] = function(fallback)
                                    if cmp.visible() then
                                        cmp.select_next_item()
                                    else
                                        fallback()
                                    end
                                end,
                    ['<C-p>'] = function(fallback)
                                      if cmp.visible() then
                                          cmp.select_prev_item()
                                      else
                                          fallback()
                                      end
                                  end,
                    ['<C-k>'] = cmp.mapping(function(fallback)
                                    if ls.expand_or_jumpable() then
                                        ls.expand_or_jump()
                                    else
                                        fallback()
                                    end
                                  end, {"i", "s"}),
                    ['<C-j>'] = cmp.mapping(function(fallback)
                                    if ls.jumpable(-1) then
                                        ls.jump(-1)
                                    else
                                        fallback()
                                    end
                                  end, {"i", "s"}),
                    ['<C-l>'] = cmp.mapping(function(fallback)
                                    if ls.choice_active() then
                                        ls.change_choice(1)
                                    else
                                        fallback()
                                    end
                                  end, {"i", "s"}),
                    ['<C-e>'] = cmp.mapping({
                        i = cmp.mapping.abort(),
                        c = cmp.mapping.close(),
                    }),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item
                },
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                }, {
                    { name = 'buffer' },
                })
            })

              -- Use buffer source for `/`
            cmp.setup.cmdline('/', {
                sources = {
                    { name = 'buffer' }
                }
            })

            -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline(':', {
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    { name = 'cmdline' }
                })
            })

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
    { -- ai 
        "folke/sidekick.nvim",
        lazy = true,
        cmd = "SidekickLoad",
        config = function()
            vim.api.nvim_create_user_command(
                "SidekickLoad",
                function()
                    require("sidekick.cli").toggle()
                end,
                { desc = "Load and Toggle Sidekick/Copilot" }
            )

            local opts = {
                nes = { enabled = false },
                cli = {
                    mux = {
                        backend = "tmux",
                        enabled = true,
                    },
                    tools = {
                        auggie = {
                            cmd = {"auggie"}
                        }
                    }
                },
            }

            require("sidekick").setup(opts)

            -- select
            vim.api.nvim_set_keymap("n", "<C-g>w", "<cmd>lua require('sidekick.cli').select()<CR>", {noremap=true, silent=true, desc="Sidekick Select"})

            -- toggle
            vim.api.nvim_set_keymap("n", "<C-g>o", "<cmd>lua require('sidekick.cli').toggle()<CR>", {noremap=true, silent=true, desc="Sidekick Toggle"})
            vim.api.nvim_set_keymap("i", "<C-g>o", "<cmd>lua require('sidekick.cli').toggle()<CR>", {noremap=true, silent=true, desc="Sidekick Toggle"})
            vim.api.nvim_set_keymap("t", "<C-g>o", "<cmd>lua require('sidekick.cli').toggle()<CR>", {noremap=true, silent=true, desc="Sidekick Toggle"})
            vim.api.nvim_set_keymap("x", "<C-g>o", "<cmd>lua require('sidekick.cli').toggle()<CR>", {noremap=true, silent=true, desc="Sidekick Toggle"})

            -- nes
            vim.api.nvim_set_keymap("n", "<C-g>n", "<cmd>lua if not require('sidekick').nes_jump_or_apply() then return '<Tab>' end<CR>", {noremap=true, silent=true, expr=true, desc="Goto/Apply Next Edit Suggestion"})

            vim.api.nvim_set_keymap("x", "<C-g>i", "<cmd>lua require('sidekick.cli').send({ msg = '{this}' })<CR>", {noremap=true, silent=true, desc="Send This"})
            vim.api.nvim_set_keymap("n", "<C-g>f", "<cmd>lua require('sidekick.cli').send({ msg = '{file}' })<CR>", {noremap=true, silent=true, desc="Send File"})
            vim.api.nvim_set_keymap("n", "<C-g>p", "<cmd>lua require('sidekick.cli').prompt()<CR>", {noremap=true, silent=true, desc="Sidekick Select Prompt"})
            vim.api.nvim_set_keymap("x", "<C-g>p", "<cmd>lua require('sidekick.cli').prompt()<CR>", {noremap=true, silent=true, desc="Sidekick Select Prompt"})
            vim.api.nvim_set_keymap("n", "<C-g>a", "<cmd>lua require('sidekick.cli').accept()<CR>", {noremap=true, silent=true, desc="Sidekick Accept Suggestion"})
        end,
        dependencies = {
            {
                "zbirenbaum/copilot.lua",
                cmd = "Copilot",
                lazy = true,
                config = function()
                    require("copilot").setup({
                        suggestion = {
                            enabled = false,
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
    {
        'augmentcode/augment.vim',
        cmd = { "AugmentLoad" },
        config = function()
            vim.g.augment_workspace_folders = {
                '/Users/dduclos-cavalcanti/Documents/macfiles',
                '/Users/dduclos-cavalcanti/Documents/work/kms',
                '/Users/dduclos-cavalcanti/Documents/work/core-extensions/',
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

            local M = dofile(os.getenv("HOME") .. "/.config/wezterm/theme.lua").get_colors()
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
