-- Auto completion ---------------------------------------------------------------------------
-- Snipets
require('snippy').setup({
    mappings = {
        is = {
            ['<Tab>'] = 'expand_or_advance',
            ['<S-Tab>'] = 'previous',
        },
        nx = {
            ['<leader>x'] = 'cut_text',
        },
    },
})

-- Insert mode snippy completion mapping - '<Control-s>'
vim.keymap.set("i", "<C-s>", function()
  require('snippy').complete()
end, { silent = true })


--Set up nvim-cmp.
local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      require 'snippy'.expand_snippet(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  -- I can improve these mappings: https://sharksforarms.dev/posts/neovim-rust/
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  -- something weird here, I just get completion from text sources, no LSP
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'snippy' },
  }, {
    { name = 'buffer' },
  })
})

