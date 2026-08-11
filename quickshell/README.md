# Takemi

A Persona 5 flavoured Quickshell desktop for Hyprland. Crimson, black and white,
with no gradients anywhere. Everything leans by the same 14°, corners are
chopped rather than rounded, and every surface is one continuous slab divided by
hairlines rather than a cluster of floating cards.

Replaces Waybar, dunst and hyprlock.

## Running

```sh
qs                       # starts the shell (Hyprland does this via autostart.conf)
qs -p lockpreview.qml    # the lock screen in an ordinary window, for styling
```

Hyprland starts it from `~/.config/hypr/modules/autostart.conf`.

## Layout

Two surfaces. Status moves off the bar and onto a vertical rail, because on a
1080p panel horizontal space is cheap and vertical space is not: a 48px rail
costs 2.5% of the width, where another 48px strip along the bottom would have
cost 4.4% of the height on top of what the bar already takes.

```
┌────────────────────────────────────────────┐
│ ◆ │ 1 2 3 │ window title  ♪ TRACK │ 42% │ 00:09 │  bar  — 48px exclusive
├────────────────────────────────────────────┤
│                                         ▐█▌│  rail — 48px exclusive
│                windows                  ▐ ▌│
│                                         ▐ ▌│
│                                         ▐ ▌│
└────────────────────────────────────────────┘
```

- **bar** — one slab: identity and workspaces on the left; the focused window,
  the player, the CPU/MEM/GPU readout and the clock on the right.
- **rail** — one slab: network, bluetooth, audio, mic, backlight, battery, tray,
  notifications, power. Popouts open leftward, into the screen.

Each permanent surface is a single continuous `ChromeSurface` with modules
divided by sheared hairlines. `BarPill` is chromeless by default — a module is
*content inside* a surface, not a surface of its own — and marks hover with a
crimson underline. Pass `standalone: true` for the rare thing that really is its
own panel.

The shell uses three deliberate surface tiers. **Chrome** (`ChromeSurface`) is
the calm, texture-free bar, rail, and tooltip layer. **Transient**
(`PopoutSurface`) is reserved for expressive menus and detail panels, with one
clear composition and stronger separation from the desktop. **Cinematic**
(`P5Backdrop`) belongs only to scene-scale experiences such as power and lock;
it is never used as decoration inside ordinary chrome or popouts.

