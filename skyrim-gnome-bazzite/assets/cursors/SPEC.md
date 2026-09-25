# Cursors — `assets/cursors/Skyrim-Cursors/`

A standard Xcursor theme. Build with `xcursorgen` from PNG frames + `.cursor`
config files, or reskin an existing open cursor theme (e.g. a sword/dagger
tip for the default pointer, an Aetherium-style loading spinner for "wait").

Required structure:

```
Skyrim-Cursors/
├── cursors/              # compiled Xcursor binaries (output of xcursorgen)
│   ├── default
│   ├── pointer
│   ├── text
│   ├── wait
│   └── ...
└── index.theme
```

`index.theme`:

```ini
[Icon Theme]
Name=Skyrim-Cursors
Comment=Skyrim-themed cursor set
Inherits=Adwaita
```

Minimum viable set: `default`, `pointer`, `text`, `wait` — the four cursors
a user sees 95% of the time. Everything else falls back to `Inherits=`.

The installer copies this to `~/.local/share/icons/Skyrim-Cursors` and sets
it via `gsettings set org.gnome.desktop.interface cursor-theme Skyrim-Cursors`.
