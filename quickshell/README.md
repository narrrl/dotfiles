# Takemi

A Persona 5 flavoured Quickshell desktop for Hyprland. Cold teal and near-black
pulled from `~/.wallpapers/takemi_2.jpg`, with crimson as the accent voice.
Everything leans, corners are chopped rather than rounded, and headings carry
the wallpaper's RGB split.

Replaces Waybar, dunst and hyprlock.

## Running

```sh
qs                       # starts the shell (Hyprland does this via autostart.conf)
qs -p lockpreview.qml    # the lock screen in an ordinary window, for styling
```

Hyprland starts it from `~/.config/hypr/modules/autostart.conf`.

## Layout

```
shell.qml        entrypoint — one bar, power menu, toasts and OSD per screen
config/          palette, type scale, geometry, motion curves
components/      the P5 primitives: panels, gauges, sliders, split-ink text
services/        data sources, all singletons
bar/             the bar and its modules
popouts/         hover panels hanging off bar modules
overlays/        power menu, notification toasts, volume/brightness OSD
lock/            session lock
assets/          halftone and stripe tiles, generated with ImageMagick
```

`P5Panel` is the base surface everything sits on. It does not auto-size —
callers set implicit sizes from their own layout (`row.implicitWidth +
contentPad * 2`), which keeps the shape maths out of binding loops.

## Bar

| Module | Left click | Right click | Middle | Scroll | Hover |
|---|---|---|---|---|---|
| Sigil | app menu | reload shell | | | |
| Workspaces | switch | | | | |
| CPU/MEM/GPU | btop | | | | resource dashboard |
| Media | play/pause | next | raise player | next/prev | full player |
| Clock | pin calendar | | | | calendar |
| Tray | activate | app menu | secondary | | |
| Network | pin panel | toggle Wi-Fi | nm-connection-editor | | networks |
| Bluetooth | pin panel | toggle adapter | | | devices |
| Volume | mute | pin panel | pavucontrol | volume | audio mixer |
| Mic | mute | pin panel | | mic volume | audio mixer |
| Brightness | | | | brightness | |
| Battery | pin panel | | | | power detail |
| Bell | history + mark read | do not disturb | | | history |
| Power | power menu | | | | |

Popouts open on a short dwell and stay while the pointer is over the trigger or
the panel. Clicking pins one open.

## Keybinds

Set in `~/.config/hypr/modules/keybinds.conf`:

- `Super+Ctrl+L` — lock
- `Super+P` — power menu
- `Super+Shift+N` — toggle do not disturb
- `Super+Ctrl+Shift+N` — clear notifications
- `Super+Shift+R` — reload the shell

All of these go through Quickshell's IPC, so they work from any script:

```sh
qs ipc call shell lock
qs ipc call shell power
qs ipc call shell toggleDnd
qs ipc call shell clearNotifications
qs ipc call shell reloadConfig
```

## Data sources

Hardware telemetry comes from `fluxo`, whose hardware modules are configured to
emit raw pipe-delimited values rather than display strings — `services/Sys.qml`
parses them and does its own formatting. The previous human-readable Waybar
formats are preserved in `~/.config/fluxo/config.toml.waybar-bak`.

Everything else is native: PipeWire for audio, BlueZ for bluetooth,
NetworkManager for Wi-Fi, UPower for battery, MPRIS for media, and Quickshell's
own notification server. These are event-driven, so the bar and OSD react the
instant a volume key is pressed instead of on the next poll.

## Lock screen

Authenticates through `/etc/pam.d/hyprlock`, which on this box is just
`auth include login`. The visuals live in `lock/LockFace.qml` so they can be
styled in an ordinary window (`qs -p lockpreview.qml`) without locking the
session.

If the shell ever dies while the session is locked, the compositor keeps the
session secured by protocol and there is no unlocker left to talk to — recovery
means restarting Hyprland from a TTY.

## What was retired

- `waybar.service` — disabled. Its config is still in `~/.config/waybar`.
- `dunst.service` — masked, so it cannot be D-Bus activated and steal
  `org.freedesktop.Notifications`. Undo with
  `systemctl --user unmask dunst.service`.
- `hyprlock` — no longer bound. `hyprlock.conf` is untouched.

## Optional

`power-profiles-daemon` is not installed (TLP is), so the power-profile
switching in `services/Battery.qml` stays dormant. Nothing else depends on it.

The display face is Adwaita Sans Black Italic, which is what was already on the
box. A heavy condensed grotesque — Anton, Archivo Black, Oswald — would land
closer to the real Persona 5 type. Change `Theme.fontDisplay` and everything
follows.
