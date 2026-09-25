# Wallpapers — `assets/wallpapers/`

Two files, exact naming matters (the installer finds them by prefix):

```
wallpapers/
├── skyrim-desktop.jpg      # or .png — desktop background
└── skyrim-lockscreen.jpg   # or .png — lock/login screen background
```

Recommended minimum resolution: 3840×2160 (scales down cleanly to anything
smaller; GNOME won't upscale gracefully if you go too low-res). Landscape
orientation.

The installer copies the whole folder to
`~/.local/share/backgrounds/skyrim/` and sets both
`org.gnome.desktop.background` (`picture-uri` / `picture-uri-dark`) and
`org.gnome.desktop.screensaver` `picture-uri` via `gsettings`.

If you want light/dark variants, add `skyrim-desktop-dark.jpg` — this isn't
wired up in `lib/install-component.sh` yet (it currently applies the same
image to both), that's a good first enhancement if someone wants to
contribute one.
