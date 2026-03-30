#!/usr/bin/env bash
# install-fedora.sh
# Fresh Fedora setup (39+) — works on both Workstation and Minimal/Netinstall.
# On Minimal: bootstraps a lean GNOME desktop, NetworkManager, Firefox, and audio.
# On Workstation: skips what's already present.
# Run as a regular user with sudo access.
#
# Usage: bash scripts/install-fedora.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
die()     { echo -e "${RED}[x]${NC} $1"; exit 1; }
section() { echo -e "\n${YELLOW}-- $1 --${NC}"; }

[[ $EUID -eq 0 ]] && die "Do not run as root. Run as your normal user."

NEEDS_REBOOT=false

# ── RPM Fusion ────────────────────────────────────────────────────────────
section "RPM Fusion"

if ! rpm -q rpmfusion-free-release &>/dev/null; then
  sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
  info "RPM Fusion (free + nonfree) enabled"
else
  info "RPM Fusion already enabled"
fi

# ── Desktop bootstrap (Minimal ISO support) ──────────────────────────────
section "Desktop bootstrap"

# NetworkManager + WiFi
if ! rpm -q NetworkManager &>/dev/null; then
  sudo dnf install -y NetworkManager NetworkManager-wifi
  sudo systemctl enable --now NetworkManager
  NEEDS_REBOOT=true
  info "NetworkManager + WiFi installed"
else
  info "NetworkManager already present"
fi

# GNOME desktop (lean — no Workstation bloat)
if ! rpm -q gnome-shell &>/dev/null; then
  sudo dnf install -y \
    gnome-shell gdm nautilus \
    xdg-user-dirs xdg-user-dirs-gtk \
    pipewire pipewire-pulseaudio wireplumber
  sudo systemctl enable gdm
  sudo systemctl set-default graphical.target
  NEEDS_REBOOT=true
  info "GNOME desktop installed (lean)"
else
  info "GNOME already present"
fi

# Firefox
if ! command -v firefox &>/dev/null; then
  sudo dnf install -y firefox
  info "Firefox installed"
else
  info "Firefox already present"
fi

# ── System packages ────────────────────────────────────────────────────────
section "System packages"

sudo dnf install -y \
  curl wget unzip \
  zsh tmux neovim \
  ripgrep fd-find \
  fzf bat eza zoxide \
  jq yq tree \
  python3 python3-pip \
  lua luarocks \
  ca-certificates gnupg2 pinentry \
  gnome-tweaks \
  ShellCheck

sudo dnf group install -y development-tools

info "System packages installed"

# ── Alacritty ──────────────────────────────────────────────────────────────
section "Alacritty"

if ! command -v alacritty &>/dev/null; then
  sudo dnf install -y alacritty
  info "Alacritty installed"
else
  info "Alacritty already installed"
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
  curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo -E bash -
  sudo dnf install -y nodejs
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

# ── Docker CE ─────────────────────────────────────────────────────────────
section "Docker"

if ! command -v docker &>/dev/null; then
  sudo dnf install -y dnf5-plugins
  sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
  sudo dnf install -y docker-ce docker-ce-cli containerd.io
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER"
  info "Docker CE installed (log out and back in for group to take effect)"
else
  info "Docker already installed"
fi

# ── Claude Code CLI ────────────────────────────────────────────────────────
section "Claude Code CLI"

curl -fsSL https://claude.ai/install.sh | bash
info "Claude Code installed"

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
if $NEEDS_REBOOT; then
  warn "Desktop was bootstrapped from a Minimal install."
  echo ""
  echo "  REBOOT REQUIRED to start GNOME desktop:"
  echo "    sudo reboot"
  echo ""
  echo "  After reboot:"
fi
echo "  Manual steps:"
echo "  1. Start zsh:           exec zsh"
echo "  2. Claude Code auth:    claude"
echo "  3. Get secrets and keys from vault"
echo "  4. tmux plugins:        start tmux, then prefix + I"
echo "  5. nvim plugins:        nvim, then :Lazy sync"
echo ""
warn "Add your secrets to ~/.zshrc.local (see shell/zshrc.local.example)"
