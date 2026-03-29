#!/usr/bin/env bash
# install-mac.sh
# Fresh Mac setup: Homebrew + all tools + configs.
# Tested on macOS Sonoma / Sequoia, Apple Silicon and Intel.
#
# Usage: bash scripts/install-mac.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
die()     { echo -e "${RED}[x]${NC} $1"; exit 1; }
section() { echo -e "\n${YELLOW}-- $1 --${NC}"; }

# ── Homebrew ───────────────────────────────────────────────────────────────
section "Homebrew"

if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

brew update

# ── CLI tools ──────────────────────────────────────────────────────────────
section "CLI tools"

brew install \
  git curl wget \
  tmux neovim \
  ripgrep fd fzf bat eza zoxide \
  jq yq tree \
  starship \
  kubectl

# fzf shell integration
"$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish --no-update-rc 2>/dev/null || true
info "CLI tools installed"

# ── Cask apps ──────────────────────────────────────────────────────────────
section "Cask apps"

brew install --cask alacritty 2>/dev/null || info "Alacritty already installed"
brew install --cask aerospace 2>/dev/null || info "AeroSpace already installed"
brew install --cask spotify 2>/dev/null || info "Spotify already installed"
brew install --cask telegram 2>/dev/null || info "Telegram already installed"
info "Cask apps installed"

# ── Fonts ──────────────────────────────────────────────────────────────────
section "Fonts"

brew install --cask font-jetbrains-mono-nerd-font 2>/dev/null || info "JetBrainsMono Nerd Font already installed"
info "Fonts installed"

# ── Languages ──────────────────────────────────────────────────────────────
section "Languages"

brew install go node python lua luarocks
info "Languages installed"

# ── Go tools ───────────────────────────────────────────────────────────────
section "Go tools"

export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
info "Go tools installed"

# ── LSP servers ────────────────────────────────────────────────────────────
section "LSP servers"

pip3 install pyright 2>/dev/null || pip3 install --user pyright
brew install hashicorp/tap/terraform-ls 2>/dev/null || true
brew install bufbuild/buf/buf 2>/dev/null || true
npm install -g vscode-langservers-extracted
npm install -g typescript typescript-language-server
npm install -g @vue/language-server
info "LSP servers installed"

# ── Claude Code CLI ────────────────────────────────────────────────────────
section "Claude Code CLI"

npm install -g @anthropic-ai/claude-code
info "Claude Code installed"

# ── Oh My Zsh ──────────────────────────────────────────────────────────────
section "Oh My Zsh"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  info "Oh My Zsh already installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

[[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && \
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

[[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

info "Oh My Zsh + plugins ready"

# ── TPM (tmux plugin manager) ─────────────────────────────────────────────
section "TPM"

[[ ! -d "$HOME/.tmux/plugins/tpm" ]] && \
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
info "TPM ready"

# ── Linters ────────────────────────────────────────────────────────────
section "Linters"

brew install shellcheck gitleaks luacheck
info "Linters ready (shellcheck, luacheck, gitleaks)"

# ── Git hooks ──────────────────────────────────────────────────────────
git -C "$REPO_DIR" config core.hooksPath .githooks
info "Gitleaks pre-commit hook enabled"

# ── Apply configs ──────────────────────────────────────────────────────────
section "Applying configs"

bash "$SCRIPT_DIR/apply-configs.sh"

# ── Done ───────────────────────────────────────────────────────────────────
section "Done"

echo ""
echo "  Manual steps:"
echo "  1. Reload shell:        source ~/.zshrc"
echo "  2. tmux plugins:        start tmux, then prefix + I"
echo "  3. nvim plugins:        nvim, then :Lazy sync"
echo "  4. Claude Code auth:    claude"
echo ""
warn "Add your secrets to ~/.zshrc.local (see shell/zshrc.local.example)"
