#!/usr/bin/env bash
# lib/install-grub.sh — installs the Skyrim GRUB boot menu theme.
# Run with sudo, from a cloned copy of the repo. Not part of install.sh.
#
#   sudo bash lib/install-grub.sh
#
# NOTE: On Bazzite/rpm-ostree, /boot is managed by the system image and GRUB
# config lives partly outside the writable tree. This script installs the
# theme files and appends a GRUB_THEME line to /etc/default/grub, then
# regenerates the config the way Bazzite/Fedora expects. If a future Bazzite
# release changes how /boot is managed, this is the first script to check —
# see docs/COMPATIBILITY.md.

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "This script needs root (it writes to /boot). Run with sudo." >&2
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSET_DIR="$REPO_ROOT/assets/plymouth/grub"
DEST="/boot/grub2/themes/skyrim"
GRUB_DEFAULT="/etc/default/grub"

if [ ! -d "$ASSET_DIR" ] || [ -z "$(ls -A "$ASSET_DIR" 2>/dev/null)" ]; then
    echo "No GRUB theme assets found in assets/plymouth/grub/ — nothing to install." >&2
    exit 1
fi

echo "[skyrim-theme] Installing GRUB theme to $DEST"
mkdir -p "$DEST"
cp -r "$ASSET_DIR"/* "$DEST"/

if [ -f "$GRUB_DEFAULT" ]; then
    if grep -q '^GRUB_THEME=' "$GRUB_DEFAULT"; then
        sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$DEST/theme.txt\"|" "$GRUB_DEFAULT"
    else
        echo "GRUB_THEME=\"$DEST/theme.txt\"" >> "$GRUB_DEFAULT"
    fi
else
    echo "GRUB_THEME=\"$DEST/theme.txt\"" > "$GRUB_DEFAULT"
fi

echo "[skyrim-theme] Regenerating GRUB config..."
if command -v grub2-mkconfig >/dev/null 2>&1; then
    grub2-mkconfig -o /boot/grub2/grub.cfg
elif command -v update-grub >/dev/null 2>&1; then
    update-grub
else
    echo "Couldn't find grub2-mkconfig or update-grub — regenerate your GRUB config manually." >&2
fi

echo "[skyrim-theme] Done. Effective on next reboot. To revert, remove the GRUB_THEME line"
echo "from $GRUB_DEFAULT and regenerate the config again."
