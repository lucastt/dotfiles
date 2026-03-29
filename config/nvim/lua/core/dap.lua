-- Inspiration: https://github.com/LazyVim/LazyVim/blob/5a27e1def0dca0f397b70b60e0422cc570b5ca29/lua/lazyvim/plugins/extras/dap/core.lua#L72
-- vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint(), {})           -- Breakpoint
-- vim.keymap.set('n', '<leader>dc', dap.continue(), {})                    -- continue
-- vim.keymap.set('n', '<leader>ds', dap.step_over(), {})                   -- step over
-- vim.keymap.set('n', '<leader>di', dap.step_into(), {})                   -- step into
-- vim.keymap.set('n', '<leader>dt', dap.terminate(), {})                   -- terminate
-- vim.keymap.set('n', '<leader>dr', dap.repl.toggle(), {})                 -- toggle repl
-- vim.keymap.set('n', '<leader>dh', require("dap.ui.widgets").hover(), {}) -- hover
--
-- dap.setup() -- ?
--
-- -- Language specific config:
-- --
-- -- Go -------------------------------------------------------------------
--
-- require('dap-go').setup {
--     -- Debug test config is done automaticaly
--     dap_configurations = {
--         {
--             -- Must be "go" or it will be ignored by the plugin
--             type = "go",
--             name = "Attach remote",
--             mode = "remote",
--             request = "attach",
--         },
--     },
--     -- delve configurations
--     delve = {
--         initialize_timeout_sec = 30,
--     },
-- }

local dap = require('dap')
local dapgo = require('dap-go')
local ui = require("dapui")
-- require("dapui").setup()
ui.setup()
-- require("dap-go").setup()
dapgo.setup()
require("nvim-dap-virtual-text").setup()

vim.keymap.set("n", "<space>b", dap.toggle_breakpoint)
vim.keymap.set("n", "<space>gb", dap.run_to_cursor)

-- Eval var under cursor (show the full virtual text)
vim.keymap.set("n", "<space>?", function()
  require("dapui").eval(nil, { enter = true })
end)

vim.keymap.set("n", "<space>dc", dap.continue)
vim.keymap.set("n", "<space>si", dap.step_into)
vim.keymap.set("n", "<space>sv", dap.step_over)
vim.keymap.set("n", "<space>so", dap.step_out)
vim.keymap.set("n", "<space>sb", dap.step_back) -- dap go do not support this one
vim.keymap.set("n", "<space>dr", dap.restart)

-- Need to configure test launch
vim.keymap.set("n", "<space>db", dapgo.debug_test, { silent = true })

dap.listeners.before.attach.dapui_config = function()
  ui.open()
end
dap.listeners.before.launch.dapui_config = function()
  ui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  ui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  ui.close()
end
