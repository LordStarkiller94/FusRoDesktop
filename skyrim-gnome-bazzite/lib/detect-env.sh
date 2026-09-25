#!/usr/bin/env bash
# lib/detect-env.sh
#
# Detects the environment this installer is running in and exports
# variables the other lib/install-*.sh scripts rely on. Sourced, not
# executed — every install script does `source "$LIB_DIR/detect-env.sh"`.

set -euo pipefail

# --- GNOME Shell version -----------------------------------------------
detect_gnome_version() {
    if command -v gnome-shell >/dev/null 2>&1; then
        gnome-shell --version | grep -oE '[0-9]+(\.[0-9]+)?' | head -n1
    else
        echo ""
    fi
}

# --- Session type (X11 vs Wayland) --------------------------------------
detect_session_type() {
    echo "${XDG_SESSION_TYPE:-unknown}"
}

# --- Is this Bazzite? -----------------------------------------------------
detect_is_bazzite() {
    if [ -f /usr/share/ublue-os/image-info.json ] && grep -qi bazzite /usr/share/ublue-os/image-info.json 2>/dev/null; then
        echo "true"
    elif grep -qi bazzite /etc/os-release 2>/dev/null; then
        echo "true"
    else
        echo "false"
    fi
}

# --- Is this rpm-ostree / image-based (Bazzite, Silverblue, Kinoite...) --
detect_is_ostree() {
    if command -v rpm-ostree >/dev/null 2>&1; then
        echo "true"
    else
        echo "false"
    fi
}

# --- Is the GNOME "User Themes" extension installed & enabled? -----------
detect_user_theme_extension() {
    local uuid="user-theme@gnome-shell-extensions.gcampax.github.com"
    if command -v gnome-extensions >/dev/null 2>&1; then
        if gnome-extensions list --enabled 2>/dev/null | grep -q "$uuid"; then
            echo "enabled"
        elif gnome-extensions list 2>/dev/null | grep -q "$uuid"; then
            echo "disabled"
        else
            echo "missing"
        fi
    else
        echo "unknown"
    fi
}

# --- Simple version compare: returns 0 if $1 >= $2 -------------------------
version_gte() {
    [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

# --- Simple version compare: returns 0 if $1 <= $2 -------------------------
version_lte() {
    [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" = "$1" ]
}

export GNOME_VERSION
export SESSION_TYPE
export IS_BAZZITE
export IS_OSTREE
export USER_THEME_EXT_STATE

GNOME_VERSION="$(detect_gnome_version)"
SESSION_TYPE="$(detect_session_type)"
IS_BAZZITE="$(detect_is_bazzite)"
IS_OSTREE="$(detect_is_ostree)"
USER_THEME_EXT_STATE="$(detect_user_theme_extension)"

if [ "${SKYRIM_THEME_DEBUG:-0}" = "1" ]; then
    echo "[detect-env] GNOME_VERSION=$GNOME_VERSION SESSION_TYPE=$SESSION_TYPE IS_BAZZITE=$IS_BAZZITE IS_OSTREE=$IS_OSTREE USER_THEME_EXT_STATE=$USER_THEME_EXT_STATE" >&2
fi
