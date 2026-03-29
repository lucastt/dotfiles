#!/usr/bin/env bash
# install-ubuntu.sh
# Fresh Ubuntu setup (22.04 / 24.04 LTS) with GNOME desktop.
# Run as a regular user with sudo access.
#
# Usage: bash scripts/install-ubuntu.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
die()     { echo -e "${RED}[x]${NC} $1"; exit 1; }
section() { echo -e "\n${YELLOW}-- $1 --${NC}"; }

[[ $EUID -eq 0 ]] && die "Do not run as root. Run as your normal user."

# ── System packages ────────────────────────────────────────────────────────
section "System packages"

sudo apt-get update -qq
sudo apt-get install -y \
  git curl wget unzip build-essential \
  zsh tmux \
  ripgrep fd-find \
  fzf bat \
  jq tree \
  python3 python3-pip python3-venv \
  lua5.4 luarocks \
  ca-certificates gnupg lsb-release \
  gnome-tweaks

# fd on Ubuntu is fdfind
if ! command -v fd &>/dev/null && command -v fdfind &>/dev/null; then
  mkdir -p ~/.local/bin
  ln -sf "$(which fdfind)" ~/.local/bin/fd
  info "Symlinked fdfind -> fd"
fi

# bat on Ubuntu is batcat
if ! command -v bat &>/dev/null && command -v batcat &>/dev/null; then
  mkdir -p ~/.local/bin
  ln -sf "$(which batcat)" ~/.local/bin/bat
  info "Symlinked batcat -> bat"
fi

info "System packages installed"

# ── Neovim ─────────────────────────────────────────────────────────────────
section "Neovim"

NVIM_VERSION="v0.10.3"

if ! command -v nvim &>/dev/null; then
  sudo mkdir -p /opt/nvim
  curl -Lo /tmp/nvim.tar.gz \
    "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
  sudo tar -xzf /tmp/nvim.tar.gz -C /opt/nvim --strip-components=1
  sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  rm /tmp/nvim.tar.gz
  info "Neovim ${NVIM_VERSION} installed"
else
  info "Neovim already installed: $(nvim --version | head -1)"
fi

# ── Alacritty ──────────────────────────────────────────────────────────────
section "Alacritty"

if ! command -v alacritty &>/dev/null; then
  sudo add-apt-repository -y ppa:aslatter/ppa 2>/dev/null || true
  sudo apt-get update -qq
  sudo apt-get install -y alacritty 2>/dev/null || warn "Alacritty PPA not available — install manually"
else
  info "Alacritty already installed"
fi

# ── eza ────────────────────────────────────────────────────────────────────
section "eza"

if ! command -v eza &>/dev/null; then
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | sudo tee /etc/apt/sources.list.d/gierens.list
  sudo apt-get update -qq
  sudo apt-get install -y eza
  info "eza installed"
else
  info "eza already installed"
fi

# ── yq ─────────────────────────────────────────────────────────────────────
section "yq"

if ! command -v yq &>/dev/null; then
  YQ_VERSION="v4.40.5"
  sudo curl -Lo /usr/local/bin/yq \
    "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64"
  sudo chmod +x /usr/local/bin/yq
  info "yq installed"
else
  info "yq already installed"
fi

# ── zoxide ─────────────────────────────────────────────────────────────────
section "zoxide"

if ! command -v zoxide &>/dev/null; then
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  info "zoxide installed"
else
  info "zoxide already installed"
fi

# ── Starship ───────────────────────────────────────────────────────────────
section "Starship"

if ! command -v starship &>/dev/null; then
  curl -sSfL https://starship.rs/install.sh | sh -s -- --yes
  info "Starship installed"
else
  info "Starship already installed"
fi

# ── kubectl ────────────────────────────────────────────────────────────────
section "kubectl"

if ! command -v kubectl &>/dev/null; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm kubectl
  info "kubectl installed"
else
  info "kubectl already installed"
fi

# ── Go ─────────────────────────────────────────────────────────────────────
section "Go"

GO_VERSION="1.23.5"

if ! command -v go &>/dev/null; then
  curl -Lo /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf /tmp/go.tar.gz
  rm /tmp/go.tar.gz
  info "Go ${GO_VERSION} installed"
else
  info "Go already installed: $(go version)"
fi

export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"
export GOPATH="$HOME/go"

# Go tools
go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
info "Go tools installed"

# ── Node ───────────────────────────────────────────────────────────────────
section "Node"

if ! command -v node &>/dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  sudo apt-get install -y nodejs
  info "Node installed: $(node --version)"
else
  info "Node already installed: $(node --version)"
fi

# ── npm prefix (user-local) ───────────────────────────────────────────────
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$PATH"

# ── LSP servers ────────────────────────────────────────────────────────────
section "LSP servers"

pip3 install --user pyright
npm install -g vscode-langservers-extracted
npm install -g typescript typescript-language-server
npm install -g @vue/language-server

# Terraform LSP
if ! command -v terraform-ls &>/dev/null; then
  TF_LS_VERSION="0.33.1"
  curl -Lo /tmp/terraform-ls.zip \
    "https://releases.hashicorp.com/terraform-ls/${TF_LS_VERSION}/terraform-ls_${TF_LS_VERSION}_linux_amd64.zip"
  sudo unzip -o /tmp/terraform-ls.zip -d /usr/local/bin/
  rm /tmp/terraform-ls.zip
fi

# Buf
if ! command -v buf &>/dev/null; then
  BUF_VERSION="1.29.0"
  sudo curl -Lo /usr/local/bin/buf \
    "https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-Linux-x86_64"
  sudo chmod +x /usr/local/bin/buf
fi

info "LSP servers installed"

# ── Claude Code CLI ────────────────────────────────────────────────────────
section "Claude Code CLI"

curl -fsSL https://claude.ai/install.sh | bash
info "Claude Code installed"

# ── Apps (snap) ────────────────────────────────────────────────────────────
section "Apps"

snap install spotify 2>/dev/null || sudo snap install spotify 2>/dev/null || warn "Spotify snap failed — install manually"
snap install telegram-desktop 2>/dev/null || sudo snap install telegram-desktop 2>/dev/null || warn "Telegram snap failed — install manually"
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

# ── Linters ────────────────────────────────────────────────────────────
section "Linters"

sudo apt-get install -y shellcheck

if ! command -v luacheck &>/dev/null; then
  sudo luarocks install luacheck
  info "luacheck installed"
else
  info "luacheck already installed"
fi

if ! command -v gitleaks &>/dev/null; then
  GITLEAKS_VERSION="8.21.2"
  curl -Lo /tmp/gitleaks.tar.gz \
    "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz"
  sudo tar -xzf /tmp/gitleaks.tar.gz -C /usr/local/bin/ gitleaks
  rm /tmp/gitleaks.tar.gz
  info "gitleaks installed"
else
  info "gitleaks already installed"
fi

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
echo "  1. Start zsh:           exec zsh"
echo "  2. tmux plugins:        start tmux, then prefix + I"
echo "  3. nvim plugins:        nvim, then :Lazy sync"
echo "  4. Claude Code auth:    claude"
echo ""
warn "Add your secrets to ~/.zshrc.local (see shell/zshrc.local.example)"
