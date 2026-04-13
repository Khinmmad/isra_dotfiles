# 🐻 Isra Dotfiles - Hyprland + Quickshell

![GitHub top language](https://img.shields.io/github/languages/top/Khinmmad/isra_dotfiles?style=for-the-badge)
![GitHub Repo stars](https://img.shields.io/github/stars/Khinmmad/isra_dotfiles?style=for-the-badge)

Una configuración moderna, minimalista y estética de **Hyprland** impulsada por **Quickshell** para una experiencia de escritorio fluida y altamente personalizable utilizando el esquema de colores **Catppuccin Mocha**.

![Previsualización](assets/preview.png)

## 🌟 Características

- **Panel Superior Dinámico (Quickshell)**:
  - **Workspaces**: Indicadores tipo píldora con transiciones suaves.
  - **Módulo de Música**: Control total de Spotify y otros reproductores con barra de progreso deslizable, control de volumen y lanzador automático.
  - **Información del Sistema**: Popups interactivos con detalles de CPU y RAM.
  - **Reloj y Calendario**: Vista detallada de fecha al pasar el mouse.
- **Lanzador de Aplicaciones**: Menú premium integrado en el panel con acceso rápido y menú de energía.
- **Estética "Smooth"**: Bordes redondeados (24px), micro-animaciones y feedback visual consistente.
- **Gestión de Red**: Integración con `rofi-network-manager`.

## 🛠️ Stack Tecnológico

- **Compositor**: [Hyprland](https://hyprland.org/)
- **Panel / Shell**: [Quickshell](https://outfoxxed.github.io/quickshell/) (QML)
- **Lanzador / Menús**: [Rofi](https://github.com/davatorium/rofi)
- **Terminal**: [Kitty](https://sw.kovidgoyal.net/kitty/)
- **Notificaciones**: [Dunst](https://dunst-project.org/)
- **Fondo de Pantalla**: [Swww](https://github.com/L_S_X/swww) + [Awww](https://github.com/Khinmmad/awww)
- **Colores**: [Catppuccin Mocha](https://github.com/catppuccin/catppuccin)

## 🚀 Instalación

> [!IMPORTANT]
> Este script está diseñado principalmente para sistemas basados en Arch Linux. Asegúrate de tener instalado un gestor de AUR (como `paru`).

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/Khinmmad/isra_dotfiles.git
   cd isra_dotfiles
   ```

2. **Ejecutar el instalador:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. **Reiniciar**: Una vez finalizada la instalación, reinicia tu sesión para aplicar todos los cambios de theming y servicios.

## 📁 Estructura del Proyecto

```bash
isra_dotfiles/
├── assets/         # Imágenes y capturas de pantalla
├── configs/        # Configuraciones maestras (se enlazan a ~/.config/)
│   ├── hypr/       # Configuración de Hyprland
│   ├── quickshell/  # Código QML del panel
│   ├── kitty/      # Estilos de la terminal
│   └── ...
├── wallpapers/     # Colección de fondos de pantalla
└── install.sh      # Script de instalación automatizada
```

## 🤝 Contribuciones

Siéntete libre de abrir un *Issue* o enviar un *Pull Request* para mejorar cualquier parte de la configuración. 

---
Desarrollado con ❤️ por [Khinmmad](https://github.com/Khinmmad)
