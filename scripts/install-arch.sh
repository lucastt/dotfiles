#!/usr/bin/env bash
# install-arch.sh
# Fresh Arch Linux setup with GNOME desktop.
# Run as a regular user with sudo access.
#
# Usage: bash scripts/install-arch.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
die()     { echo -e "${RED}[x]${NC} $1"; exit 1; }
section() { echo -e "\n${YELLOW}-- $1 --${NC}"; }

[[ $EUID -eq 0 ]] && die "Do not run as root. Run as your normal user."

# ── yay (AUR helper) ──────────────────────────────────────────────────────
section "yay"

if ! command -v yay &>/dev/null; then
  sudo pacman -S --needed --noconfirm git base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
  rm -rf /tmp/yay
  info "yay installed"
else
  info "yay already installed"
fi

# ── Core packages ──────────────────────────────────────────────────────────
section "Core packages"

sudo pacman -S --needed --noconfirm \
  git curl wget unzip \
  zsh tmux \
  neovim \
  alacritty \
  ripgrep fd fzf bat eza zoxide \
  jq yq tree \
  go nodejs npm python python-pip lua luarocks \
  starship \
  kubectl \
  gnome-tweaks

info "Core packages installed"

# fzf shell integration
if [[ ! -f ~/.fzf.zsh ]]; then
  /usr/share/fzf/install --all --no-bash --no-fish --no-update-rc 2>/dev/null || \
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all --no-bash --no-fish --no-update-rc
fi

# ── Go tools ───────────────────────────────────────────────────────────────
section "Go tools"

export GOPATH="$HOME/go"
export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"

go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
info "Go tools installed"

# ── LSP servers ────────────────────────────────────────────────────────────
section "LSP servers"

pip install --user pyright

yay -S --needed --noconfirm \
  terraform-ls \
  buf

npm install -g vscode-langservers-extracted
npm install -g typescript typescript-language-server
npm install -g @vue/language-server

info "LSP servers installed"

# ── Claude Code CLI ────────────────────────────────────────────────────────
section "Claude Code CLI"

npm install -g @anthropic-ai/claude-code
info "Claude Code installed"

# ── Apps ───────────────────────────────────────────────────────────────────
section "Apps"

yay -S --needed --noconfirm spotify-launcher telegram-desktop 2>/dev/null || \
  warn "App install failed — install spotify-launcher and telegram-desktop manually"
info "Apps installed"

# ── Zsh as default shell ──────────────────────────────────────────────────
section "Default shell"

if [[ "$SHELL" != "$(which zsh)" ]]; then
  warn "Changing default shell to zsh..."
  chsh -s "$(which zsh)"
fi

# ── Oh My Zsh ──────────────────────────────────────────────────────────────
section "Oh My Zsh"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

[[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && \
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

[[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

info "Oh My Zsh + plugins ready"

# ── TPM ────────────────────────────────────────────────────────────────────
section "TPM"

[[ ! -d "$HOME/.tmux/plugins/tpm" ]] && \
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
info "TPM ready"

# ── Apply configs ──────────────────────────────────────────────────────────
section "Applying configs"

bash "$SCRIPT_DIR/apply-configs.sh"

# ── Done ───────────────────────────────────────────────────────────────────
section "Done"

echo ""
echo "  Manual steps:"
echo "  1. Start zsh:           exec zsh"
echo "  2. tmux plugins:        start tmux, then prefix + I"
echo "  3. nvim plugins:        nvim, then :Lazy sync"
echo "  4. Claude Code auth:    claude"
echo ""
warn "Add your secrets to ~/.zshrc.local (see shell/zshrc.local.example)"
