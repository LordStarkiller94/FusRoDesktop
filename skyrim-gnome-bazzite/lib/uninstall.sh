#!/usr/bin/env bash
# lib/uninstall.sh — removes installed files and restores prior gsettings.

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export REPO_ROOT
source "$REPO_ROOT/lib/common.sh"

STATE_FILE="$STATE_DIR/previous-settings.json"

log "Removing installed Skyrim theme files..."
for key in icons cursors gtk_theme shell_theme wallpapers; do
    install_path="$(manifest_get "$key" install_path)"
    full_path="$(expand_path "$install_path")"
    if [ -e "$full_path" ]; then
        rm -rf "$full_path"
        log "Removed $full_path"
    fi
done

if [ -f "$STATE_FILE" ] && command -v gsettings >/dev/null 2>&1; then
    log "Restoring your previous theme settings..."
    python3 - "$STATE_FILE" <<'PYEOF'
import json, subprocess, sys
with open(sys.argv[1]) as f:
    prev = json.load(f)
mapping = {
    "icon-theme": ["org.gnome.desktop.interface", "icon-theme"],
    "cursor-theme": ["org.gnome.desktop.interface", "cursor-theme"],
    "gtk-theme": ["org.gnome.desktop.interface", "gtk-theme"],
    "shell-theme": ["org.gnome.shell.extensions.user-theme", "name"],
    "background-uri": ["org.gnome.desktop.background", "picture-uri"],
    "background-uri-dark": ["org.gnome.desktop.background", "picture-uri-dark"],
}
for label, (schema, key) in mapping.items():
    val = prev.get(label)
    if val:
        subprocess.run(["gsettings", "set", schema, key, val], check=False)
PYEOF
    ok "Previous settings restored."
else
    warn "No saved previous settings found — set your theme back manually in GNOME Settings/Tweaks."
fi

ok "Uninstall complete."
