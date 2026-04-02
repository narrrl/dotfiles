#!/bin/bash
url=$(playerctl metadata mpris:artUrl 2>/dev/null)
if [[ "$url" == file://* ]]; then
    cp "${url#file://}" /tmp/hyprlock_art.png
    echo "/tmp/hyprlock_art.png"
elif [[ "$url" == http* ]]; then
    curl -s "$url" -o /tmp/hyprlock_art.png
    echo "/tmp/hyprlock_art.png"
else
    echo "$HOME/.config/hypr/catppuccin-hyprland/assets/mocha.webp"
fi
