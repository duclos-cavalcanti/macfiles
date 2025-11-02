local function _on_attach(client, bufnr)
  -- Set omnifunc
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- Helper function
    local opts = {noremap = true, silent = false}
    local function bufnnoremap(lhs, rhs)
        vim.api.nvim_buf_set_keymap(bufnr, 'n', lhs, rhs, opts)
    end

    bufnnoremap("gd",           "<Cmd>lua vim.lsp.buf.definition()<CR>")
    bufnnoremap("gD",           "<Cmd>lua vim.lsp.buf.declaration()<CR>")
    bufnnoremap("gi",           "<Cmd>lua vim.lsp.buf.implementation()<CR>")
    bufnnoremap("gr",           "<cmd>Telescope lsp_references<CR>") 
    bufnnoremap("gh",           "<Cmd>lua vim.lsp.buf.signature_help()<CR>")
    bufnnoremap("GT",           "<Cmd>lua vim.lsp.buf.type_definition()<CR>")
    bufnnoremap("K",            "<Cmd>lua vim.lsp.buf.hover()<CR>")
    bufnnoremap("<leader>R",    "<Cmd>lua vim.lsp.buf.rename()<CR>")
    bufnnoremap("gn",           "<Cmd>lua vim.diagnostic.goto_next()<CR>")
    bufnnoremap("gp",           "<Cmd>lua vim.diagnostic.goto_prev()<CR>")
    bufnnoremap("gf",           "<Cmd>lua vim.diagnostic.open_float()<CR>")
end

vim.diagnostic.config({
  virtual_text = false
})

-- Show line diagnostics automatically in hover window
vim.o.updatetime = 250
vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]

-- add capabilities from nvim-cmp
local _capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
local runtime_path = vim.split(package.path, ';')

table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

vim.lsp.set_log_level 'info'
-- require('vim.lsp.log').set_format_func(vim.inspect)

require('lspconfig').clangd.setup({
    on_attach = _on_attach,
    capabilities = _capabilities,
    cmd = { "clangd" },
})

require('lspconfig').gopls.setup({
    on_attach = _on_attach,
    capabilities = _capabilities,
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gotmpl" },
})

require'lspconfig'.metals.setup{}

require'lspconfig'.marksman.setup{}

vim.lsp.enable('csharp_ls')

vim.lsp.enable('denols')

require'lspconfig'.rust_analyzer.setup{
    on_attach = _on_attach,
    capabilities = _capabilities,
    settings = {
      ['rust-analyzer'] = {
        diagnostics = {
          enable = true;
        }
      }
    }
}

require('lspconfig').cssls.setup {
  on_attach = _on_attach,
  capabilities = _capabilities
}

require('lspconfig').html.setup {
  on_attach = _on_attach,
  capabilities = _capabilities
}

require('lspconfig').pyright.setup({
    on_attach = _on_attach,
    capabilities = _capabilities,
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
})

require('lspconfig').lua_ls.setup({
    on_attach = _on_attach,
    capabilities = _capabilities,
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    settings = {
        runtime = {
            -- version = 'LuaJIT',
            version = 'Lua 5.4',
            path = runtime_path
        },
        diagnostics = {
            globals = {
                       "vim",
                       "awesome",
                       "client",
                       "screen",
                       "client",
                       "window",
                       "tag",
                       "root"
                   },
        },
        workspace = {
            library = {
                vim.api.nvim_get_runtime_file("", true),
                "/usr/share/awesome/lib",
            }
        },
        telemetry = {
            enable = false
        },
    },
    single_file_support = true,
})
