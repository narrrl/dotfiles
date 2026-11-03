# Hyprland

Hyprland 0.57 with the Lua config. `hyprland.lua` only requires the modules
below; each one owns one concern. The shell (bar, notifications, lock, idle,
wallpaper) is Quickshell — see [`../quickshell/README.md`](../quickshell/README.md).

```
hyprland.lua        entrypoint: requires everything below, in order
lua/
  palette.lua       the colours, mirrored from quickshell/config/Theme.qml
  env.lua           cursor, toolkit and portal environment
  monitors.lua      outputs; lid.lua and mirror.lua handle docking
  input.lua         layouts (dvorak-intl / us-intl), devices, touchpad swipe
  look.lua          gaps, borders, rounding, shadows, VRR
  animations.lua    curves and the animation tree (same names as Theme.qml)
  apps.lua          which terminal, file manager, launcher …
  autostart.lua     qs, nm-applet, cliphist, warm-up jobs
  gamemode.lua      drops animations and effects while a game runs
  binds/            keybinds, one file per area (apps, windows, workspaces,
                    shell, media, capture)
  rules/            window and layer rules
scripts/
  shot.sh           screenshots with a thumbnail notification
  record.sh         wf-recorder toggle for an area or the monitor
  replay-ctrl.sh    gpu-screen-recorder replay buffer (needs that package),
  replay-notification.sh  and its notification
  droidcam-ctrl.sh  phone as a webcam
```

Check a change with `hyprctl reload && hyprctl configerrors`. The type stubs
for `hl.*` live in `/usr/share/hypr/stubs` (`.luarc.json` points there).
