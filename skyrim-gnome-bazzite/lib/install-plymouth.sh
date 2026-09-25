#!/usr/bin/env bash
# lib/install-plymouth.sh — installs the Skyrim Plymouth boot splash.
# Run with sudo, from a cloned copy of the repo. Not part of install.sh.
#
#   sudo bash lib/install-plymouth.sh

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "This script needs root (it writes to /usr/share/plymouth/themes). Run with sudo." >&2
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSET_DIR="$REPO_ROOT/assets/plymouth/skyrim"
DEST="/usr/share/plymouth/themes/skyrim"

if [ ! -d "$ASSET_DIR" ] || [ -z "$(ls -A "$ASSET_DIR" 2>/dev/null)" ]; then
    echo "No Plymouth theme assets found in assets/plymouth/skyrim/ — nothing to install." >&2
    echo "See assets/plymouth/SPEC.md for what's expected there." >&2
    exit 1
fi

if ! command -v plymouth-set-default-theme >/dev/null 2>&1; then
    echo "plymouth-set-default-theme not found — is Plymouth installed on this system?" >&2
    exit 1
fi

echo "[skyrim-theme] Installing Plymouth theme to $DEST"
mkdir -p "$DEST"
cp -r "$ASSET_DIR"/* "$DEST"/

echo "[skyrim-theme] Setting as default Plymouth theme and rebuilding initramfs..."
plymouth-set-default-theme -R skyrim

echo "[skyrim-theme] Done. On an rpm-ostree system (Bazzite), this takes effect after your next"
echo "boot/deploy. To revert: sudo plymouth-set-default-theme -R <previous-theme>"
echo "(run 'plymouth-set-default-theme --list' to see available themes)."
