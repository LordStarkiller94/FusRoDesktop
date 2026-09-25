# ujust/skyrim.just
#
# Drop this into your ujust custom-recipes include so `ujust skyrim-theme`
# works like any other Bazzite command. Bazzite loads extra .just files from
# ~/.local/bin/ujust/*.just (or /etc/ujust/ system-wide) — see:
# https://universal-blue.discourse.group/  (ujust custom commands)
#
# Quick setup:
#   mkdir -p ~/.local/bin/ujust
#   cp ujust/skyrim.just ~/.local/bin/ujust/
#   ujust --list | grep skyrim

SKYRIM_REPO := env_var_or_default("SKYRIM_THEME_REPO", "https://github.com/<you>/skyrim-gnome-bazzite.git")
SKYRIM_DIR := env_var_or_default("SKYRIM_THEME_DIR", home_dir() / ".local/share/skyrim-gnome-bazzite")

# Install the Skyrim GNOME theme pack
[group('skyrim-theme')]
skyrim-theme:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -d "{{SKYRIM_DIR}}" ]; then
        echo "Cloning skyrim-gnome-bazzite..."
        git clone --depth 1 "{{SKYRIM_REPO}}" "{{SKYRIM_DIR}}"
    fi
    bash "{{SKYRIM_DIR}}/install.sh"

# Re-sync the Skyrim theme after a GNOME/Bazzite update
[group('skyrim-theme')]
skyrim-theme-update:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -d "{{SKYRIM_DIR}}" ]; then
        echo "Not installed yet — run 'ujust skyrim-theme' first." >&2
        exit 1
    fi
    echo "Pulling latest theme pack..."
    git -C "{{SKYRIM_DIR}}" pull --ff-only
    bash "{{SKYRIM_DIR}}/install.sh"

# Remove the Skyrim theme and restore your previous desktop settings
[group('skyrim-theme')]
skyrim-theme-remove:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -d "{{SKYRIM_DIR}}" ]; then
        echo "Not installed." >&2
        exit 0
    fi
    bash "{{SKYRIM_DIR}}/lib/uninstall.sh"

# Install the Skyrim Plymouth boot splash (needs sudo, separate from the theme itself)
[group('skyrim-theme')]
skyrim-theme-boot:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -d "{{SKYRIM_DIR}}" ]; then
        echo "Run 'ujust skyrim-theme' first." >&2
        exit 1
    fi
    sudo bash "{{SKYRIM_DIR}}/lib/install-plymouth.sh"
    sudo bash "{{SKYRIM_DIR}}/lib/install-grub.sh"
