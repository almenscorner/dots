# dots-hyprland (tobias fork)

> My personal Hyprland dotfiles, based on [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland).

![screenshot placeholder](.github/screenshot.png)

## What's different from upstream

### Bar
- **Floating pill style** — bar floats with rounded corners, drop shadow, no background fill (`cornerStyle: 1`)
- **Thermal pill** — CPU (k10temp hwmon) and GPU (nvidia-smi) temperatures; icons shift color from theme primary → amber → red by temp
- **Network speed pill** — live ↓/↑ KB/s from `/proc/net/dev`, green/red arrows
- **Cava waveform** — audio waveform visualizer in the media pill
- **Emoji weather** — weather widget shows emoji + temperature
- **Colored workspace icons** — app icons in workspaces are full color, not monochrome
- **8px inter-pill spacing** — more breathing room between all bar segments

### Desktop widgets
A fixed widget panel in the top-right corner of the desktop with: Clock, Calendar (with Swedish public holidays), Weather, Media player, Volume, Disk usage, System info, App launcher, Quote of the day.

### Lock screen
- Uses Quickshell's built-in lock surface (not hyprlock)

### Screen recording
- Switched from `wf-recorder` to `gpu-screen-recorder`

### Video wallpaper
- Fixed mpvpaper flags: `loop-file=inf`, `video-sync=desync`

### Hyprland
- Flat mouse acceleration (`force_no_accel = true`)
- Active window opacity 95%, inactive 90%
- Rainbow color scheme with wallpaper-based theming

## Stack

| Component | Choice |
|-----------|--------|
| WM | Hyprland |
| Shell | Quickshell (ii panel family) |
| Terminal | kitty |
| Fonts | Inter · JetBrains Mono NF · Space Grotesk · Readex Pro |
| Screen recorder | gpu-screen-recorder |
| Lockscreen | Quickshell lock surface |

## Installation

Follow the [upstream installation guide](https://end-4.github.io/dots-hyprland-wiki/) first, then overlay my config:

```bash
git clone https://github.com/almenscorner/dots

# Quickshell config
cp -r dots/quickshell/ii ~/.config/quickshell/ii

# Hyprland custom overrides
cp -r dots/hypr/custom ~/.config/hypr/custom

# Shell/bar config
cp dots/illogical-impulse/config.json ~/.config/illogical-impulse/config.json

# Scripts
mkdir -p ~/.local/bin
cp dots/scripts/hypr-toggle-floating-mode.sh ~/.local/bin/
chmod +x ~/.local/bin/hypr-toggle-floating-mode.sh
```

> Edit `bar.weather.city` in `~/.config/illogical-impulse/config.json` to your city.

### Extra dependencies (beyond upstream)

| Package | Purpose |
|---------|---------|
| `gpu-screen-recorder` | Screen recording |
| `cava` | Audio waveform in bar |
| `nvidia-smi` | GPU temperature (NVIDIA) |
| `mpvpaper` | Video wallpaper |

## Configuration

Most settings live in `~/.config/illogical-impulse/config.json`. Key options I've changed:

```json
{
  "bar": {
    "cornerStyle": 1,
    "showBackground": false,
    "floatStyleShadow": true,
    "weather": { "city": "YOUR_CITY", "enable": true, "useUSCS": false }
  },
  "appearance": {
    "palette": { "type": "scheme-rainbow" },
    "transparency": { "enable": true }
  },
  "lock": { "useHyprlock": false }
}
```

## License

GPL v3 — see [LICENSE](LICENSE).  
Original work © end-4, licensed under GPL v3. Modifications © tobias.
