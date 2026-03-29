-- LSP config --------------------------------------------------------------------------------

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Imports.
-- https://github.com/golang/tools/blob/master/gopls/doc/vim.md#installation
local lspconfig = require('lspconfig')
local lsputil = require('lspconfig.util')

-- capabilities for autocompletion - LSP integration
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Language specific configs:
-- TODO: Separete this in one file per language under some inner dir

-- Go --------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

-- Gopls configs.
-- https://github.com/golang/tools/blob/master/gopls/doc/vim.md#custom-configuration
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#gopls
-- https://github.com/neovim/nvim-lspconfig/blob/df58d91c9351a9dc5be6cf8d54f49ab0d9a64e73/doc/lspconfig.txt#L429
lspconfig.gopls.setup {
    cmd = {"gopls", "serve"},
    capabilities= capabilities,
    filetypes = {"go", "gomod"},
    --root_dir = lsputil.root_pattern("go.work", "go.mod", ".git"),
    root_dir = lsputil.root_pattern("go.work", "go.mod"),
    settings = {
        gopls = {
            experimentalPostfixCompletions = true,
            analyses = {
                unusedparams = true,
                shadow = true,
            },
            staticcheck = true,
        },
    },
}

-- Python --------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------

lspconfig.pyright.setup {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    ".git",
  },
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = true
      }
    }
  },

}

-- Rust ----------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------

lspconfig.rust_analyzer.setup({
    filetypes = {"rust"},
    settings = {
        ["rust-analyzer"] = {
            imports = {
                granularity = {
                    group = "module",
                },
                prefix = "self",
            },
            cargo = {
                buildScripts = {
                    enable = true,
                },
            },
            procMacro = {
                enable = true
            },
        }
    }
})

-- protobuf ------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------

require'lspconfig'.buf_ls.setup({
    cmd = { 'buf', 'beta', 'lsp', '--timeout=0', '--log-format=text' },
    filetypes = {"proto"},
    root_dir = lsputil.root_pattern("buf.yaml", "buf.work.yaml", ".git"),
})

---------

-- Configure imports organization using 'goimports' logic
-- https://github.com/golang/tools/blob/master/gopls/doc/vim.md#imports
-- will be replaced by formatter plugin
-- vim.api.nvim_create_autocmd('BufWritePre', {
--   pattern = '*.go',
--   callback = function()
--     vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
--   end
-- })
--
-- vim.api.nvim_create_autocmd('BufWritePre', {
--     pattern = '*.go',
--     callback = vim.lsp.buf.format
-- })

-- Terraform -------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

lspconfig.terraformls.setup({
    flags = { debounce_text_changes = 150 },
    textDocument = { completion = { completionItem = { snippetSupport = true } } },
})

-- TS --------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

-- Need to use volar for TS otherwise I get random errors from LSP
--lspconfig.tsserver.setup{}

-- Vue ----
-- lspconfig.volar.setup{}
lspconfig.volar.setup{
  filetypes = {'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json'}
}

-- CSS ----
lspconfig.cssls.setup{}

-- HTML ----
lspconfig.html.setup{}

-- General Attach configuration -----------------------------------------------------------------
-------------------------------------------------------------------------------------------------

-- Format on save for all LSP-attached buffers
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
        vim.lsp.buf.format { async = false }
    end
})

-- https://github.com/neovim/nvim-lspconfig/tree/master#suggested-configuration
-- The idea of LspAttach autocommand is to only map the following keys after the
-- language server attaches to the current buffer.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)

  end,
})

