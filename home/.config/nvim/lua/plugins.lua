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
            vim.lsp.enable('yamlls')

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
                        enabled = false,
                        backend = "tmux",
                    },
                    win = {
                        layout = "float", -- Change from default "right" to "float"
                        float = {
                            width = 0.8,                -- 60% of screen width
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
    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      ---@type snacks.Config
      opts = {
        bigfile = { enabled = true },
        dashboard = { enabled = true },
        explorer = { enabled = true },
        indent = { enabled = true },
        input = { enabled = true },
        notifier = {
          enabled = false,
          timeout = 3000,
        },
        picker = { enabled = true },
        quickfile = { enabled = true },
        scope = { enabled = true },
        scroll = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
        styles = {
          notification = {
            -- wo = { wrap = true } -- Wrap notifications
          }
        }
      },
      keys = {
        -- Top Pickers & Explorer
        { "<leader>sf", function() Snacks.picker.files() end, desc = "Find Files" },
        { "<leader>sb", function() Snacks.picker.buffers() end, desc = "Buffers" },
        { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
        { "<leader>sbd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
        { "<leader>sbr", function() Snacks.rename.rename_file() end, desc = "Rename File" },
        { "<leader>sl", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
        { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
        { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
        { "<leader>sc", function() Snacks.picker.commands() end, desc = "Commands" },
        { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
        { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
        { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
        { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
        { "<leader>sL", function() Snacks.picker.loclist() end, desc = "Location List" },
        { "<leader>sQ", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
        { "<leader>sm", function() Snacks.picker.man() end, desc = "Man Pages" },
        { "<leader>sM", function() Snacks.picker.marks() end, desc = "Marks" },

        { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },

        { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
        { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
        { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
        { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
        { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
        { "gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming" },
        { "gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing" },

        { "<leader><Tab>", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
        { "<leader><S-Tab>", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },

        { "<leader>Z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
        { "<leader>z",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },

        { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
        { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
        { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
        { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
      },
      init = function()
        vim.api.nvim_create_autocmd("User", {
          pattern = "VeryLazy",
          callback = function()
            -- Setup some globals for debugging (lazy-loaded)
            _G.dd = function(...)
              Snacks.debug.inspect(...)
            end
            _G.bt = function()
              Snacks.debug.backtrace()
            end

            -- Override print to use snacks for `:=` command
            if vim.fn.has("nvim-0.11") == 1 then
              vim._print = function(_, ...)
                dd(...)
              end
            else
              vim.print = _G.dd
            end
          end,
        })
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

            -- Get base16 palette from terminal colors
            local M = dofile(os.getenv("MACFILES") .. "/themes/theme.lua")
            M.base00 = "#282828"

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
                    mode = "tabs",
                    show_duplicate_prefix = false,
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
        {
        'akinsho/toggleterm.nvim',
        version = "*",
        config = function()
            vim.o.hidden = true

            require("toggleterm").setup{
                open_mapping = [[<space><space>]],
                direction = 'float',
                persist_mode = true,
                persist_size = true,
                insert_mappings = true,
            }
        end,
        },
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
            config = function()
                require('render-markdown').setup({
                    enabled = false,
                })
            end
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
                { "<C-w><space>", "<cmd>BulletLaunch<CR>", desc = "Launch bullet project note" },
                { "<C-w><enter>", "<cmd>BulletSticky<CR>", desc = "Launch bullet sticky note" },
                { "<C-w><tab>", "<cmd>BulletList<CR>", desc = "Select bullet project notes" },
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
