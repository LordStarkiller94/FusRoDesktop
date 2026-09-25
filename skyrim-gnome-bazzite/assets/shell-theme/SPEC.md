# Shell theme — `assets/shell-theme/Skyrim-Shell/`

Themes the GNOME Shell top bar, overview, app grid, and system menus. This is
the **most version-fragile** component (see `docs/COMPATIBILITY.md`) — the
Shell's internal DOM/selector structure changes across releases, so this
file needs the most maintenance over time. Requires the `User Themes`
GNOME Shell extension to be installed and enabled — the installer checks
for this and skips gracefully if it's missing (see
`lib/install-component.sh`).

Required structure:

```
Skyrim-Shell/
├── gnome-shell.css
└── assets/                # backgrounds, borders, icons the CSS references
```

Approach:
1. Start from GNOME's own stylesheet for your target version
   (`/usr/share/gnome-shell/theme/gnome-shell.css` on a running system, or
   the `gnome-shell` source tree on GitHub for the matching version tag) —
   don't write shell CSS from a blank file, the selector set is huge.
2. Override only what needs Skyrim styling: `#panel` (top bar — parchment
   texture + iron trim), `.overview` background, `.workspace-thumbnails`,
   `.app-well-app` hover states.
3. Test on the *exact* GNOME Shell version you're targeting — this file
   should carry a comment at the top noting which GNOME version it was
   built against, e.g. `/* built against GNOME Shell 46 */`, so future
   maintainers know at a glance if it's stale.

The installer copies this to `~/.local/share/themes/Skyrim-Shell` and sets
it via `gsettings set org.gnome.shell.extensions.user-theme name Skyrim-Shell`.
