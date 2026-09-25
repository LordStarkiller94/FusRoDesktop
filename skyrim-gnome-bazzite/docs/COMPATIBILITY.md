# Compatibility matrix

This table is maintained alongside `theme.manifest.yaml`'s `compatibility`
block. The weekly CI job (`.github/workflows/compat-check.yml`) checks the
"Latest Bazzite" row automatically and opens an issue when it drifts;
everything else here is updated by hand when verified.

| GNOME Shell | Bazzite stream | Icons | Cursors | Wallpapers | GTK theme | Shell theme | Notes |
|---|---|---|---|---|---|---|---|
| 48 | latest | ✅ | ✅ | ✅ | ✅ | ⚠️ untested | Verify once assets exist |
| 46 | stable | ✅ | ✅ | ✅ | ✅ | ✅ | Baseline target |
| 42 | — | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | `min_gnome` floor in manifest |

Legend: ✅ verified working · ⚠️ untested/partial · ❌ known broken

## Known fragile points

- **Shell theme (`assets/shell-theme/`)** — GNOME Shell's internal CSS
  structure changes most releases. This is the component most likely to
  need per-version fixes. The `User Themes` extension itself
  (`user-theme@gnome-shell-extensions.gcampax.github.com`) is maintained
  upstream by the GNOME Shell extensions team, but our theme's CSS still has
  to match whatever selectors that GNOME version's Shell actually renders.
- **GTK4 / libadwaita** — GTK4 apps deliberately resist full re-skinning by
  design (Adwaita + accent color is the intended customization surface).
  `lib/install-component.sh` installs a `gtk-theme` for GTK3 apps normally;
  GTK4 gets, at most, a `~/.config/gtk-4.0/gtk.css` accent/border override —
  don't expect GTK4 apps to look "Skyrim-skinned" the way GTK3 ones will.
- **Boot theming** — Plymouth theme format has been stable for a long time,
  but on an rpm-ostree system like Bazzite, exactly how `/boot` is managed
  can shift between releases. If `lib/install-plymouth.sh` or
  `lib/install-grub.sh` starts failing, that's the first place to check
  against current Bazzite documentation.

## Updating this file

1. Run `bash install.sh` on the GNOME/Bazzite version in question.
2. Note what installed cleanly vs. what the installer skipped and why.
3. Update the table row and, if appropriate, bump
   `theme.manifest.yaml`'s `tested_max` / component `max_gnome` values.
