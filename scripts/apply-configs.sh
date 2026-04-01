#!/usr/bin/env bash
# apply-configs.sh
# Creates symlinks from dotfiles repo to their target locations.
# Safe to run multiple times — skips already-correct symlinks.
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

# ── Symlink helper ─────────────────────────────────────────────────────────────
# link_config <source> <target>
# - Already correct symlink → skip
# - Symlink to wrong target → relink
# - Real file/dir → remove and replace (dotfiles is source of truth)
link_config() {
  local src="$1"
  local dst="$2"

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    info "already linked: $dst"
    return
  fi

  if [[ -L "$dst" ]]; then
    warn "relinking: $dst (was → $(readlink "$dst"))"
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    warn "replacing: $dst"
    rm -rf "$dst"
  fi

  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  info "linked: $dst → $src"
}

# ── Shell ──────────────────────────────────────────────────────────────────────
section "Shell"
link_config "$REPO_DIR/shell/zshrc" "$HOME/.zshrc"
[[ "$OS" == "Darwin" ]] && link_config "$REPO_DIR/shell/zprofile" "$HOME/.zprofile"
link_config "$REPO_DIR/shell/zsh/custom-colorschemes/onedark.zsh" "$HOME/.zsh/custom-colorschemes/onedark.zsh"

# ── Git ────────────────────────────────────────────────────────────────────────
section "Git"
link_config "$REPO_DIR/git/gitconfig" "$HOME/.gitconfig"

# ── tmux ───────────────────────────────────────────────────────────────────────
section "tmux"
link_config "$REPO_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
link_config "$REPO_DIR/config/tmux/scripts/claude-layout.sh" "$HOME/.config/tmux/scripts/claude-layout.sh"
chmod +x "$REPO_DIR/config/tmux/scripts/claude-layout.sh"

# ── Alacritty ──────────────────────────────────────────────────────────────────
section "Alacritty"
link_config "$REPO_DIR/config/alacritty" "$HOME/.config/alacritty"

# ── Neovim ─────────────────────────────────────────────────────────────────────
section "Neovim"
link_config "$REPO_DIR/config/nvim" "$HOME/.config/nvim"
# lazy-lock.json is gitignored — nvim writes it into the symlinked dir, never committed

# ── Starship ───────────────────────────────────────────────────────────────────
section "Starship"
link_config "$REPO_DIR/config/starship.toml" "$HOME/.config/starship.toml"

# ── AeroSpace (Mac only) ──────────────────────────────────────────────────────
if [[ "$OS" == "Darwin" ]]; then
  section "AeroSpace"
  link_config "$REPO_DIR/config/aerospace" "$HOME/.config/aerospace"
fi

# ── Fonts (Linux only — binary files, copied not linked) ──────────────────────
if [[ "$OS" == "Linux" ]] && [[ -d "$REPO_DIR/fonts" ]]; then
  section "Fonts"
  mkdir -p "$HOME/.local/share/fonts"
  cp "$REPO_DIR/fonts/"*.ttf "$HOME/.local/share/fonts/" 2>/dev/null || true
  fc-cache -fv > /dev/null 2>&1
  info "JetBrainsMono Nerd Font installed"
fi

# ── Done ───────────────────────────────────────────────────────────────────────
echo ""
info "All configs linked."

if [[ ! -f "$HOME/.zshrc.local" ]]; then
  warn "No ~/.zshrc.local found. Copy the example and add your secrets:"
  warn "  cp $REPO_DIR/shell/zshrc.local.example ~/.zshrc.local"
fi
