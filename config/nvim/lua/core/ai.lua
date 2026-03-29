-- lua/core/ai.lua
-- AI workflow integration: claudecode.nvim, 99, harpoon, path yanking
-- Load this from init.lua: require('core.ai')

-- ── Context mirror helpers ──────────────────────────────────────────────
-- ~/.context/ mirrors project paths relative to $HOME.
-- e.g. ~/Code/lucastt/dotfiles -> ~/.context/Code/lucastt/dotfiles/AGENT.md
local CONTEXT_ROOT = vim.fn.expand("$HOME/.context")

-- Resolve the mirror path for a given filename in the current project
local function mirror_path(filename)
  local cwd = vim.fn.getcwd()
  local home = vim.fn.expand("$HOME")
  local rel = cwd
  if cwd:sub(1, #home) == home then
    rel = cwd:sub(#home + 2) -- strip $HOME/ prefix
  end
  return CONTEXT_ROOT .. "/" .. rel .. "/" .. filename
end

-- Check if a file exists
local function file_exists(path)
  return vim.fn.filereadable(path) == 1
end

-- Open a context file: project root first, then mirror fallback
local function open_context_file(filename)
  local cwd = vim.fn.getcwd()
  local project_file = cwd .. "/" .. filename

  -- If project has its own, open that
  if file_exists(project_file) then
    vim.cmd("edit " .. vim.fn.fnameescape(project_file))
    return
  end

  -- Otherwise open the mirror (create dir structure if needed)
  local m_path = mirror_path(filename)
  local m_dir = vim.fn.fnamemodify(m_path, ":h")
  vim.fn.mkdir(m_dir, "p")
  vim.cmd("edit " .. vim.fn.fnameescape(m_path))
end

-- Expose mirror_path globally so plugins.lua can compute paths for 99's md_files
_G._context_mirror_path = mirror_path


-- ── Harpoon 2 ─────────────────────────────────────────────────────────────
-- Fast file marks — navigate between your 4-5 hot files without telescope
local harpoon = require("harpoon")
harpoon:setup()

-- Add current file to harpoon list
vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end,
  { desc = "Harpoon: add file" })

-- Open harpoon menu (telescope-style picker)
vim.keymap.set("n", "<leader>hh", function()
  local conf = require("telescope.config").values
  local file_paths = {}
  for _, item in ipairs(harpoon:list().items) do
    table.insert(file_paths, item.value)
  end
  require("telescope.pickers").new({}, {
    prompt_title = "Harpoon",
    finder = require("telescope.finders").new_table({ results = file_paths }),
    previewer = conf.file_previewer({}),
    sorter = conf.generic_sorter({}),
  }):find()
end, { desc = "Harpoon: open menu" })

-- Direct jump to slot 1-4 (<leader>1 through <leader>4)
vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon: file 1" })
vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon: file 2" })
vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon: file 3" })
vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon: file 4" })

-- Cycle through harpoon list
vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end, { desc = "Harpoon: prev" })
vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end, { desc = "Harpoon: next" })


-- ── File path yanking — feed context to Claude Code in terminal pane ────────
-- Mirrors the pattern from xata.io blog: yank file path, paste into claude pane

-- Yank relative path (most useful with Claude Code — it knows the cwd)
vim.keymap.set("n", "<leader>yr", function()
  local path = vim.fn.expand("%:.")   -- relative to cwd
  vim.fn.setreg("+", path)
  vim.fn.setreg('"', path)
  vim.notify("Yanked: " .. path, vim.log.levels.INFO)
end, { desc = "Yank relative file path" })

-- Yank absolute path
vim.keymap.set("n", "<leader>ya", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.fn.setreg('"', path)
  vim.notify("Yanked: " .. path, vim.log.levels.INFO)
end, { desc = "Yank absolute file path" })

-- Yank path:line (e.g. internal/controller/foo.go:42) — for precise Claude refs
vim.keymap.set("n", "<leader>yl", function()
  local path = vim.fn.expand("%:.") .. ":" .. vim.fn.line(".")
  vim.fn.setreg("+", path)
  vim.fn.setreg('"', path)
  vim.notify("Yanked: " .. path, vim.log.levels.INFO)
end, { desc = "Yank file path:line" })


-- ── Auto-reload files changed externally ─────────────────────────────────
-- Essential: Claude Code writes files from terminal, nvim needs to pick them up.
-- This is more aggressive than the default autoread.
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= 'c' then
      vim.cmd("checktime")
    end
  end,
})

-- Lower updatetime so CursorHold fires faster (default 4000ms is too slow)
vim.opt.updatetime = 500


-- ── Context file keymaps ────────────────────────────────────────────────
-- Opens project-root file if it exists, otherwise falls back to ~/.context/ mirror

vim.keymap.set("n", "<leader>ag", function()
  open_context_file("AGENT.md")
end, { desc = "Open AGENT.md (project or mirror)" })

vim.keymap.set("n", "<leader>am", function()
  open_context_file("CLAUDE.md")
end, { desc = "Open CLAUDE.md (project or mirror)" })
