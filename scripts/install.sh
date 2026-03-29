#!/usr/bin/env bash
# install.sh
# Detects the OS and runs the appropriate install script.
#
# Usage: bash scripts/install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  Darwin)
    echo "Detected macOS"
    bash "$SCRIPT_DIR/install-mac.sh"
    ;;
  Linux)
    if command -v pacman &>/dev/null; then
      echo "Detected Arch Linux"
      bash "$SCRIPT_DIR/install-arch.sh"
    elif command -v dnf &>/dev/null; then
      echo "Detected Fedora"
      bash "$SCRIPT_DIR/install-fedora.sh"
    elif command -v apt-get &>/dev/null; then
      echo "Detected Ubuntu/Debian"
      bash "$SCRIPT_DIR/install-ubuntu.sh"
    else
      echo "Unsupported Linux distribution."
      echo "Supported: Ubuntu/Debian (apt), Arch (pacman), Fedora (dnf)"
      exit 1
    fi
    ;;
  *)
    echo "Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac
