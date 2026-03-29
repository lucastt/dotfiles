#!/usr/bin/env bash
# setup-gaming.sh
# Fedora gaming setup — NVIDIA drivers, Steam, and supporting tools.
# Run as a regular user with sudo access.
#
# Requires: Fedora with GNOME desktop.
# Note: Reboot after running this script for the NVIDIA driver to load.
#
# Usage: bash scripts/setup-gaming.sh

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
die()     { echo -e "${RED}[x]${NC} $1"; exit 1; }
section() { echo -e "\n${YELLOW}-- $1 --${NC}"; }

[[ $EUID -eq 0 ]] && die "Do not run as root. Run as your normal user."
command -v dnf &>/dev/null || die "This script is for Fedora (dnf) only."

# ── RPM Fusion repos ──────────────────────────────────────────────────────
section "RPM Fusion repositories"

FEDORA_VER=$(rpm -E %fedora)

if ! dnf repolist | grep -q rpmfusion-free; then
  sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm"
  info "RPM Fusion (free) enabled"
else
  info "RPM Fusion (free) already enabled"
fi

if ! dnf repolist | grep -q rpmfusion-nonfree; then
  sudo dnf install -y \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm"
  info "RPM Fusion (nonfree) enabled"
else
  info "RPM Fusion (nonfree) already enabled"
fi

# ── NVIDIA driver ─────────────────────────────────────────────────────────
section "NVIDIA driver (akmod-nvidia)"

if ! rpm -q akmod-nvidia &>/dev/null; then
  sudo dnf install -y akmod-nvidia
  info "akmod-nvidia installed"
  warn "The kernel module is building in the background (akmods)."
  warn "Wait a few minutes before rebooting — rebooting too early = broken graphics."
else
  info "akmod-nvidia already installed"
fi

# NVIDIA CUDA / NVDEC / NVENC support libraries
sudo dnf install -y xorg-x11-drv-nvidia-cuda 2>/dev/null || true

# ── Vulkan / Mesa (32-bit compat for Proton) ──────────────────────────────
section "Vulkan and 32-bit libraries"

sudo dnf install -y \
  vulkan-loader vulkan-tools \
  mesa-vulkan-drivers mesa-vulkan-drivers.i686 \
  mesa-libGL.i686 mesa-libEGL.i686

info "Vulkan and 32-bit libraries installed"

# ── Steam ─────────────────────────────────────────────────────────────────
section "Steam"

if ! command -v steam &>/dev/null; then
  sudo dnf install -y steam
  info "Steam installed"
else
  info "Steam already installed"
fi

# ── Gamemode ──────────────────────────────────────────────────────────────
section "Gamemode"

if ! command -v gamemoded &>/dev/null; then
  sudo dnf install -y gamemode
  info "Gamemode installed — use 'gamemoderun <game>' to launch with optimizations"
else
  info "Gamemode already installed"
fi

# ── MangoHud (optional performance overlay) ───────────────────────────────
section "MangoHud"

if ! command -v mangohud &>/dev/null; then
  sudo dnf install -y mangohud
  info "MangoHud installed — use 'mangohud <game>' or MANGOHUD=1 to enable the overlay"
else
  info "MangoHud already installed"
fi

# ── Done ──────────────────────────────────────────────────────────────────
section "Done"

echo ""
echo "  What was installed:"
echo "    - RPM Fusion (free + nonfree)"
echo "    - NVIDIA proprietary driver (akmod-nvidia)"
echo "    - Vulkan + 32-bit Mesa libraries (for Proton/DXVK)"
echo "    - Steam"
echo "    - Gamemode (CPU/GPU scheduler optimizations)"
echo "    - MangoHud (FPS/performance overlay)"
echo ""
warn "REBOOT before launching Steam so the NVIDIA driver loads properly."
echo ""
echo "  After reboot:"
echo "    1. Verify driver:    nvidia-smi"
echo "    2. Launch Steam:     steam"
echo "    3. Enable Proton:    Steam > Settings > Compatibility > Enable Steam Play for all titles"
echo ""
