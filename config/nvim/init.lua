-- ~/.config/nvim/init.lua

-- Old vim config (keeps your existing settings from old-init.vim)
vim.cmd('source ~/.config/nvim/old-init.vim')

-- Setup plugins
-- this needs to happen before any other lua module be called
require('core.plugins')

-- Initialize Theme
vim.cmd('colorscheme onedark')

-- Syntax highlight and awareness
require('core.syntax')

-- Navigation stuff
require('core.navigation')

-- Auto completion
require('core.autocompletion')

-- LSP config
require('core.lsp')

-- DAP config
require('core.dap')

-- Github links getter
require('core.githublinks').setup()

-- AI workflow: claudecode.nvim, 99, harpoon, path yanking, autoread
require('core.ai')
