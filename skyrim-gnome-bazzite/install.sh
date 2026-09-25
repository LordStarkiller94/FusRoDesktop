#!/usr/bin/env bash
# install.sh — the user-friendly entry point.
#
#   curl -fsSL https://raw.githubusercontent.com/<you>/skyrim-gnome-bazzite/main/install.sh | bash
#
# Installs only user-space, no-sudo components (icons, cursors, wallpapers,
# GTK theme, Shell theme if compatible). Boot theming (Plymouth/GRUB) is
# intentionally separate — see README.md.

set -euo pipefail

# --- Resolve repo root, self-cloning if run via curl|bash -------------------
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
    REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    # We were piped in (curl|bash) — no local copy of the repo yet.
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT
    echo "[skyrim-theme] Downloading repository..."
    if command -v git >/dev/null 2>&1; then
        git clone --depth 1 https://github.com/<you>/skyrim-gnome-bazzite.git "$TMP_DIR/repo"
    else
        curl -fsSL https://github.com/<you>/skyrim-gnome-bazzite/archive/refs/heads/main.tar.gz | tar -xz -C "$TMP_DIR"
        mv "$TMP_DIR"/skyrim-gnome-bazzite-* "$TMP_DIR/repo"
    fi
    REPO_ROOT="$TMP_DIR/repo"
fi
export REPO_ROOT

# shellcheck source=lib/common.sh
source "$REPO_ROOT/lib/common.sh"
# shellcheck source=lib/detect-env.sh
source "$REPO_ROOT/lib/detect-env.sh"
# shellcheck source=lib/install-component.sh
source "$REPO_ROOT/lib/install-component.sh"

theme_name="$(manifest_theme_field name)"
theme_version="$(manifest_theme_field version)"

echo
log "$(printf '%s' "$theme_name") theme pack v$theme_version"
log "GNOME Shell: ${GNOME_VERSION:-unknown} | Session: $SESSION_TYPE | Bazzite: $IS_BAZZITE | ostree: $IS_OSTREE"
echo

if [ -z "$GNOME_VERSION" ]; then
    warn "Couldn't detect a GNOME Shell version — are you running this inside a GNOME session?"
    warn "Continuing anyway; components that need a version check will be skipped."
fi

backup_current_settings

for component in icons cursors wallpapers gtk_theme shell_theme; do
    install_component "$component"
done

echo
ok "Done. Some changes (Shell theme, GTK4 apps) may need a log out/in to fully apply."
log "Boot theming (Plymouth splash + GRUB) is opt-in and needs sudo — see:"
log "  sudo bash lib/install-plymouth.sh   (from a cloned copy of this repo)"
log "  sudo bash lib/install-grub.sh"
echo
log "To undo everything: bash lib/uninstall.sh   (or: ujust skyrim-theme-remove)"
