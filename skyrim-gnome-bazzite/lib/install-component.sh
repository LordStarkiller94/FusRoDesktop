#!/usr/bin/env bash
# lib/install-component.sh
#
# Generic installer for any user-space component declared in the manifest.
# Handles: existence check, min/max GNOME version gate, required-extension
# gate, copying assets into place, and applying via gsettings where relevant.
#
# Usage: install_component <component_key>
#   e.g. install_component icons

install_component() {
    local key="$1"
    local asset_dir install_path requires_ext min_gnome max_gnome

    asset_dir="$(manifest_get "$key" asset_dir)"
    install_path="$(manifest_get "$key" install_path)"
    requires_ext="$(manifest_get "$key" requires_extension)"
    min_gnome="$(manifest_get "$key" min_gnome)"
    max_gnome="$(manifest_get "$key" max_gnome)"

    local full_asset_dir="$REPO_ROOT/$asset_dir"
    local full_install_path
    full_install_path="$(expand_path "$install_path")"

    # 1. Asset present at all?
    if [ ! -d "$full_asset_dir" ] || [ -z "$(ls -A "$full_asset_dir" 2>/dev/null)" ]; then
        warn "Skipping '$key' — no assets found in $asset_dir yet (see assets/README.md)."
        return 0
    fi

    # 2. GNOME version gate
    if [ -n "$min_gnome" ] && [ -n "$GNOME_VERSION" ]; then
        if ! version_gte "$GNOME_VERSION" "$min_gnome"; then
            warn "Skipping '$key' — needs GNOME >= $min_gnome, you have $GNOME_VERSION."
            return 0
        fi
    fi
    if [ -n "$max_gnome" ] && [ "$max_gnome" != "None" ] && [ -n "$GNOME_VERSION" ]; then
        if ! version_lte "$GNOME_VERSION" "$max_gnome"; then
            warn "Skipping '$key' — not yet verified compatible with GNOME $GNOME_VERSION (tested up to $max_gnome). Run with SKYRIM_THEME_FORCE=1 to try anyway."
            [ "${SKYRIM_THEME_FORCE:-0}" = "1" ] || return 0
        fi
    fi

    # 3. Required extension gate (currently only Shell theme uses this)
    if [ -n "$requires_ext" ] && [ "$requires_ext" != "null" ]; then
        case "$USER_THEME_EXT_STATE" in
            enabled) : ;;
            disabled)
                warn "Skipping '$key' — the 'User Themes' extension is installed but disabled. Enable it (gnome-extensions enable $requires_ext) and re-run 'ujust skyrim-theme-update'."
                return 0
                ;;
            missing|unknown)
                warn "Skipping '$key' — needs the GNOME 'User Themes' extension, which isn't installed. Get it from extensions.gnome.org, then re-run 'ujust skyrim-theme-update'."
                return 0
                ;;
        esac
    fi

    # 4. Copy into place
    mkdir -p "$(dirname "$full_install_path")"
    rm -rf "$full_install_path"
    cp -r "$full_asset_dir" "$full_install_path"
    ok "Installed '$key' -> $full_install_path"

    # 5. Apply via gsettings where we know how
    apply_component_setting "$key"
}

apply_component_setting() {
    local key="$1"
    local theme_name
    theme_name="$(basename "$(expand_path "$(manifest_get "$key" install_path)")")"

    command -v gsettings >/dev/null 2>&1 || return 0

    case "$key" in
        icons)
            gsettings set org.gnome.desktop.interface icon-theme "$theme_name" 2>/dev/null || true ;;
        cursors)
            gsettings set org.gnome.desktop.interface cursor-theme "$theme_name" 2>/dev/null || true ;;
        gtk_theme)
            gsettings set org.gnome.desktop.interface gtk-theme "$theme_name" 2>/dev/null || true ;;
        shell_theme)
            gsettings set org.gnome.shell.extensions.user-theme name "$theme_name" 2>/dev/null || true ;;
        wallpapers)
            local wp
            wp="$(find "$(expand_path "$(manifest_get wallpapers install_path)")" -iname 'skyrim-desktop*' | head -n1)"
            if [ -n "$wp" ]; then
                gsettings set org.gnome.desktop.background picture-uri "file://$wp" 2>/dev/null || true
                gsettings set org.gnome.desktop.background picture-uri-dark "file://$wp" 2>/dev/null || true
            fi
            local lock
            lock="$(find "$(expand_path "$(manifest_get wallpapers install_path)")" -iname 'skyrim-lockscreen*' | head -n1)"
            if [ -n "$lock" ] && command -v busctl >/dev/null 2>&1; then
                gsettings set org.gnome.desktop.screensaver picture-uri "file://$lock" 2>/dev/null || true
            fi
            ;;
    esac
}
