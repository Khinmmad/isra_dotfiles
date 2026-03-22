# Progress - Arch + Hyprland Setup

## Completado ✅
- rofi-network-manager (ronema) + waybar
- Fastfetch con imagen kitty-direct
- Waybar estilos píldoras azul translúcido
- Animaciones Hyprland
- Dunst notificaciones (catppuccin)
- Hyprlock
- SDDM sugar-candy
- Thunar + plugins
- Yazi (previsualizador)
- Spicetify + Marketplace
- Pacman ILoveCandy
- Wallpaper switcher con rofi preview
- AGS v3 corriendo (barra básica)
- Dotfiles en GitHub
- AGS sidebar con music player (Spotify/MPRIS reactivo)
  - Controles play/pause/next/prev
  - Barra de progreso en tiempo real
  - Control de volumen
  - Se abre con click en módulo música de waybar

## Pendiente 🔧
- AGS sidebar: clima
- AGS sidebar: notificaciones
- AGS sidebar: panel de temas
- Waybar módulos extra
- Animaciones de ventanas mejoradas
- Scripts de utilidades
- Arreglar audio (pactl set-sink-mute false al inicio)
- wlogout configurar
- hypridle configurar
- bluetooth configurar

## Comandos importantes
- Recargar waybar: pkill waybar && waybar &
- Recargar hyprland: hyprctl reload
- AGS: cd ~/.config/ags && ags run app.ts --gtk 4 &
- Toggle sidebar: ags toggle sidebar
- Wallpaper selector: SUPER+SHIFT+W
- Network manager: click en waybar o ronema
- Lock: SUPER+L
- Power menu: SUPER+power button
