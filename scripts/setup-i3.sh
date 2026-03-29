#!/usr/bin/env bash
# setup-i3.sh
# Optional: install and configure i3 window manager on Linux.
# Run after the main install script. GNOME remains the default DE.
#
# Usage: bash scripts/setup-i3.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
die()     { echo -e "${RED}[x]${NC} $1"; exit 1; }
section() { echo -e "\n${YELLOW}-- $1 --${NC}"; }

[[ "$(uname -s)" != "Linux" ]] && die "i3 setup is Linux-only."

# ── Install i3 packages ───────────────────────────────────────────────────
section "i3 packages"

if command -v pacman &>/dev/null; then
  sudo pacman -S --needed --noconfirm \
    i3-wm i3lock i3status \
    dmenu nitrogen xss-lock \
    network-manager-applet \
    xfce4-screenshooter
elif command -v apt-get &>/dev/null; then
  sudo apt-get install -y \
    i3 i3lock i3status \
    dmenu nitrogen xss-lock \
    network-manager-gnome \
    xfce4-screenshooter
else
  die "Unsupported package manager"
fi

info "i3 packages installed"

# ── Apply i3 config ───────────────────────────────────────────────────────
section "i3 config"

mkdir -p "$HOME/.config/i3"
cp "$REPO_DIR/config/i3/config" "$HOME/.config/i3/config"
[[ -f "$REPO_DIR/config/i3/multi_display.sh" ]] && \
  cp "$REPO_DIR/config/i3/multi_display.sh" "$HOME/.config/i3/multi_display.sh" && \
  chmod +x "$HOME/.config/i3/multi_display.sh"
info "i3 config applied"

# ── Wallpapers ─────────────────────────────────────────────────────────────
section "Wallpapers"

mkdir -p "$HOME/Wallpapers"
cp "$REPO_DIR/wallpapers/"* "$HOME/Wallpapers/" 2>/dev/null || true
info "Wallpapers copied to ~/Wallpapers/"

# ── Done ───────────────────────────────────────────────────────────────────
section "Done"

echo ""
echo "  i3 is installed. To use it:"
echo "  - Log out"
echo "  - Select 'i3' from the session picker on the login screen"
echo "  - Mod key is Super (Windows key)"
echo ""
warn "GNOME remains your default desktop. i3 is available as an alternative session."
