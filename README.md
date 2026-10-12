# MangoWM

My MangoWM dotfiles.

## Applications

**Required:** rofi, waybar, wallust, cliphist, wlogout, kitty, fish, nmtui (for WiFi)

**Apps I use:**

| Purpose | App |
|---|---|
| File manager | Nautilus |
| Code editor | VSCodium |
| Browser | Zen Browser |
| Terminal | Kitty |
| Shell | Fish |
| Text editor | Gedit |

## Additional dependencies

- swww
- cliphist
- nmtui
- wl-clipboard
- ttf-JetBrains Mono Nerd ExtraBold
- bibata-cursor-theme
- papirus-icon-theme
- wallust

## Installation

Designed for Arch Linux (uses `pacman` and an AUR helper such as `yay` or `paru`).

```bash
git clone https://github.com/XimeX0114/MangoWM-dotfiles.git
cd MangoWM
python3 install.py
```

The script installs all packages, copies `config/*` to `~/.config` and `local/bin/*` to `~/.local/bin` (existing files are backed up as `<name>.bak-<timestamp>`). Make sure `~/.local/bin` is in your `PATH`. The script also installs Fish and sets it as your default shell if it isn't already (takes effect after re-login).

## Keybindings

| Keys | Action |
|---|---|
| `SUPER + W` | Wallpaper selection menu |
| `SUPER + V` | VSCodium |
| `SUPER + Z` | Zen Browser |
| `SUPER + SPACE` | Rofi |
| `SUPER + E` | Nautilus |
| `SUPER + RETURN` | Kitty |
| `SUPER + SHIFT + V` | Cliphist |
| `SUPER + R` | Reload config |

More keybindings can be found in the config.
