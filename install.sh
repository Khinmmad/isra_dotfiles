#!/usr/bin/env bash
# ============================================
# Dotfiles Install Script - isra@archlinux
# ============================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
# PAQUETES
# ============================================
PACMAN_PKGS=(
    # Sistema
    uwsm pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse
    gst-plugin-pipewire wireplumber pavucontrol pamixer libpulse
    networkmanager network-manager-applet
    bluez bluez-utils blueman
    brightnessctl playerctl udiskie

    # Display Manager
    sddm qt5-quickcontrols qt5-quickcontrols2 qt5-graphicaleffects

    # Window Manager
    # waybar  # legacy — reemplazado por AGS
    hyprland hyprlock hypridle dunst rofi
    wlogout grim slurp wl-clipboard hyprpicker satty
    cliphist wl-clip-persist hyprsunset

    # AGS / GJS
    gjs npm

    # Dependencias
    polkit-gnome xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    xdg-user-dirs pacman-contrib parallel jq imagemagick
    qt5-imageformats ffmpegthumbs libnotify noto-fonts-emoji

    # Fuentes
    ttf-jetbrains-mono-nerd

    # Theming
    nwg-look qt5ct qt6ct kvantum kvantum-qt5 qt5-wayland qt6-wayland

    # Aplicaciones
    firefox kitty thunar thunar-archive-plugin thunar-media-tags-plugin
    tumbler ffmpegthumbnailer ark unzip vim wofi
    nwg-displays fzf

    # Shell
    zsh zsh-syntax-highlighting zsh-autosuggestions fastfetch lsd

    # Audio/Utils
    alsa-utils

    # Yazi
    yazi ffmpeg p7zip poppler fd ripgrep zoxide
)

AUR_PKGS=(
    awww                      # wallpaper daemon (antes swww)
    eww-wayland
    spicetify-cli
    sddm-sugar-candy-git
    tokyonight-gtk-theme-git
    aylurs-gtk-shell           # AGS v3
    astal-mpris                # MPRIS para AGS (MusicPlayer)
)

# ============================================
# FUNCIONES
# ============================================
install_pacman() {
    log_section "Instalando paquetes de pacman"
    sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
    log_success "Paquetes de pacman instalados"
}

install_aur() {
    log_section "Instalando paquetes de AUR"
    # Instalar paru si no existe
    if ! command -v paru &>/dev/null; then
        log_info "Instalando paru..."
        sudo pacman -S --needed base-devel
        git clone https://aur.archlinux.org/paru.git /tmp/paru
        cd /tmp/paru && makepkg -si --noconfirm
        cd -
    fi
    paru -S --needed --noconfirm "${AUR_PKGS[@]}"
    log_success "Paquetes AUR instalados"
}

install_ohmyzsh() {
    log_section "Instalando Oh My Zsh"
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "Oh My Zsh instalado"
    else
        log_warn "Oh My Zsh ya existe, saltando..."
    fi
}

install_powerlevel10k() {
    log_section "Instalando Powerlevel10k"
    if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
        log_success "Powerlevel10k instalado"
    else
        log_warn "Powerlevel10k ya existe, saltando..."
    fi
}

install_ronema() {
    log_section "Instalando ronema (rofi-network-manager)"
    if ! command -v ronema &>/dev/null; then
        git clone https://github.com/P3rf3ctRoot/rofi-network-manager /tmp/ronema
        cd /tmp/ronema && sudo bash rofi-network-manager install
        # Fix para sistemas en español
        sudo sed -i '2a export LANG=C' /usr/local/bin/ronema
        cd -
        log_success "Ronema instalado"
    else
        log_warn "Ronema ya existe, saltando..."
    fi
}

install_spicetify_marketplace() {
    log_section "Instalando Spicetify Marketplace"
    if ! command -v spotify &>/dev/null; then
        log_warn "Spotify no está instalado — saltando Spicetify Marketplace"
        log_warn "Instala Spotify manualmente y ejecuta este paso después"
        return 0
    fi
    curl -fsSL https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.sh | sh
    log_success "Spicetify Marketplace instalado"
}

install_rofi_themes() {
    log_section "Instalando temas de rofi"
    if [ ! -d "$HOME/.local/src/rofi-themes" ]; then
        git clone https://github.com/adi1090x/rofi "$HOME/.local/src/rofi-themes"
        log_success "Temas de rofi instalados"
    else
        log_warn "Temas de rofi ya existen, saltando..."
    fi
}

install_rofi_nerd_themes() {
    log_section "Instalando rofi-themes-collection"
    if [ ! -d "$HOME/.local/src/rofi-themes-collection" ]; then
        git clone https://github.com/lr-tech/rofi-themes-collection \
            "$HOME/.local/src/rofi-themes-collection"
        mkdir -p "$HOME/.local/share/rofi/themes"
        cp "$HOME/.local/src/rofi-themes-collection/themes/"*.rasi \
            "$HOME/.local/share/rofi/themes/"
        log_success "rofi-themes-collection instalado"
    else
        log_warn "rofi-themes-collection ya existe, saltando..."
    fi
}

install_ags() {
    log_section "Configurando AGS"
    # Guard: asegurarse de que copy_configs ya corrió
    if [ ! -d "$CONFIG_DIR/ags" ]; then
        log_error "~/.config/ags no existe — copy_configs falló o no se ejecutó"
        return 1
    fi
    cd "$CONFIG_DIR/ags"
    npm install
    log_success "AGS configurado"
}

