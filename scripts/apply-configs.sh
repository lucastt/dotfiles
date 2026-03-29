#!/usr/bin/env bash
# apply-configs.sh
# Backs up existing configs and copies repo configs to their target locations.
# Called by all install scripts, or run standalone to refresh configs.
#
# Usage: bash scripts/apply-configs.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
section() { echo -e "\n${YELLOW}-- $1 --${NC}"; }

OS="$(uname -s)"

# ── Backup existing configs ────────────────────────────────────────────────
section "Backup"

BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
NEEDS_BACKUP=false

for target in \
  "$HOME/.zshrc" \
  "$HOME/.zprofile" \
  "$HOME/.tmux.conf" \
  "$HOME/.gitconfig" \
  "$HOME/.config/alacritty" \
  "$HOME/.config/nvim" \
  "$HOME/.config/starship.toml" \
  "$HOME/.config/tmux" \
  "$HOME/.config/aerospace" \
  "$HOME/.config/i3" \
  "$HOME/.zsh"; do
  [[ -e "$target" ]] && NEEDS_BACKUP=true && break
done

if $NEEDS_BACKUP; then
  mkdir -p "$BACKUP_DIR"
  for target in \
    "$HOME/.zshrc" \
    "$HOME/.zprofile" \
    "$HOME/.tmux.conf" \
    "$HOME/.gitconfig"; do
    [[ -f "$target" ]] && cp "$target" "$BACKUP_DIR/" 2>/dev/null
  done
  for target in \
    "$HOME/.config/alacritty" \
    "$HOME/.config/nvim" \
    "$HOME/.config/tmux" \
    "$HOME/.config/aerospace" \
    "$HOME/.config/i3" \
    "$HOME/.zsh"; do
    [[ -d "$target" ]] && cp -r "$target" "$BACKUP_DIR/" 2>/dev/null
  done
  [[ -f "$HOME/.config/starship.toml" ]] && cp "$HOME/.config/starship.toml" "$BACKUP_DIR/" 2>/dev/null
  info "Existing configs backed up to $BACKUP_DIR"
else
  info "No existing configs found — skipping backup"
fi

# ── Shell ──────────────────────────────────────────────────────────────────
section "Shell configs"

ZSHRC_SRC="$REPO_DIR/shell/zshrc"

# On Linux, remove the macos OMZ plugin line
if [[ "$OS" == "Linux" ]]; then
  sed 's/  macos.*$//' "$ZSHRC_SRC" > "$HOME/.zshrc"
  info "~/.zshrc applied (macos plugin removed for Linux)"
else
  cp "$ZSHRC_SRC" "$HOME/.zshrc"
  info "~/.zshrc applied"
fi

if [[ "$OS" == "Darwin" ]]; then
  cp "$REPO_DIR/shell/zprofile" "$HOME/.zprofile"
  info "~/.zprofile applied"
fi

mkdir -p "$HOME/.zsh/custom-colorschemes"
cp "$REPO_DIR/shell/zsh/custom-colorschemes/onedark.zsh" "$HOME/.zsh/custom-colorschemes/onedark.zsh"
info "zsh colorscheme applied"

# ── Git ────────────────────────────────────────────────────────────────────
section "Git config"

cp "$REPO_DIR/git/gitconfig" "$HOME/.gitconfig"
info "~/.gitconfig applied"

# ── tmux ───────────────────────────────────────────────────────────────────
section "tmux config"

cp "$REPO_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
mkdir -p "$HOME/.config/tmux/scripts"
cp "$REPO_DIR/config/tmux/scripts/claude-layout.sh" "$HOME/.config/tmux/scripts/"
chmod +x "$HOME/.config/tmux/scripts/claude-layout.sh"
info "tmux config applied"

# ── Alacritty ──────────────────────────────────────────────────────────────
section "Alacritty"

mkdir -p "$HOME/.config/alacritty/themes"
cp "$REPO_DIR/config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
cp "$REPO_DIR/config/alacritty/themes/one_dark.toml" "$HOME/.config/alacritty/themes/one_dark.toml"
info "Alacritty config applied"

# ── Neovim ─────────────────────────────────────────────────────────────────
section "Neovim"

mkdir -p "$HOME/.config/nvim/lua/core"
mkdir -p "$HOME/.config/nvim/snippets"
mkdir -p "$HOME/.config/nvim/ftplugin"

cp "$REPO_DIR/config/nvim/init.lua"     "$HOME/.config/nvim/init.lua"
cp "$REPO_DIR/config/nvim/old-init.vim" "$HOME/.config/nvim/old-init.vim"

for f in plugins.lua ai.lua lsp.lua navigation.lua autocompletion.lua dap.lua syntax.lua githublinks.lua copilot.lua; do
  cp "$REPO_DIR/config/nvim/lua/core/$f" "$HOME/.config/nvim/lua/core/$f"
done

cp "$REPO_DIR/config/nvim/snippets/go.snippets" "$HOME/.config/nvim/snippets/go.snippets"
cp "$REPO_DIR/config/nvim/ftplugin/java.lua"    "$HOME/.config/nvim/ftplugin/java.lua"
info "Neovim config applied"

# ── Starship ───────────────────────────────────────────────────────────────
section "Starship"

mkdir -p "$HOME/.config"
cp "$REPO_DIR/config/starship.toml" "$HOME/.config/starship.toml"
info "Starship config applied"

# ── AeroSpace (Mac only) ──────────────────────────────────────────────────
if [[ "$OS" == "Darwin" ]]; then
  section "AeroSpace"
  mkdir -p "$HOME/.config/aerospace"
  cp "$REPO_DIR/config/aerospace/aerospace.toml" "$HOME/.config/aerospace/aerospace.toml"
  cp "$REPO_DIR/config/aerospace/i3-like.toml"   "$HOME/.config/aerospace/i3-like.toml"
  info "AeroSpace config applied"
fi

# ── Fonts (Linux only) ────────────────────────────────────────────────────
if [[ "$OS" == "Linux" ]] && [[ -d "$REPO_DIR/fonts" ]]; then
  section "Fonts"
  mkdir -p "$HOME/.local/share/fonts"
  cp "$REPO_DIR/fonts/"*.ttf "$HOME/.local/share/fonts/" 2>/dev/null
  fc-cache -fv > /dev/null 2>&1
  info "JetBrainsMono Nerd Font installed"
fi

# ── Done ───────────────────────────────────────────────────────────────────
echo ""
info "All configs applied."

if [[ ! -f "$HOME/.zshrc.local" ]]; then
  warn "No ~/.zshrc.local found. Copy the example and add your secrets:"
  warn "  cp $REPO_DIR/shell/zshrc.local.example ~/.zshrc.local"
fi
