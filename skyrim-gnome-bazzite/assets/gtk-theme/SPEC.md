# GTK theme — `assets/gtk-theme/Skyrim-Gtk/`

A GTK3 theme (GTK4/libadwaita apps mostly ignore full theme swapping — see
`docs/COMPATIBILITY.md`). Easiest path: fork a well-maintained GTK3 theme
(e.g. one built on `gtk-theme-config` / a Sass-based theme like Orchis or
Materia) and re-skin the color variables, then compile the Sass to CSS.

Required structure:

```
Skyrim-Gtk/
├── index.theme
├── gtk-3.0/
│   ├── gtk.css
│   ├── gtk-dark.css
│   └── assets/           # any images/svgs the CSS references
└── gtk-4.0/               # optional: accent/border override only, see below
    └── gtk.css
```

`index.theme`:

```ini
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=Skyrim-Gtk
Comment=Skyrim-themed GTK3 theme
[X-GNOME-Metatheme]
GtkTheme=Skyrim-Gtk
MetacityTheme=Skyrim-Gtk
IconTheme=Skyrim-Icons
CursorTheme=Skyrim-Cursors
```

Palette starting point (adjust to taste): parchment/aged-leather
backgrounds, iron/steel greys for chrome, a single gold/bronze accent
(#a87b32-ish) for selection highlights and focus rings — keep contrast
readable, this isn't just a mood board, people read text in it all day.

The installer copies this to `~/.local/share/themes/Skyrim-Gtk` and sets it
via `gsettings set org.gnome.desktop.interface gtk-theme Skyrim-Gtk`.
