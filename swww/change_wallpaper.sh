#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
STATE_FILE="$HOME/.cache/current_wallpaper_index"

# Crear cache si no existe
mkdir -p "$HOME/.cache"

# Obtener lista de wallpapers
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | sort)

TOTAL=${#WALLPAPERS[@]}

# Si no hay wallpapers salir
if [ "$TOTAL" -eq 0 ]; then
    exit 1
fi

# Leer índice actual
if [ -f "$STATE_FILE" ]; then
    INDEX=$(cat "$STATE_FILE")
else
    INDEX=0
fi

# Calcular siguiente
NEXT_INDEX=$(( (INDEX + 1) % TOTAL ))

FILE="${WALLPAPERS[$NEXT_INDEX]}"

# Cambiar wallpaper
swww img "$FILE" --transition-type wipe --transition-duration 1

# Guardar índice
echo "$NEXT_INDEX" > "$STATE_FILE"
