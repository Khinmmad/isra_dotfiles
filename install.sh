#!/usr/bin/env bash
# ============================================
# Dotfiles Install Script - isra@archlinux
# ============================================

# DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR=$(dirname $(readlink -f $0))
CONFIG_DIR="$HOME/.config"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_section() { echo -e "\n${CYAN}========== $1 ==========${NC}"; }

# ============================================
# PAQUETES (Sistema Arch Linux)
# ============================================
PACMAN_PKGS=(
    # Sistema Base & Utilities
    uwsm pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse
    gst-plugin-pipewire wireplumber pavucontrol pamixer libpulse
    networkmanager network-manager-applet bluez bluez-utils blueman
    brightnessctl playerctl udiskie parallel jq imagemagick
    xdg-user-dirs xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    pacman-contrib qt5-imageformats ffmpegthumbs libnotify

    # Window Manager & Display
    sddm hyprland hyprlock hypridle dunst rofi
    grim slurp wl-clipboard hyprpicker satty
    cliphist wl-clip-persist hyprsunset

    # Theming & Fonts
    nwg-look qt5ct qt6ct kvantum kvantum-qt5 qt5-wayland qt6-wayland
    noto-fonts-emoji ttf-jetbrains-mono-nerd

    # Aplicaciones & Shell
    firefox kitty thunar thunar-archive-plugin thunar-media-tags-plugin
    tumbler ffmpegthumbnailer ark unzip vim wofi nwg-displays fzf
    zsh zsh-syntax-highlighting zsh-autosuggestions fastfetch lsd npm

    # Yazi (Terminal File Manager)
    yazi ffmpeg p7zip poppler fd ripgrep zoxide
)

AUR_PKGS=(
    quickshell-git             # Panel / Barra de status modular
    grub2-theme-fallout-git    # Tema de Fallout para GRUB
    awww                       # Wallpaper daemon
    eww-wayland                # Widgets (opcional)
    spicetify-cli              # Personalización de Spotify
    sddm-sugar-candy-git       # Tema de SDDM
    tokyonight-gtk-theme-git   # Tema GTK
    bibata-cursor-theme-bin    # Set de cursores
)

# ============================================
# FUNCIONES DE INSTALACIÓN
# ============================================

setup_pacman() {
    log_section "Configurando pacman"
    sudo sed -i 's/#Color/Color/' /etc/pacman.conf 2>/dev/null
    if ! grep -q "ILoveCandy" /etc/pacman.conf; then
        sudo sed -i '/^Color/a ILoveCandy' /etc/pacman.conf 2>/dev/null
    fi
    log_success "Pacman configurado"
}

install_pacman() {
    log_section "Instalando paquetes de pacman"
    if ! sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"; then
        log_error "Error al instalar paquetes de pacman. Verifica tu conexión o repositorios."
        return 1
    fi
}

install_aur() {
    log_section "Instalando de AUR (usando paru)"
    if ! command -v paru &>/dev/null; then
        log_info "Paru no encontrado. Instalándolo..."
        sudo pacman -S --needed base-devel git --noconfirm
        git clone https://aur.archlinux.org/paru.git /tmp/paru
        cd /tmp/paru && makepkg -si --noconfirm
        cd -
    fi
    if ! paru -S --needed --noconfirm "${AUR_PKGS[@]}"; then
        log_error "Error al instalar paquetes de AUR."
        return 1
    fi
}

install_ohmyzsh() {
    log_section "Personalizando Shell (ZSH)"
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    # Powerlevel10k
    if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    fi
}

copy_configs() {
    log_section "Sincronizando configuraciones"
    
    # Backup
    BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Iterar sobre las carpetas en configs/ del repo
    cd "$DOTFILES_DIR/configs"
    for dir in *; do
        if [ -d "$dir" ] && [ "$dir" != "grub" ]; then
            # Backup si ya existe en ~/.config
            if [ -d "$CONFIG_DIR/$dir" ]; then
                cp -r "$CONFIG_DIR/$dir" "$BACKUP_DIR/"
            fi
            # Copiar nueva versión
            mkdir -p "$CONFIG_DIR"
            cp -r "$dir" "$CONFIG_DIR/"
            log_success "Config sincronizada: $dir"
        fi
    done
    cd -

    # ZSH files (fuera de .config)
    [ -f "$DOTFILES_DIR/configs/.zshrc" ] && cp "$DOTFILES_DIR/configs/.zshrc" "$HOME/.zshrc"
    [ -f "$DOTFILES_DIR/configs/.p10k.zsh" ] && cp "$DOTFILES_DIR/configs/.p10k.zsh" "$HOME/.p10k.zsh"
}

setup_grub() {
    log_section "Configurando GRUB (Tema Fallout)"
    
    # Backup
    [ -f /etc/default/grub ] && sudo cp /etc/default/grub /etc/default/grub.bak
    
    # Aplicar config personalizada si existe
    if [ -f "$DOTFILES_DIR/configs/grub/default_grub" ]; then
        sudo cp "$DOTFILES_DIR/configs/grub/default_grub" /etc/default/grub
        log_success "Configuración de GRUB aplicada desde dotfiles"
    fi
    
    # Regenerar config
    log_info "Regenerando menú de arranque..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg
}

copy_wallpapers() {
    log_section "Sincronizando Wallpapers"
    mkdir -p "$HOME/Pictures/wallpapers"
    if [ -d "$DOTFILES_DIR/wallpapers" ]; then
        cp "$DOTFILES_DIR/wallpapers/"* "$HOME/Pictures/wallpapers/"
        log_success "Wallpapers copiados"
    fi
}

setup_sddm() {
    log_section "Configurando SDDM Pantalla de Inicio"
    sudo mkdir -p /usr/share/sddm/themes/sugar-candy/backgrounds
    SDDM_WALL="$(ls "$HOME/Pictures/wallpapers/"*.png 2>/dev/null | head -1)"
    if [ -n "$SDDM_WALL" ]; then
        sudo cp "$SDDM_WALL" /usr/share/sddm/themes/sugar-candy/backgrounds/
    fi
    sudo bash -c 'cat > /etc/sddm.conf << EOF
[Theme]
Current=sugar-candy
EOF'
}

setup_services() {
    log_section "Habilitando Servicios de Sistema"
    sudo systemctl enable sddm
    sudo systemctl enable NetworkManager
    sudo systemctl enable bluetooth
    log_success "Servicios habilitados (SDDM, NetworkManager, Bluetooth)"
}

# ============================================
# LÓGICA PRINCIPAL (MAIN)
# ============================================

echo -e "${CYAN}"
cat << 'EOF'
  ____        _    __ _ _           
  |  _ \  ___ | |_ / _(_) | ___  ___ 
  | | | |/ _ \| __| |_| | |/ _ \/ __|
  | |_| | (_) | |_|  _| | |  __/\__ \
  |____/ \___/ \__|_| |_|_|\___||___/
                                       
  isra@archlinux - Quickshell + Hyprland
EOF
echo -e "${NC}"

echo -e "${YELLOW}Este script instalará el setup completo de dotfiles.${NC}"
read -p "¿Deseas continuar con la instalación? [s/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    log_error "Instalación cancelada."
    exit 1
fi

# Flujo de ejecución
setup_pacman
install_pacman
install_aur
install_ohmyzsh
copy_configs
setup_grub
copy_wallpapers
setup_sddm
setup_services

log_section "TODO LISTO"
log_success "Instalación completada con éxito."
log_warn "Por favor, reinicia para entrar en tu nuevo entorno."
log_info "La barra (Quickshell) se iniciará automáticamente al entrar en Hyprland."
