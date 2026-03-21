#!/bin/bash

option=$(printf "⏻ Shutdown\n↻ Reboot\n🔒 Lock\n🌙 Suspend\n🚪 Logout" | wofi --dmenu)

case "$option" in
    "⏻ Shutdown")
        systemctl poweroff
        ;;
    "↻ Reboot")
        systemctl reboot
        ;;
    "🔒 Lock")
        hyprlock
        ;;
    "🌙 Suspend")
        systemctl suspend
        ;;
    "🚪 Logout")
        hyprctl dispatch exit
        ;;
esac
