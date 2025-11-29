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

            vim.lsp.set_log_level 'info'
            vim.diagnostic.config({ virtual_text = false })

            vim.o.updatetime = 250
            vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]

            vim.lsp.config('*', {
              capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
            })

            vim.api.nvim_create_autocmd("LspAttach", {
                desc = "LSP actions",
                callback = function(args)
                    local bufnr = args.buf
                    local opts = {noremap = true, silent = false}

                    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

                    vim.api.nvim_buf_set_keymap(bufnr, 'n', "gd",        "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
                    vim.api.nvim_buf_set_keymap(bufnr, 'n', "gD",        "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
                    vim.api.nvim_buf_set_keymap(bufnr, 'n', "gi",        "<Cmd>lua vim.lsp.buf.implementation()<CR>", opts)
                    vim.api.nvim_buf_set_keymap(bufnr, 'n', "gr",        "<cmd>Telescope lsp_references<CR>", opts)
                    vim.api.nvim_buf_set_keymap(bufnr, 'n', "gh",        "<Cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
                    vim.api.nvim_buf_set_keymap(bufnr, 'n', "GT",        "<Cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
                    vim.api.nvim_buf_set_keymap(bufnr, 'n', "K",         "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
                    vim.api.nvim_buf_set_keymap(bufnr, 'n', "<leader>R", "<Cmd>lua vim.lsp.buf.rename()<CR>", opts)
                    vim.api.nvim_buf_set_keymap(bufnr, 'n', "gn",        "<Cmd>lua vim.diagnostic.goto_next()<CR>", opts)
                    vim.api.nvim_buf_set_keymap(bufnr, 'n', "gp",        "<Cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
                    vim.api.nvim_buf_set_keymap(bufnr, 'n', "gf",        "<Cmd>lua vim.diagnostic.open_float()<CR>", opts)
                end,
            })

            vim.lsp.enable('clangd')
            vim.lsp.enable('gopls')
            vim.lsp.enable('metals')
            vim.lsp.enable('marksman')
            vim.lsp.enable('csharp_ls')
            vim.lsp.enable('denols')
            vim.lsp.enable('rust_analyzer')
            vim.lsp.enable('cssls')
            vim.lsp.enable('html')
            vim.lsp.enable('pyright')
            vim.lsp.enable('lua_ls')

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
        keys = {
            { "<C-g>w", function() require('sidekick.cli').select() end, desc = "Sidekick Select" },
            { "<C-g>o", function() require('sidekick.cli').show() end, desc = "Sidekick Show" },
            { "<C-g>n", function()
                if not require('sidekick').nes_jump_or_apply() then
                    return '<Tab>'
                end
            end, expr = true, desc = "Goto/Apply Next Edit Suggestion" },
            { "<C-g>i", function() require('sidekick.cli').send({ msg = '{this}' }) end, mode = "x", desc = "Send This" },
            { "<C-g>f", function() require('sidekick.cli').send({ msg = '{file}' }) end, desc = "Send File" },
            { "<C-g>p", function() require('sidekick.cli').prompt() end, mode = { "n", "x" }, desc = "Sidekick Select Prompt" },
            { "<C-g>a", function() require('sidekick.cli').accept() end, desc = "Sidekick Accept Suggestion" },
            { "<C-g>d", function()
                local origin = vim.fn.getcwd()
                require('utils').pick_dir(function(dir)
                    vim.cmd('cd ' .. vim.fn.fnameescape(dir))
                    require('sidekick.cli').select()
                    vim.schedule(function()
                        vim.cmd('cd ' .. vim.fn.fnameescape(origin))
                    end)
                end)
            end, desc = "Sidekick in Directory" },
        },
        config = function()
            local opts = {
                nes = { enabled = false },
                cli = {
                    mux = {
                        backend = "tmux",
                        enabled = true,
                    },
                    win = {
                        layout = "float", -- Change from default "right" to "float"
                        float = {
                            width = 0.6,                -- 60% of screen width
                            height = 0.6,               -- 60% of screen height
                            row = 0.3,                  -- 20% from top (centers vertically: (100% - 60%) / 2 = 20%)
                            col = 0.4,                  -- 20% from left (centers horizontally: (100% - 60%) / 2 = 20%)
                            border = "rounded",         -- Border style: "none", "single", "double", "rounded", "solid", "shadow"
                            title = "AI",               -- Custom title
                            title_pos = "center",      -- Title position: "left", "center",
                        },
                    },
                    tools = {
                        auggie = {
                            cmd = {"auggie"}
                        }
                    }
                },
            }

            require("sidekick").setup(opts)
        end,
        dependencies = {
            {
                "zbirenbaum/copilot.lua",
                cmd = "Copilot",
                lazy = true,
                config = function()
                    require("copilot").setup({
                        suggestion = {
                            enabled = true,
                            auto_trigger = true,
                            keymap = {
                                accept = "<C-o>",
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
        'nvim-mini/mini.base16',
        version = '*',
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
            vim.opt.termguicolors = true
            local M = dofile(os.getenv("MACFILES") .. "/themes/theme.lua")

            require('mini.base16').setup({
              palette = M,
              use_cterm = true,
              plugins = {
                default = false,
                ['nvim-mini/mini.nvim'] = true,
                ['akinsho/bufferline.nvim'] = true,
                ['nvim-lualine/lualine.nvim'] = true,
              },
            })

            require("bufferline").setup {
                options = {
                    mode = "tabs"
                }
            }

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
                    lualine_c = {{'branch'}, { function() if vim.t['simple-zoom'] == nil then return '' elseif vim.t['simple-zoom'] == 'zoom' then return '󰍉' end end }},
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
        { "fasterius/simple-zoom.nvim", config = function() require('simple-zoom').setup({ hide_tabline = true }); vim.api.nvim_set_keymap("n", "<C-w>z", "<cmd>lua require('simple-zoom').toggle_zoom()<CR>", {noremap=true, silent=true}) end },
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
    { -- local
        {
            dir = vim.fn.stdpath("config") .. "/pack/plugins/start/moonspector",
            name = "moonspector",
            config = function()
                require("moonspector").setup()
                vim.api.nvim_set_keymap("n", "<C-w>m", "<cmd>MoonLaunch<CR>", {noremap=true, silent=true})
            end,
        },
        {
            dir = vim.fn.stdpath("config") .. "/pack/plugins/start/bullet",
            name = "bullet",
            lazy = "true",
            keys = {
                { "<C-w>O", "<cmd>BulletLaunch<CR>", desc = "Sidekick Select" },
            },
            config = function()
                local path = nil
                if os.getenv("USER") == "dduclos-cavalcanti" then
                    path = os.getenv("HOME") .. "/Documents/notes/"
                else
                    path = os.getenv("MACFILES") .. "/notes/"
                end
                local opts = {
                    notes_dir = path,
                }
                require("bullet").setup(opts)
            end,
        },
    },
}

local opts = {

}

require("lazy").setup(plugins, opts)
