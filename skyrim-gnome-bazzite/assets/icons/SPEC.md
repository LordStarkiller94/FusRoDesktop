# Icons — `assets/icons/Skyrim-Icons/`

A standard freedesktop.org icon theme. Easiest path: fork an existing
well-structured icon theme (e.g. Papirus, or a template from
`freedesktop.org`'s icon theme spec) and re-skin the folder/app icons rather
than building the directory structure from scratch.

Required structure:

```
Skyrim-Icons/
├── index.theme          # [Icon Theme] name, comment, Inherits=Adwaita (or Papirus)
├── 16x16/ 22x22/ 24x24/ 32x32/ 48x48/ 64x64/ 128x128/ 256x256/ scalable/
│   ├── apps/
│   ├── places/
│   ├── devices/
│   ├── mimetypes/
│   └── status/
```

Minimum viable set to look "themed" without doing every single icon:
- `places/` — folder icons (the highest-visibility win)
- A handful of common `apps/` icons (Files, Terminal, Settings, Browser)
- Leave everything else inheriting from a fallback theme via `Inherits=` in
  `index.theme` — GNOME will use the fallback for anything you haven't made.

`index.theme` minimum:

```ini
[Icon Theme]
Name=Skyrim-Icons
Comment=Skyrim-themed icon set
Inherits=Papirus,Adwaita,hicolor
Directories=16x16/apps,...
```

The installer copies this whole folder to
`~/.local/share/icons/Skyrim-Icons` verbatim and sets it via
`gsettings set org.gnome.desktop.interface icon-theme Skyrim-Icons`.
