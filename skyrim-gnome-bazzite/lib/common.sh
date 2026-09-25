#!/usr/bin/env bash
# lib/common.sh
# Shared helpers: logging, manifest field lookup, safe backup of prior settings.
# Sourced by install.sh and every lib/install-*.sh.

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
MANIFEST="${MANIFEST:-$REPO_ROOT/theme.manifest.yaml}"
STATE_DIR="${STATE_DIR:-$HOME/.local/state/skyrim-theme}"

# --- logging ---------------------------------------------------------------
c_reset='\033[0m'; c_blue='\033[1;34m'; c_yellow='\033[1;33m'; c_red='\033[1;31m'; c_green='\033[1;32m'
log()  { echo -e "${c_blue}[skyrim-theme]${c_reset} $*"; }
warn() { echo -e "${c_yellow}[skyrim-theme]${c_reset} $*" >&2; }
err()  { echo -e "${c_red}[skyrim-theme]${c_reset} $*" >&2; }
ok()   { echo -e "${c_green}[skyrim-theme]${c_reset} $*"; }

# --- manifest lookup ---------------------------------------------------------
# We deliberately avoid requiring PyYAML (not guaranteed present). The manifest
# is a small, flat-ish YAML file we control the shape of, so a targeted awk
# lookup of "component_name:" blocks is reliable enough. If PyYAML IS present,
# prefer it for robustness.
#
# Usage: manifest_get <component> <field>
#   e.g. manifest_get shell_theme requires_extension
manifest_get() {
    local component="$1" field="$2"
    if python3 -c "import yaml" >/dev/null 2>&1; then
        python3 - "$MANIFEST" "$component" "$field" <<'PYEOF'
import sys, yaml
path, component, field = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path) as f:
    data = yaml.safe_load(f)
val = data.get("components", {}).get(component, {}).get(field, "")
print("" if val is None else val)
PYEOF
    else
        awk -v comp="$component" -v field="$field" '
            $0 ~ "^  "comp":" { in_block=1; next }
            in_block && /^  [a-zA-Z]/ { in_block=0 }
            in_block && $0 ~ "^    "field":" {
                sub("^    "field":[ ]*", "");
                gsub(/^"|"$/, "");
                print;
                exit
            }
        ' "$MANIFEST"
    fi
}

manifest_theme_field() {
    local field="$1"
    if python3 -c "import yaml" >/dev/null 2>&1; then
        python3 - "$MANIFEST" "$field" <<'PYEOF'
import sys, yaml
path, field = sys.argv[1], sys.argv[2]
with open(path) as f:
    data = yaml.safe_load(f)
val = data.get("theme", {}).get(field, "")
print("" if val is None else val)
PYEOF
    else
        awk -v field="$field" '
            $0 ~ "^theme:" { in_block=1; next }
            in_block && /^[a-zA-Z]/ { in_block=0 }
            in_block && $0 ~ "^  "field":" {
                sub("^  "field":[ ]*", "");
                gsub(/^"|"$/, "");
                print;
                exit
            }
        ' "$MANIFEST"
    fi
}

# --- resolve ~ in a manifest install_path value -----------------------------
expand_path() {
    local p="$1"
    eval echo "$p"
}

# --- prior-settings backup, so uninstall can restore ------------------------
backup_current_settings() {
    mkdir -p "$STATE_DIR"
    local out="$STATE_DIR/previous-settings.json"
    if [ -f "$out" ]; then
        return 0   # never clobber an existing backup — that's the user's true "before"
    fi
    command -v gsettings >/dev/null 2>&1 || { warn "gsettings not found, skipping settings backup"; return 0; }
    python3 - "$out" <<'PYEOF'
import json, subprocess, sys
out = sys.argv[1]
keys = {
    "icon-theme": ["org.gnome.desktop.interface", "icon-theme"],
    "cursor-theme": ["org.gnome.desktop.interface", "cursor-theme"],
    "gtk-theme": ["org.gnome.desktop.interface", "gtk-theme"],
    "shell-theme": ["org.gnome.shell.extensions.user-theme", "name"],
    "background-uri": ["org.gnome.desktop.background", "picture-uri"],
    "background-uri-dark": ["org.gnome.desktop.background", "picture-uri-dark"],
}
result = {}
for label, (schema, key) in keys.items():
    try:
        val = subprocess.run(["gsettings", "get", schema, key], capture_output=True, text=True, timeout=5)
        result[label] = val.stdout.strip().strip("'") if val.returncode == 0 else None
    except Exception:
        result[label] = None
with open(out, "w") as f:
    json.dump(result, f, indent=2)
PYEOF
    ok "Backed up your current theme settings to $out"
}
