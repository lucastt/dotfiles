-- lua/core/plugins.lua
-- Plugins initialization — lazy.nvim
-- Added: coder/claudecode.nvim, ThePrimeagen/99, harpoon2

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
    -- ── Themes ───────────────────────────────────────────────────────────────
    { 'rose-pine/neovim', name = 'rose-pine' },
    { 'navarasu/onedark.nvim', name = 'one-dark' },
    { 'tanvirtin/monokai.nvim', name = 'monokai' },
    { 'nvim-tree/nvim-web-devicons' },

    -- ── LSP ──────────────────────────────────────────────────────────────────
    { 'neovim/nvim-lspconfig', name = 'lspconfig' },

    -- ── Telescope ────────────────────────────────────────────────────────────
    { 'nvim-telescope/telescope.nvim', tag = '0.1.4',
      dependencies = { 'nvim-lua/plenary.nvim' }
    },
    { 'nvim-treesitter/nvim-treesitter', name = 'tree-sitter' },

    -- ── Syntax / QoL ─────────────────────────────────────────────────────────
    { 'lukas-reineke/indent-blankline.nvim', name = 'ibl' },
    { 'RRethy/vim-illuminate', name = 'illuminate' },

    -- ── Session ──────────────────────────────────────────────────────────────
    { 'rmagatti/auto-session', name = 'auto-session' },

    -- ── Completion ───────────────────────────────────────────────────────────
    { 'hrsh7th/nvim-cmp', name = 'cmp' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-buffer' },
    { 'dcampos/nvim-snippy', name = 'snippy' },
    { 'dcampos/cmp-snippy' },

    -- ── DAP ──────────────────────────────────────────────────────────────────
    { 'mfussenegger/nvim-dap', name = 'dap',
      dependencies = {
        "rcarriga/nvim-dap-ui",
        "theHamsta/nvim-dap-virtual-text",
        "nvim-neotest/nvim-nio",
      }
    },
    { 'leoluz/nvim-dap-go', name = 'dap-go' },

    -- ── GRPC ─────────────────────────────────────────────────────────────────
    { 'hudclark/grpc-nvim', dependencies = { 'nvim-lua/plenary.nvim' } },

    -- ── Diagnostics / Comments ───────────────────────────────────────────────
    {
      "folke/trouble.nvim",
      opts = {},
      cmd = "Trouble",
      keys = {
        { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (Trouble)" },
        { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
        { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>",      desc = "Symbols (Trouble)" },
        { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Defs/Refs (Trouble)" },
        { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                  desc = "Location List (Trouble)" },
        { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix List (Trouble)" },
      },
    },
    { "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },

    -- ── Copilot (existing) ───────────────────────────────────────────────────
    { "github/copilot.vim" },
    {
      "CopilotC-Nvim/CopilotChat.nvim",
      dependencies = {
        { "github/copilot.vim" },
        { "nvim-lua/plenary.nvim" },
      },
      build = "make tiktoken",
    },
    { "ravitemer/mcphub.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      build = "npm install mcp-hub@latest",
    },

    -- ── Harpoon 2 — fast file marks ──────────────────────────────────────────
    -- You mentioned this in your init.lua todos. Replaces manual buffer jumping.
    {
      "ThePrimeagen/harpoon",
      branch = "harpoon2",
      dependencies = { "nvim-lua/plenary.nvim" },
    },

    -- ── ThePrimeagen/99 — targeted AI agent ──────────────────────────────────
    -- Philosophy: AI fills specific functions, not autonomous. You stay in control.
    -- Uses AGENT.md auto-discovery. Supports Claude Code + OpenCode providers.
    -- Repo: https://github.com/ThePrimeagen/99
    {
      "ThePrimeagen/99",
      config = function()
        local _99 = require("99")
        local cwd = vim.uv.cwd()
        local home = vim.fn.expand("$HOME")
        local basename = vim.fs.basename(cwd)

        -- Build md_files list: project-root names + absolute mirror paths
        -- 99 walks up the tree for relative names; absolute paths are read directly
        local md_files = {
          "AGENT.md",       -- project-level context (auto-walked up dir tree)
          "CLAUDE.md",      -- standard claude context file
        }

        -- Add ~/.context/ mirror paths so 99 reads from there too
        local rel = cwd
        if cwd:sub(1, #home) == home then
          rel = cwd:sub(#home + 2)
        end
        local context_root = home .. "/.context/" .. rel
        table.insert(md_files, context_root .. "/AGENT.md")
        table.insert(md_files, context_root .. "/CLAUDE.md")

        _99.setup({
          provider = _99.Providers.ClaudeCodeProvider,
          -- model = "claude-sonnet-4-6",  -- optional: pin a model
          logger = {
            level = _99.ERROR,             -- change to _99.DEBUG when troubleshooting
            path = "/tmp/" .. basename .. ".99.debug",
            print_on_error = true,
          },
          completion = {
            md_files = md_files,
          },
        })

        -- ── 99 snapshot + diff ──────────────────────────────────────────
        -- Snapshots buffer before 99 runs so you can diff what it changed.
        local snapshot = { lines = nil, name = nil, filetype = nil }

        -- Visual selection → AI (snapshots buffer first)
        vim.keymap.set("v", "<leader>9v", function()
          local buf = vim.api.nvim_get_current_buf()
          snapshot.lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          snapshot.name = vim.fn.expand("%:.")
          snapshot.filetype = vim.bo[buf].filetype
          _99.visual()
        end, { desc = "99: send visual selection to AI (snapshots first)" })

        -- Diff: show what 99 changed in a side-by-side tab
        vim.keymap.set("n", "<leader>9d", function()
          if not snapshot.lines then
            vim.notify("No 99 snapshot — run <leader>9v first", vim.log.levels.WARN)
            return
          end

          -- Open a new tab with the snapshot (before) on the left
          vim.cmd("tabnew")
          local snap_buf = vim.api.nvim_get_current_buf()
          vim.api.nvim_buf_set_lines(snap_buf, 0, -1, false, snapshot.lines)
          vim.bo[snap_buf].buftype = "nofile"
          vim.bo[snap_buf].buflisted = false
          vim.bo[snap_buf].modifiable = false
          vim.bo[snap_buf].filetype = snapshot.filetype or ""
          vim.api.nvim_buf_set_name(snap_buf, "99-before://" .. snapshot.name)
          vim.cmd("diffthis")

          -- Open the current file (after) on the right
          vim.cmd("vsplit " .. vim.fn.fnameescape(snapshot.name))
          vim.cmd("diffthis")
        end, { desc = "99: diff against pre-99 snapshot" })

        -- Revert: restore the buffer to its pre-99 state
        vim.keymap.set("n", "<leader>9r", function()
          if not snapshot.lines then
            vim.notify("No 99 snapshot to restore", vim.log.levels.WARN)
            return
          end
          local buf = vim.fn.bufnr(snapshot.name)
          if buf == -1 then
            vim.notify("Buffer " .. snapshot.name .. " not found", vim.log.levels.ERROR)
            return
          end
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, snapshot.lines)
          vim.notify("Restored buffer to pre-99 state", vim.log.levels.INFO)
        end, { desc = "99: revert to pre-99 snapshot" })

        -- Stop all in-flight requests
        vim.keymap.set("n", "<leader>9s", function() _99.stop_all_requests() end,
          { desc = "99: stop all AI requests" })

        -- Switch model on the fly via telescope (if telescope is loaded)
        vim.keymap.set("n", "<leader>9m", function()
          require("99.extensions.telescope").select_model()
        end, { desc = "99: select model" })

        -- View last run logs (for debugging)
        vim.keymap.set("n", "<leader>9l", function() _99.view_logs() end,
          { desc = "99: view last request logs" })
      end,
    },
}

vim.g.mapleader = " "

require("lazy").setup(plugins, {
    git = { url_format = "git@github.com:%s.git" }
})
