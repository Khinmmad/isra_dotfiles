# isra_dotfiles

Arch Linux dotfiles for a Hyprland setup with AGS bar, Tokyo Night theme, and Bibata cursor.

![Preview](assets/preview.png)

## System Info

| Component | Details |
|-----------|---------|
| OS | Arch Linux |
| WM | Hyprland |
| Bar | AGS (Aylurs GTK Shell) |
| Terminal | Kitty |
| Shell | Zsh + Oh My Zsh + Powerlevel10k |
| Theme | Tokyo Night GTK |
| Cursor | Bibata Modern Ice |
| Wallpaper Daemon | awww |
| File Manager | Thunar |
| Launcher | Rofi |
| Notifications | Dunst |

## Requirements

- Arch Linux (or Arch-based distro)
- `paru` AUR helper (installed automatically by the script if not present)
- Internet connection
- NVIDIA GPU users: make sure the proprietary drivers are installed before running the script

## Installation

```bash
git clone https://github.com/Khinmmad/isra_dotfiles.git
cd isra_dotfiles
chmod +x install.sh
./install.sh
```

The script will:
- Install all required packages from pacman and AUR
- Set up Oh My Zsh with Powerlevel10k
- Create symlinks for all configs into `~/.config`
- Copy wallpapers to `~/Pictures/wallpapers`
- Configure SDDM with Sugar Candy theme
- Enable required systemd services
- Set Zsh as the default shell

## Post-install Steps

These steps must be done manually after running the script:

1. **Reboot** to apply all changes
2. **Spicetify** — open Spotify first, then run:
   ```bash
   spicetify backup apply
   ```
3. **Bibata cursor** — convert to hyprcursor format:
   ```bash
   mkdir -p /tmp/bibata-hypr ~/.local/share/icons
   hyprcursor-util --extract /usr/share/icons/Bibata-Modern-Ice -o /tmp/bibata-hypr
   hyprcursor-util --create /tmp/bibata-hypr/extracted_Bibata-Modern-Ice -o ~/.local/share/icons/
   ```
4. **Locale** — if apps show locale warnings:
   ```bash
   sudo localectl set-locale LANG=en_US.UTF-8
   ```
5. **SSH key for Git** — configure your SSH key or use credential store:
   ```bash
   git config --global credential.helper store
   ```

## Keybinds

| Keybind | Action |
|---------|--------|
| `Super + Q` | Open terminal (Kitty) |
| `Super + R` | Open launcher (Rofi) |
| `Super + E` | Open file manager (Thunar) |
| `Super + F` | Open Firefox |
| `Super + L` | Lock screen (Hyprlock) |
| `Super + C` | Close active window |
| `Super + V` | Toggle floating |
| `Super + W` | Next wallpaper |
| `Super + Shift + W` | Select wallpaper |
| `Super + Y` | Open Spotify |
| `Super + K` | Open nwg-look |
| `Print` | Screenshot |
| `Shift + Print` | Screenshot selection |

## Credits

- [Hyprland](https://hyprland.org/) — Wayland compositor
- [AGS](https://github.com/Aylur/ags) — Bar
- [Tokyo Night GTK](https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme) — GTK theme
- [Bibata](https://github.com/ful1e5/Bibata_Cursor) — Cursor theme
- [Sugar Candy](https://framagit.org/Zhaith-Izaliel/sddm-sugar-candy) — SDDM theme
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) — Zsh theme
- [rofi-network-manager](https://github.com/P3rf/rofi-network-manager) — Network manager
