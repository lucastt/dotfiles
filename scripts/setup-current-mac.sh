#!/usr/bin/env bash
# setup-current-mac.sh
# Update an existing Mac setup: installs missing tools and refreshes configs.
# Safe to run multiple times — only installs what's missing.
#
# Usage: bash scripts/setup-current-mac.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
section() { echo -e "\n${YELLOW}-- $1 --${NC}"; }

[[ "$(uname -s)" != "Darwin" ]] && { echo "This script is for macOS only."; exit 1; }

eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null

# ── Install missing Homebrew packages ──────────────────────────────────────
section "Checking Homebrew packages"

BREW_FORMULAE=(starship ripgrep fd fzf bat eza zoxide tmux jq yq tree neovim kubectl)
BREW_CASKS=(alacritty aerospace font-jetbrains-mono-nerd-font spotify telegram)

for pkg in "${BREW_FORMULAE[@]}"; do
  if ! brew list "$pkg" &>/dev/null; then
    brew install "$pkg"
    info "Installed $pkg"
  fi
done

for pkg in "${BREW_CASKS[@]}"; do
  if ! brew list --cask "$pkg" &>/dev/null; then
    brew install --cask "$pkg" 2>/dev/null || warn "$pkg cask failed"
    info "Installed $pkg"
  fi
done

info "All Homebrew packages up to date"

# ── Oh My Zsh plugins ─────────────────────────────────────────────────────
section "Oh My Zsh plugins"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

[[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && \
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

[[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

info "Plugins ready"

# ── TPM ────────────────────────────────────────────────────────────────────
section "TPM"

[[ ! -d "$HOME/.tmux/plugins/tpm" ]] && \
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
info "TPM ready"

# ── Claude Code CLI ────────────────────────────────────────────────────────
section "Claude Code CLI"

if ! command -v claude &>/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
  info "Claude Code installed"
else
  info "Claude Code already installed"
fi

# ── Apply configs ──────────────────────────────────────────────────────────
section "Applying configs"

bash "$SCRIPT_DIR/apply-configs.sh"

# ── Done ───────────────────────────────────────────────────────────────────
section "Done"

echo ""
echo "  1. Reload shell:        source ~/.zshrc"
echo "  2. tmux plugins:        prefix + I (if new plugins added)"
echo "  3. nvim plugins:        :Lazy sync"
echo ""
