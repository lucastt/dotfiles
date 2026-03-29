-- Navigation stuff --------------------------------------------------------------------------
-- TODO: consider only searching in directories that are git repos. This might improve search a lot...
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fr', builtin.oldfiles, {})

local telescope = require("telescope")
telescope.setup({
    defaults = {
        file_ignore_patterns = {
            "%.7z",
            "%.JPEG",
            "%.JPG",
            "%.MOV",
            "%.RAF",
            "%.burp",
            "%.bz2",
            "%.cache",
            "%.class",
            "%.dll",
            "%.docx",
            "%.dylib",
            "%.epub",
            "%.exe",
            "%.flac",
            "%.ico",
            "%.ipynb",
            "%.jar",
            "%.jpeg",
            "%.jpg",
            "%.lock",
            "%.mkv",
            "%.mov",
            "%.mp4",
            "%.otf",
            "%.pdb",
            "%.pdf",
            "%.png",
            "%.rar",
            "%.sqlite3",
            "%.svg",
            "%.tar",
            "%.tar.gz",
            "%.ttf",
            "%.webp",
            "%.zip",
            ".git/",
            ".gradle/",
            ".idea/",
            ".settings/",
            ".vale/",
            ".vscode/",
            "__pycache__/*",
            "build/",
            "env/",
            "gradle/",
            "node_modules/",
            "smalljre_*/*",
            "target/",
            "vendor/*", -- This one might be excluded in the future
        }
    },
    pickers = {
        find_files = { find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" } }
    }
})


require('nvim-web-devicons').setup {
     -- globally enable different highlight colors per icon (default to true)
     -- if set to false all icons will have the default icon's color
     color_icons = true;
     -- globally enable default icons (default to false)
     -- will get overriden by `get_icons` option
     default = true;
     -- globally enable "strict" selection of icons - icon will be looked up in
     -- different tables, first by filename, and if not found by extension; this
     -- prevents cases when file doesn't have any extension but still gets some icon
     -- because its name happened to match some extension (default to false)
     strict = true;
}

-- Session management
-- https://github.com/rmagatti/auto-session
-- https://www.reddit.com/r/neovim/comments/szis80/which_session_manager_for_nvim/hy5z83g/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
require('auto-session').setup({
    log_level = "error",
    -- auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/"},
    -- auto_session_root_dir = ?
})
