# Boot theming — `assets/plymouth/`

Two separate sub-themes, installed by two separate opt-in sudo scripts
(`lib/install-plymouth.sh`, `lib/install-grub.sh`) — neither runs as part
of the default `install.sh`.

## `plymouth/skyrim/` — boot splash

Standard Plymouth "two-step" theme structure:

```
skyrim/
├── skyrim.plymouth        # [Plymouth Theme] metadata + ModuleName=script
├── skyrim.script           # Plymouth boot script (progress bar, logo animation)
└── *.png                   # logo/background frames the script references
```

Keep the script simple and fast — this renders very early in boot with
minimal resources available; elaborate animations can visibly stutter.
A logo fade-in + a themed progress bar is plenty.

## `plymouth/grub/` — GRUB boot menu

Standard GRUB2 theme structure:

```
grub/
├── theme.txt               # layout: fonts, colors, positions
├── background.png
└── *.png                   # icons for boot entries, selection highlight, etc.
```

Background image should match the aspect ratio of common boot resolutions
(1920×1080 is a safe default — GRUB doesn't do dynamic scaling as gracefully
as a desktop compositor).

## Why these are separate from the main installer

Both write outside `$HOME` (`/usr/share/plymouth/...`, `/boot/grub2/...`)
and regenerate boot config (`plymouth-set-default-theme -R`, `grub2-mkconfig`).
On an rpm-ostree system like Bazzite, exactly how `/boot` is writable can
shift between releases — this is the component most likely to need
maintenance if Bazzite changes its boot management approach. Check
`docs/COMPATIBILITY.md` first if these scripts start failing after a
Bazzite update.
