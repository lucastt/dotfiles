-- LSP config --------------------------------------------------------------------------------

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- capabilities for autocompletion - LSP integration
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- nvim-lspconfig deprecated the `require('lspconfig').<server>.setup{}` framework
-- on Neovim 0.11+ in favour of the built-in vim.lsp.config / vim.lsp.enable API
-- (removed entirely in nvim-lspconfig v3.0.0). Branch on the same nvim-0.11
-- predicate used in plugins.lua/syntax.lua so this shared config keeps working
-- on older machines (Fedora/Ubuntu) with the legacy framework, untouched.
if vim.fn.has('nvim-0.11') == 1 then
  -- ── Neovim 0.11+ : native vim.lsp.config / vim.lsp.enable ──────────────────
  -- Apply cmp completion capabilities to every server.
  vim.lsp.config('*', { capabilities = capabilities })

  -- Go
  vim.lsp.config('gopls', {
    cmd = { 'gopls', 'serve' },
    filetypes = { 'go', 'gomod' },
    root_markers = { 'go.work', 'go.mod' },
    settings = {
      gopls = {
        experimentalPostfixCompletions = true,
        analyses = { unusedparams = true, shadow = true },
        staticcheck = true,
      },
    },
  })

  -- Python
  vim.lsp.config('pyright', {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = 'openFilesOnly',
          useLibraryCodeForTypes = true,
        },
      },
    },
  })

  -- Rust
  vim.lsp.config('rust_analyzer', {
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml', 'rust-project.json' },
    settings = {
      ['rust-analyzer'] = {
        imports = { granularity = { group = 'module' }, prefix = 'self' },
        cargo = { buildScripts = { enable = true } },
        procMacro = { enable = true },
      },
    },
  })

  -- Protobuf
  vim.lsp.config('buf_ls', {
    cmd = { 'buf', 'beta', 'lsp', '--timeout=0', '--log-format=text' },
    filetypes = { 'proto' },
    root_markers = { 'buf.yaml', 'buf.work.yaml', '.git' },
  })

  -- Terraform
  vim.lsp.config('terraformls', {
    flags = { debounce_text_changes = 150 },
  })

  -- Vue / TS (volar)
  vim.lsp.config('volar', {
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' },
  })

  -- cssls and html use nvim-lspconfig's shipped defaults as-is.
  vim.lsp.enable({
    'gopls', 'pyright', 'rust_analyzer', 'buf_ls',
    'terraformls', 'volar', 'cssls', 'html',
  })
else
  -- ── Neovim ≤ 0.10 : legacy lspconfig framework (unchanged) ─────────────────
  local lspconfig = require('lspconfig')
  local lsputil = require('lspconfig.util')

  -- Go
  lspconfig.gopls.setup {
      cmd = {"gopls", "serve"},
      capabilities= capabilities,
      filetypes = {"go", "gomod"},
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

  -- Python
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

  -- Rust
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

  -- protobuf
  require'lspconfig'.buf_ls.setup({
      cmd = { 'buf', 'beta', 'lsp', '--timeout=0', '--log-format=text' },
      filetypes = {"proto"},
      root_dir = lsputil.root_pattern("buf.yaml", "buf.work.yaml", ".git"),
  })

  -- Terraform
  lspconfig.terraformls.setup({
      flags = { debounce_text_changes = 150 },
      textDocument = { completion = { completionItem = { snippetSupport = true } } },
  })

  -- Vue / TS (volar)
  lspconfig.volar.setup{
    filetypes = {'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json'}
  }

  -- CSS
  lspconfig.cssls.setup{}

  -- HTML
  lspconfig.html.setup{}
end

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
