# Skyrim GNOME Theme Pack (for Bazzite)

A full-desktop Skyrim overhaul for **Bazzite** running **GNOME** — icons, cursors,
GTK theming, Shell theming, wallpapers, and boot experience (Plymouth + GRUB) —
built to keep working as GNOME and Bazzite update out from under it.

This repo is also the **first build on a reusable engine**. The installer,
version-detection logic, and update tooling live in [`lib/`](lib/) and know
nothing Skyrim-specific — all theme content lives in [`theme.manifest.yaml`](theme.manifest.yaml)
and [`assets/`](assets/). Future game themes (Elden Ring, Zelda, whatever's next)
are meant to fork this repo, swap the manifest + assets, and reuse everything else.

## Install (the easy way)

```bash
curl -fsSL https://raw.githubusercontent.com/<you>/skyrim-gnome-bazzite/main/install.sh | bash
```

The installer:
1. Detects your GNOME Shell version, session type (X11/Wayland), and whether
   you're on Bazzite vs. generic Fedora Atomic/other GNOME.
2. Installs icons, cursors, GTK theme, wallpapers, and (if compatible) the
   Shell theme into `~/.local/share/` and `~/.config/` — **no sudo, no reboot,
   nothing touches your OS image.**
3. Skips anything that isn't compatible with your GNOME version and tells you
   why, instead of half-breaking your desktop.
4. Boot theming (Plymouth splash + GRUB) is **not** included in the default
   run — see [Boot Theming](#boot-theming-optional--needs-sudo) below.

## Install (native Bazzite way)

If you'd rather this feel like a built-in part of the OS:

```bash
ujust skyrim-theme        # install
ujust skyrim-theme-update # re-sync after a GNOME/Bazzite update
ujust skyrim-theme-remove # uninstall, restores previous theme settings
```

See [`ujust/skyrim.just`](ujust/skyrim.just) for what these wrap.

## What gets themed

| Component | Status | Risk |
|---|---|---|
| Icons | ✅ Always installed | None — plain XDG icon theme |
| Cursors | ✅ Always installed | None — plain XDG cursor theme |
| Wallpapers + lock screen | ✅ Always installed | None |
| GTK3 theme | ✅ Installed if compatible | Low |
| GTK4 / libadwaita | ⚠️ Partial (accent color + `gtk.css` override) | GTK4 apps largely ignore full theming by design |
| GNOME Shell (top bar, overview) | ⚠️ Installed only if `User Themes` extension is present & compatible | Shell theming is the most version-fragile part of GNOME |
| Plymouth boot splash | 🔒 Opt-in, separate script, needs sudo | Touches boot chain |
| GRUB theme | 🔒 Opt-in, separate script, needs sudo | Touches bootloader |

## Boot theming (optional, needs sudo)

```bash
sudo bash lib/install-plymouth.sh
sudo bash lib/install-grub.sh
```

These are kept out of the one-line installer on purpose — nothing that needs
root runs without you explicitly asking for it.

## Staying current with GNOME & Bazzite

See [`docs/COMPATIBILITY.md`](docs/COMPATIBILITY.md) for the tested version
matrix. [`.github/workflows/compat-check.yml`](.github/workflows/compat-check.yml)
runs weekly against the latest Bazzite container image and the latest GNOME
Shell available in it, and opens an issue automatically if something in the
manifest's compatibility claims no longer holds. It doesn't auto-fix breakage
(that still needs a human look at what GNOME changed), but you'll know the
same day something breaks, not months later.

## Uninstall

```bash
ujust skyrim-theme-remove
# or, without ujust:
bash lib/uninstall.sh
```

Restores your previous GTK/icon/cursor/shell theme settings (saved to
`~/.local/state/skyrim-theme/previous-settings.json` on first install).

## Repo layout

```
theme.manifest.yaml    # theme metadata + declared GNOME version compatibility
install.sh              # entry point — the curl|bash script
lib/                     # reusable engine (detection, per-component installers, uninstall)
ujust/skyrim.just        # Bazzite ujust recipe wrapper
assets/                  # the actual Skyrim art — see assets/README.md for specs
docs/COMPATIBILITY.md    # tested version matrix
.github/workflows/       # scheduled compatibility CI
```

## Contributing an asset

Nothing here generates icons, cursors, or shell CSS for you — those are hand
or AI-image-tool authored. Each `assets/<component>/` folder has its own
`SPEC.md` with exact file names, sizes, and formats the installer expects.
