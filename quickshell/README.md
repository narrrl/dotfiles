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

The shell is spread across three surfaces rather than crammed into one bar,
because on a 1080p panel horizontal space is cheap and vertical space is not: a
48px rail costs 2.5% of the width, where the same 48px along the bottom would
have cost 4.4% of the height on top of what the top bar already takes.

```
┌────────────────────────────────────────────┐
│ ◆ TAKEMI  [1][2][3]  window title    00:09 │  bar   — 48px exclusive
├────────────────────────────────────────────┤
│                                         ▐█▌│  rail  — 48px exclusive
│                windows                  ▐ ▌│
│                                       ◣ ▐█▌│
│  ╱ ♪ TRACK ╲  ▁▃▅ 42%                      │  dock  — no exclusive zone
└────────────────────────────────────────────┘
```

- **bar** — identity, workspaces, focused window, clock.
- **rail** — network, bluetooth, audio, mic, backlight, battery, tray,
  notifications, power. Popouts open leftward, into the screen.
- **dock** — now playing and the CPU/MEM/GPU readout. Reserves nothing: windows
  tile the full height underneath, and the input mask is clipped to the cluster
  so clicks elsewhere in the corner fall through. Idles near-invisible and wakes
  on hover or on playback; the crimson corner wedge is the always-on handle that
  marks where it lives.

```
shell.qml        entrypoint — bar, rail, dock, power menu, toasts, OSD per screen
config/          palette, type scale, geometry, motion curves, shape variance
components/      the P5 primitives: panels, gauges, sliders, split-ink text
services/        data sources, all singletons
bar/             the three surfaces and their modules
popouts/         hover panels hanging off rail and bar modules
overlays/        power menu, notification toasts, volume/brightness OSD
lock/            session lock
assets/          halftone and stripe tiles, generated with ImageMagick
```

`P5Panel` is the base surface everything sits on. It does not auto-size —
callers set implicit sizes from their own layout (`row.implicitWidth +
contentPad * 2`), which keeps the shape maths out of binding loops.

## Modules

| Module | Where | Left click | Right click | Middle | Scroll | Hover |
|---|---|---|---|---|---|---|
| Sigil | bar | app menu | reload shell | | | |
| Workspaces | bar | switch | | | | |
| Clock | bar | pin calendar | | | | calendar |
| Network | rail | pin panel | toggle Wi-Fi | nm-connection-editor | | networks |
| Bluetooth | rail | pin panel | toggle adapter | | | devices |
| Volume | rail | mute | pin panel | pavucontrol | volume | audio mixer |
| Mic | rail | mute | pin panel | | mic volume | audio mixer |
| Brightness | rail | | | | brightness | |
| Battery | rail | pin panel | | | | power detail |
| Tray | rail | activate | app menu | secondary | | |
| Bell | rail | history + mark read | do not disturb | | | history |
| Power | rail | power menu | | | | |
| Media | dock | play/pause | next | raise player | next/prev | full player |
| CPU/MEM/GPU | dock | btop | | | | resource dashboard |

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

The display face is Archivo Black, set italic almost everywhere. Change
`Theme.fontDisplay` and everything follows.

## Palette discipline

Two hues, deliberately: teal carries every resting state, crimson means alarm
and nothing else. The old blue, green and amber remain in `Theme.qml` only as
aliases onto those two families so existing call sites keep working — don't
introduce new uses. `Theme.heat()` is a continuous teal→crimson ramp rather than
a hue cycle, so a number that has gone red means the same thing as a battery
that has gone red. Tray icons are force-flattened to a single colour for the
same reason: app brand colours wreck the palette faster than anything else.

Geometry variance lives in the same file. `Theme.leanFor(i)`, `chopFor(i)` and
`cornersFor(i)` hand each module a different lean and chamfer by index, so
modules stop being congruent parallelograms in an even rhythm — pass a module's
index rather than accepting the defaults.
