# dotfiles

Dev environment for macOS and Linux (Ubuntu, Arch). One Dark theme across the entire stack.

## What's included

- **Shell**: zsh + Oh My Zsh + Starship prompt
- **Terminal**: Alacritty (JetBrainsMono Nerd Font)
- **Editor**: Neovim (lazy.nvim) with LSP, DAP, Telescope, Treesitter, CopilotChat, ThePrimeagen/99, Harpoon
- **Multiplexer**: tmux with TPM (resurrect + continuum)
- **Window manager**: AeroSpace (Mac), i3 (Linux, optional)
- **CLI tools**: ripgrep, fd, fzf, bat, eza, zoxide, jq, yq
- **AI**: Claude Code CLI + in-editor AI (99)

## Quick install

```bash
git clone https://github.com/lucastt/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash scripts/install.sh
```

This detects your OS and runs the right script:
- **macOS**: `install-mac.sh` (Homebrew + casks + configs)
- **Ubuntu**: `install-ubuntu.sh` (apt + snaps + configs)
- **Arch**: `install-arch.sh` (pacman + yay + configs)

### Update existing Mac

If you already have most tools installed and just want to refresh configs:

```bash
bash scripts/setup-current-mac.sh
```

### Optional: i3 window manager (Linux)

```bash
bash scripts/setup-i3.sh
```

## After install

1. **Reload shell**: `source ~/.zshrc` (or `exec zsh` on fresh Linux)
2. **tmux plugins**: start tmux, then `prefix + I`
3. **nvim plugins**: open nvim, then `:Lazy sync`
4. **Claude Code**: run `claude` to authenticate

## Secrets

Secrets are not committed. After install, create `~/.zshrc.local`:

```bash
cp ~/dotfiles/shell/zshrc.local.example ~/.zshrc.local
# Edit with your tokens
```

## Per-project AI context (`~/.context/`)

Context files for AI tools (Claude Code CLI and ThePrimeagen/99) are stored
in a mirror directory at `~/.context/`, organized by project path relative to
`$HOME`. This keeps project-specific instructions out of the project repos
while making them available to both tools.

### How it works

```
~/.context/<path-relative-to-HOME>/CLAUDE.md   # read by Claude Code CLI
~/.context/<path-relative-to-HOME>/AGENT.md    # read by 99
```

Example — context for `~/Code/lucastt/dotfiles`:

```
~/.context/Code/lucastt/dotfiles/CLAUDE.md
~/.context/Code/lucastt/dotfiles/AGENT.md
```

### Priority

1. **Project root** — if the project has its own `CLAUDE.md` or `AGENT.md`, that file is used
2. **Mirror** (`~/.context/...`) — fallback when no project-local file exists

### How each tool finds the files

- **Claude Code CLI** reads `~/.claude/CLAUDE.md` (global context) on every session.
  That file instructs Claude Code to check `~/.context/` for per-project context.
- **99** is configured with absolute mirror paths in its `md_files` list
  (computed at nvim startup from the cwd), so it reads directly from `~/.context/`.
- **Neovim keymaps** `<leader>ag` / `<leader>am` open the project-root file if
  it exists, otherwise open the mirror file (creating the directory structure).

### Creating context for a project

Open nvim in the project directory and press `<leader>ag` (AGENT.md) or
`<leader>am` (CLAUDE.md). The mirror directory is created automatically.

## Structure

```
config/              -> ~/.config/
  alacritty/         Alacritty terminal config + one_dark theme
  nvim/              Neovim config (init.lua, plugins, LSP, DAP, AI)
  starship.toml      Starship prompt (One Dark colors)
  tmux/scripts/      tmux helper scripts
  aerospace/         AeroSpace window manager (Mac)
  i3/                i3 window manager (Linux)

claude/
  CLAUDE.md          Global Claude Code context (deployed to ~/.claude/CLAUDE.md)

shell/
  zshrc              Main shell config (aliases, PATH, plugins)
  zprofile           Homebrew init (Mac)
  zshrc.local.example  Template for secrets
  zsh/               Custom zsh colorschemes

git/
  gitconfig          Git user, GPG signing, SSH URL rewriting

tmux/
  tmux.conf          tmux config (One Dark, Claude Code layout)

fonts/               JetBrainsMono Nerd Font (auto-installed on Linux)
wallpapers/          Desktop wallpapers
scripts/             Install and config scripts
```

## Key bindings

### tmux
| Key | Action |
|-----|--------|
| `prefix + \|` | Vertical split |
| `prefix + -` | Horizontal split |
| `prefix + hjkl` | Pane navigation |
| `prefix + G` | Claude Code layout (nvim 70% + claude 30%) |
| `prefix + C` | Quick claude split |

### Neovim
| Key | Action |
|-----|--------|
| `<leader>ff` | Telescope find files |
| `<leader>fg` | Telescope live grep |
| `<leader>ha` | Harpoon add file |
| `<leader>1-4` | Harpoon jump |
| `<leader>yr` | Yank relative path |
| `<leader>9v` | AI (99) visual selection (snapshots buffer first) |
| `<leader>9d` | Diff: side-by-side view of what 99 changed |
| `<leader>9r` | Revert buffer to pre-99 state |
| `<leader>ag` | Open AGENT.md (project root or `~/.context/` mirror) |
| `<leader>am` | Open CLAUDE.md (project root or `~/.context/` mirror) |
