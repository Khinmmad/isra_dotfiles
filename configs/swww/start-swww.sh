#!/bin/bash
swww-daemon &
sleep 1
swww img /home/isra/Downloads/wallhaven-k81776_2560x1440.png --transition-type grow --transition-duration 1
