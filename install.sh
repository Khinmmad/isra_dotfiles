#!/bin/bash

# Instalación automática para entorno Hyprland personalizado

# Salir si hay error
set -e

# Confirmar usuario
echo "Instalando entorno para: $USER"

# Actualizar e instalar paquetes base
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm git base-devel curl wget neovim zsh unzip \
  pipewire wireplumber pipewire-pulse pipewire-alsa \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  networkmanager hyprland waybar rofi kitty thunar firefox \
  grim slurp wl-clipboard swappy swww ttf-jetbrains-mono-nerd

# Habilitar NetworkManager
sudo systemctl enable NetworkManager

# Instalar paru (si no existe)
if ! command -v paru &> /dev/null; then
  echo "Instalando paru..."
  cd /opt
  sudo git clone https://aur.archlinux.org/paru.git
  sudo chown -R $USER:$USER paru
  cd paru
  makepkg -si --noconfirm
fi

# Restaurar configuraciones
echo "Copiando configuraciones..."
cp -r .config/* ~/.config/
cp .zshrc ~/

# Cambiar shell a zsh
chsh -s /bin/zsh

echo "✅ Instalación completa. Reinicia tu sesión."