```
shell.qml        entrypoint — bar, rail, power menu, toasts, OSD per screen
config/          palette, type scale, geometry, motion curves
components/      the P5 primitives: panels, gauges, sliders, split-ink text
services/        data sources, all singletons
bar/             the two surfaces and their modules
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
| Network | rail | pin details | | | | state + networks |
| Bluetooth | rail | pin details | | | | state + devices |
| Volume | rail | pin audio | | | volume | state + scroll hint + audio |
| Mic | rail | pin audio | | | mic volume | state + scroll hint + audio |
| Brightness | rail | | | | brightness | state + scroll hint |
| Battery | rail | pin panel | | | | power detail |
| Tray | rail | activate | app menu | secondary | | |
| Bell | rail | pin history + mark read | | | | state + history |
| Power | rail | power menu | | | | |
| Media | bar | play/pause | next | raise player | next/prev | full player |
| CPU/MEM/GPU | bar | btop | | | | resource dashboard |

Popouts open on a short dwell and stay while the pointer is over the trigger or
the panel. Hover openings remain passive. Clicking remaps a detail panel as a
keyboard-focused popup: Tab moves through its controls, Escape dismisses it,
and an outside click closes it. A shell-wide coordinator keeps only one
transient surface mapped at a time, including tray context menus, so sweeping
across the rail cannot stack several animated panels over one another.

Audio is the reference vertical-slice popout: current output percentage leads,
output and input have distinct bands, and application streams form a subordinate
mixer list. Output/input mute actions and **Open audio mixer** are explicit
buttons inside the panel; scrolling the rail icons remains the fast level
adjustment.

The power menu is fully keyboard-driven as well as clickable: `Up`/`Down` or
`J`/`K` moves the active slab, `Enter`/`Space` confirms it, and `Escape`
dismisses the screen.

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

Crimson, black, white. That is the whole palette.

**Changing the accent.** The colour is written in exactly three places, one per
program:

| File | Line | Covers |
|---|---|---|
| `quickshell/config/Theme.qml` | `readonly property color accent: "#ff2d40"` | the shell |
| `hypr/modules/takemi.conf` | `$accent = rgb(ff2d40)` | window borders, groups |
| `alacritty/takemi.toml` | `red`, cursor, selection | the terminal |

Everything else derives. `accentDim` and `accentSoft` come off `accent` via
`Qt.darker`/`Qt.lighter`, `glow` (the hover highlight) *is* `accent`, and every
Hyprland border, group indicator and focus state references `$accent`. Change
those lines and the whole setup recolours — swap in Persona 4's yellow or
Persona 3's blue and nothing else needs touching.

## The rest of the desktop

- **Alacritty** — `alacritty/takemi.toml`, selected by the `import` in
  `alacritty.toml`. The Catppuccin files are left in place, just unreferenced.
  Near-black ground, white text, crimson cursor and selection. The sixteen ANSI
  slots keep their hues because syntax highlighters need to tell them apart, but
  every one is desaturated so nothing competes with the accent.
- **Neovim** — `nvim/lua/takemi.lua`, loaded through `nvim/colors/takemi.lua`
  so `:colorscheme takemi` and `require("takemi").lualine()` both work. Same
  palette, same rule: crimson is spent only on keywords, types and errors,
  functions are plain white-bold, and `terminal_color_0..15` mirror
  `takemi.toml` slot for slot so `:terminal` matches the shell around it.
- **Fish** — `fish/conf.d/takemi_theme.fish`, with a preview copy in
  `fish/themes/Takemi.theme` for `fish_config`. Replaced the Catppuccin
  `fish_frozen_theme.fish` that fish 4.3 generated on upgrade. The prompt arrow
  is white and turns crimson on a non-zero exit — the shell's one "wrong"
  signal, and so the one place that earns the accent.
- **Fuzzel** — `fuzzel/takemi.ini`, selected by the `include` in `fuzzel.ini`.
  Square corners rather than the stock radius, and a fully opaque ground.
- **No glass anywhere.** Alacritty is `opacity = 1.0, blur = false`, and
  Hyprland's `decoration:blur` is disabled with both opacities at `1.0`. Blur is
  the signature of the frosted-glass look, which is the opposite of flat ink on
  flat ground — and with nothing translucent left it was costing three render
  passes for no visible result.

White is the resting voice — text, icons, idle indicators. Crimson is the only
accent and always means one thing: active, or wrong. Black is structure, used as
a hard keyline rather than as a soft shadow. **There are no gradients in this
shell**; every fill is flat. `Theme.sheen` still exists as a no-op property
because a teal-to-transparent wash on every panel was the single biggest source
of the murky blue cast the design used to have.

`primary`, `glow`, `blue`, `ok` and `warn` survive in `Theme.qml` only as
aliases onto white, crimson and grey, so the existing call sites keep working —
don't introduce new uses. `warn` used to alias `accentSoft`, which put a
washed-out pink-red wherever something was merely notable; there is no
half-crimson in this palette, so it aliases the real `accent` now and anything
merely informational (brightness, most readouts) is white instead. `Theme.heat()` is a continuous white→crimson ramp, so
a CPU figure that has gone red means the same thing as a battery that has gone
red. Tray icons are force-flattened to a single colour for the same reason: app
brand colours wreck the palette faster than anything else in the shell.

The wallpaper is teal. The UI used to be teal too, and the two fought each other
into a blue-grey mush. Going monochrome-plus-red is what lets the wallpaper be
the colour in the composition.

## Geometry discipline

**One angle, one chamfer, everywhere.** `Theme.skew` is `tan(14°)` and every
edge in the shell leans by exactly that, in the same direction; every corner is
chopped by exactly `Theme.cut`. A vertical panel (the rail) leans its horizontal
edges by a fraction of its *width*, which works out to the same 14°.

This is deliberate and was learned the hard way. An earlier pass gave every
module a different lean, chamfer and height from per-index variance tables, on
the theory that Persona geometry is "chaotic". It isn't — Persona UI is
meticulously clean, and the chaos lives in composition and motion, not in each
element being a different shape. Randomised geometry just reads as noise. If you
find yourself adding a variance table, don't.

Each surface is **one continuous slab**, with modules divided by sheared
hairline rules rather than by gaps. A row of separate floating cards reads as
clutter; that is what the dividers exist to avoid.
