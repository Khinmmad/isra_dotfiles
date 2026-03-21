#!/bin/bash

WALLPAPER_DIR="/home/isra/Pictures/wallpapers"
STATE_FILE="$HOME/.cache/current_wallpaper_index"

# Obtener la cantidad de imágenes
TOTAL=$(ls "$WALLPAPER_DIR"/*.png "$WALLPAPER_DIR"/*.jpg 2>/dev/null | wc -l)
if [ "$TOTAL" -eq 0 ]; then
    exit 1
fi

# Leer índice actual o empezar en 0
if [ -f "$STATE_FILE" ]; then
    INDEX=$(cat "$STATE_FILE")
else
    INDEX=0
fi

# Calcular siguiente índice
NEXT_INDEX=$(( (INDEX + 1) % TOTAL ))

# Obtener el archivo de wallpaper correspondiente
FILE=$(ls "$WALLPAPER_DIR"/*.png "$WALLPAPER_DIR"/*.jpg | sed -n "$((NEXT_INDEX + 1))p")

# Cambiar el fondo usando swww
swww img "$FILE" \
--transition-type outer \
--transition-pos 1,1 \
--transition-duration 2 \
--transition-fps 60
--transition-angle 45

# Guardar el nuevo índice
echo "$NEXT_INDEX" > "$STATE_FILE"
