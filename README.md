# Nocture

Personal Hyprland rice for Arch Linux. Wallpaper-reactive theming via [matugen](https://github.com/InioX/matugen), Quickshell as the live bar/shell, Hyprland (Lua config) as the compositor.

## Stack

| Piece | Tool |
|---|---|
| Compositor | Hyprland (Lua config via `hyprlang`'s Lua support) |
| Bar / shell | [Quickshell](https://quickshell.outfoxxed.me/) ([ML4W](https://github.com/mylinuxforwork/quickshell)-based) — *not tracked in this repo, see below* |
| Terminal | Kitty |
| File manager | Thunar (custom "Nebula" GTK3 theme) |
| Launcher | Rofi ([adi1090x](https://github.com/adi1090x/rofi-collection) launcher pack, `type-1/style-3`) |
| Notifications | SwayNC |
| Lock / idle | hyprlock / hypridle |
| Wallpaper | waypaper + swww (`awww-daemon`), per-monitor effects in `hypr/effects/wallpaper/` |
| Color engine | matugen (Material You palette extraction from the current wallpaper) |

## Live theming — how matugen wires everything together

Changing the wallpaper in waypaper is the trigger for the whole theme. Its `post_command` (`~/.config/waypaper/config.ini`) runs:

```
matugen image "$wallpaper" --source-color-index 0
```

matugen reads `~/.config/matugen/config.toml`, extracts a Material You palette from the image, and for every `[templates.*]` entry renders an input template into an output file, then optionally runs a `post_hook` to make the running app pick up the new colors live:

| Template | Output | Reload mechanism |
|---|---|---|
| `hyprland` | `hypr/borders.lua` | `hyprctl reload` |
| `kitty` | `kitty/theme.conf` | `kitty @ set-colors --all …` |
| `swaync` | `swaync/colors.css` | `swaync-client -R && swaync-client -rs` |
| `gtk4` | `gtk-4.0/colors.css` | — (no live consumer yet) |
| `rofi` | `rofi/colors/matugen.rasi` | none needed — rofi reads the file fresh on every launch |
| `zathura` | `zathura/zathurarc` | — |
| `hyprlock` | `hypr/colors.conf` | picked up on next lock |
| `quickshell` | `~/.config/ml4w/colors/colors.json` | `qs ipc call theme-manager reload` |

Two things are **not** matugen-driven, on purpose:

- **Thunar/GTK3 ("Nebula" theme)** — hand-authored, hardcoded palette in `gtk-3.0/gtk.css`. `@import` in GTK3 CSS silently fails to resolve, so everything has to be inlined; there's no matugen template for it.
- **Waybar** — see below, it's a leftover from before the switch to Quickshell.

## Repo layout

Only these directories are tracked (see `.gitignore` — everything else under `~/.config` is ignored by default):

```
hypr/       Hyprland Lua config, hyprlock, hypridle, monitors, wallpaper effects, helper scripts
waybar/     legacy bar config — not currently running, kept for reference (see note below)
swaync/     notification center config + two swappable themes (glass / modern)
kitty/      terminal config + matugen-generated theme
gtk-3.0/    Thunar's "Nebula" theme (static, not matugen)
rofi/       adi1090x launcher pack + a dozen swappable color schemes, matugen.rasi is live
```

Generated/cache files that matugen rewrites on every wallpaper change are gitignored (`hypr/colors.conf`, `hypr/colors.lua`, `waybar/colors/`) so they don't create noisy diffs.

### Note on Waybar vs Quickshell

This rice originally themed Waybar, and that config is still tracked here. It has since moved to **Quickshell** (an ML4W-based shell — Welcome/Power/Sidebar/Calendar/Wallpaper apps + status bar + a `CustomTheme/Theme.qml` that matugen's `theme-manager reload` IPC call refreshes). Quickshell itself lives at `~/.config/quickshell` and is **not part of this repo** — it's a separate, larger third-party config rather than something authored here. The Waybar files are left in place in case of a rollback, but `waybar/colors.css` is stale (matugen no longer has a `[templates.waybar]` entry) and the process isn't running day to day.

Similarly, `wlogout` (the old logout screen, launched from a Waybar button) has been superseded by Quickshell's `PowerApp` and isn't wired to a keybind anymore.

## Setting this up on a new machine

1. Install Hyprland, and the pieces above: `kitty`, `thunar`, `swaync`, `rofi`, `matugen`, `waypaper`, `swww`, `hypridle`, `hyprlock`, `brightnessctl`, `nm-applet`, Papirus icon theme, a Nerd Font (JetBrainsMono Nerd Font).
2. Quickshell isn't in this repo — grab the [ML4W quickshell config](https://github.com/mylinuxforwork/quickshell) separately if you want the live bar; otherwise Waybar's config here still works as a fallback (`waybar/style.css` + `waybar/config`), just re-add a `[templates.waybar]` entry in `matugen/config.toml` to bring it back under live theming.
3. Clone this repo directly into `~/.config` (or clone elsewhere and copy the tracked directories in):
   ```bash
   git clone git@github.com:FilipKlaic/Nocture.git ~/.config
   ```
4. Set up `~/.config/matugen/config.toml` and `~/.config/waypaper/config.ini` (not tracked here — machine-specific paths) to wire the wallpaper → matugen → apps pipeline described above.
5. Pick a wallpaper in waypaper once — that first run generates `hypr/colors.conf`, `hypr/colors.lua`, etc. and themes everything.

## Credits

- Rofi launcher pack: [adi1090x/rofi-collection](https://github.com/adi1090x/rofi-collection)
- Quickshell base: [mylinuxforwork/quickshell](https://github.com/mylinuxforwork/quickshell) (ML4W)
- Color engine: [InioX/matugen](https://github.com/InioX/matugen)