backup_configs() {
    log_section "Haciendo backup de configs existentes"
    BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    for dir in waybar hypr kitty ronema fastfetch eww swww dunst wofi rofi spicetify yazi nwg-look gtk-3.0 gtk-4.0 ags; do
        if [ -d "$CONFIG_DIR/$dir" ]; then
            cp -r "$CONFIG_DIR/$dir" "$BACKUP_DIR/"
            log_warn "Backup de $dir en $BACKUP_DIR"
        fi
    done
    log_success "Backup completado en $BACKUP_DIR"
}

copy_configs() {
    log_section "Copiando configs"
    # waybar se copia como referencia legacy pero AGS es la barra activa
    for dir in waybar hypr kitty ronema fastfetch eww swww dunst wofi rofi spicetify yazi nwg-look gtk-3.0 gtk-4.0 ags; do
        if [ -d "$DOTFILES_DIR/configs/$dir" ]; then
            cp -r "$DOTFILES_DIR/configs/$dir" "$CONFIG_DIR/"
            log_success "Copiado: $dir"
        fi
    done

    # ZSH configs
    cp "$DOTFILES_DIR/configs/.zshrc" "$HOME/.zshrc" 2>/dev/null \
        || log_warn ".zshrc no encontrado en configs/, saltando..."
    cp "$DOTFILES_DIR/configs/.p10k.zsh" "$HOME/.p10k.zsh" 2>/dev/null \
        || log_warn ".p10k.zsh no encontrado en configs/, saltando..."
    log_success "Configs copiados"
}

copy_wallpapers() {
    log_section "Copiando wallpapers"
    mkdir -p "$HOME/Pictures/wallpapers"
    cp "$DOTFILES_DIR/wallpapers/"* "$HOME/Pictures/wallpapers/"
    log_success "Wallpapers copiados"
}

setup_sddm() {
    log_section "Configurando SDDM"
    sudo mkdir -p /usr/share/sddm/themes/sugar-candy/backgrounds

    # Usar el primer wallpaper disponible en vez de hardcodear el nombre
    SDDM_WALL="$(ls "$HOME/Pictures/wallpapers/"*.png 2>/dev/null | head -1)"
    if [ -z "$SDDM_WALL" ]; then
        log_warn "No se encontró ningún wallpaper .png — SDDM sin fondo"
    else
        sudo cp "$SDDM_WALL" /usr/share/sddm/themes/sugar-candy/backgrounds/
        log_info "Wallpaper SDDM: $(basename "$SDDM_WALL")"
    fi

    sudo bash -c 'cat > /etc/sddm.conf << EOF
[Theme]
Current=sugar-candy
EOF'
    log_success "SDDM configurado"
}

setup_services() {
    log_section "Habilitando servicios"
    sudo systemctl enable sddm
    sudo systemctl enable NetworkManager
    sudo systemctl enable bluetooth
    log_success "Servicios habilitados"
}

setup_zsh() {
    log_section "Configurando ZSH como shell default"
    chsh -s "$(which zsh)"
    log_success "ZSH configurado como shell default"
}

setup_pacman() {
    log_section "Configurando pacman"
    sudo sed -i 's/#Color/Color/' /etc/pacman.conf
    # Evitar duplicar ILoveCandy si ya existe
    grep -q "ILoveCandy" /etc/pacman.conf \
        || sudo sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
    log_success "Pacman configurado con ILoveCandy"
}

# ============================================
# MAIN
# ============================================
echo -e "${CYAN}"
cat << 'EOF'
  ____        _    __ _ _           
 |  _ \  ___ | |_ / _(_) | ___  ___ 
 | | | |/ _ \| __| |_| | |/ _ \/ __|
 | |_| | (_) | |_|  _| | |  __/\__ \
 |____/ \___/ \__|_| |_|_|\___||___/
                                      
  isra@archlinux - Arch + Hyprland
EOF
echo -e "${NC}"

echo -e "${YELLOW}Este script instalará todos los dotfiles y paquetes necesarios.${NC}"
echo -e "${YELLOW}Se hará un backup de tus configs actuales antes de sobreescribir.${NC}"
read -p "¿Continuar? [s/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    log_error "Instalación cancelada"
    exit 1
fi

# Ejecutar en orden
setup_pacman
install_pacman
install_aur
install_ohmyzsh
install_powerlevel10k
install_ronema
install_rofi_themes
install_rofi_nerd_themes
backup_configs
copy_configs
copy_wallpapers
setup_sddm
setup_services
setup_zsh
install_spicetify_marketplace
install_ags

echo -e "\n${GREEN}"
cat << 'EOF'
  ___           _        _            _   _ 
 |_ _|_ __  ___| |_ __ _| | __ _  __| | | |
  | || '_ \/ __| __/ _` | |/ _` |/ _` | | |
  | || | | \__ \ || (_| | | (_| | (_| | |_|
 |___|_| |_|___/\__\__,_|_|\__,_|\__,_| (_)
                                             
EOF
echo -e "${NC}"
log_success "¡Instalación completada! Reinicia para aplicar todos los cambios."
log_warn "Ejecuta 'spicetify backup apply' después de abrir Spotify por primera vez."
log_warn "AGS se inicia automáticamente via hyprland.conf — no necesitas correrlo manualmente."
