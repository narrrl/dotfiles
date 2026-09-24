# Takemi — Persona × Mocha

A Persona 5 flavoured Quickshell desktop for Hyprland, painted in Catppuccin
Mocha. Blue for anything live, mauve for anything wrong, the Mocha greys for
everything else, and no gradients anywhere. Everything leans by the same 14°,
corners are chopped rather than rounded, and every surface is one continuous
slab divided by hairlines rather than a cluster of floating cards.

Replaces Waybar, dunst and hyprlock.

## Running

```sh
qs                       # starts the shell (Hyprland does this via autostart.lua)
qs -p lockpreview.qml    # the lock screen in an ordinary window, for styling
```

Hyprland starts it from `~/.config/hypr/lua/autostart.lua`.

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
*content inside* a surface, not a surface of its own — and marks hover with an
accent underline. Pass `standalone: true` for the rare thing that really is its
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
components/      the P5 primitives: panels, sliders, list rows, print-shadowed text
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

Set in `~/.config/hypr/lua/binds/shell.lua`:

- `Super+Ctrl+L` — lock
- `Super+P` — power menu
- `Super+Shift+N` — toggle do not disturb
- `Super+Ctrl+Shift+N` — clear notifications
- `Super+A` — ask panel
- `Super+Shift+R` — reload the shell

All of these go through Quickshell's IPC, so they work from any script:

```sh
qs ipc call shell lock
qs ipc call shell power
qs ipc call shell toggleDnd
qs ipc call shell ask
qs ipc call shell askAbout "why is the sky blue"
qs ipc call shell clearNotifications
qs ipc call shell reloadConfig
```

## Ask

`Super+A` drops a panel off the top edge and hands whatever you type to
`claude -p`, streamed token by token. It is the subscription that answers —
the CLI already holds the credentials, so nothing here has an API key and
nothing here has to be given one.

The panel is a chat, not a coding session. Settings sources, MCP servers and
project files are switched off by default, which keeps a question asked from
the desktop from arriving with the last project's hooks, `CLAUDE.md` and tone
attached. The thread survives closing the panel; `Ctrl+L` starts a new one.

| Key | Does |
|---|---|
| `Enter` | ask |
| `Shift+Enter` | newline |
| `Ctrl+M` | next model, written back to `ask.json` |
| `Ctrl+Y` | copy the last answer |
| `Ctrl+L` | new conversation |
| `Ctrl+S` | stop the answer |
| `Escape` | hide, keeping the thread |

Configured in `ask.json`, watched and reloaded live:

```json
{
  "model": "sonnet",
  "systemPrompt": "…",
  "keepContext": true,
  "settingSources": "",
  "allowedTools": ["WebSearch", "WebFetch"],
  "disallowedTools": ["Bash", "Edit", "Write"],
  "workingDirectory": "/home/narl",
  "maxTurns": 6
}
```

`settingSources` is the escape hatch: set it to `"user,project,local"` and the
panel becomes your ordinary Claude Code, hooks and all.

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

Catppuccin Mocha, spent on two hues. **Hue is meaning**; nothing gets a colour
for decoration.

- **Blue (`accent`, Mocha blue)** means live: the focused workspace, the
  selected row, the hovered control, a channel that is on, an unread badge.
- **Mauve (`alarm`, Mocha mauve)** means wrong or destructive: critical battery,
  an urgent workspace, a critical notification, reboot and shut down.
- **Grey** is everything else, and that includes *off*. A muted speaker, a
  muted mic and Do Not Disturb drop to `muted` grey with their off glyph. They
  used to be painted in the accent, which made a silenced channel look the most
  alive thing on the rail.
- **Crust (`ink`)** is structure: the hard keyline, the offset under display
  type and panels, the text on an accent slab.

**Selection is an inverted slab.** Focus and selection fill with the accent and
print their text in crust (about 9:1). Hover stays on the surface tone with an
accent mark. Destructive-active is the same slab in mauve. The `treatment*`
tokens in `Theme.qml` encode all of this; use them rather than picking colours
per widget.

**Print, not blur.** Display text (`SplitText`) carries one hard crust offset.
The blue and mauve ghosts appear only while `glitch()` runs. Drawn permanently
1.6px off the body, they read as a focus problem on Mocha's pastels rather than
as misregistered print. The lock screen and the power menu are the exceptions;
they are the cinematic surfaces and keep their split.

**Texture is tiered.** Chrome (bar, rail, tooltips) and transient panels
(popouts, OSD, toasts) are flat. Stripes and halftone live only in
`P5Backdrop`, behind the lock screen and the power menu.

**Type has a floor.** Nothing renders below `Theme.fsMicro` (10px).

**Changing the palette.** The colours are written once per program:

| File | Covers |
|---|---|
| `quickshell/config/Theme.qml` | the shell: `accent`, `alarm` and the neutral ramp |
| `hypr/lua/palette.lua` | window borders, groups, shadows |
| `alacritty/catppuccin-mocha.toml` | the terminal (stock Mocha, cursor in the accent) |

Everything else derives. `accentDim` and `accentSoft` come off `accent`, `glow`
*is* `accent`, and `primary` is plain `text`. `Theme.heat()` is a continuous
text → blue → mauve ramp, so a CPU figure that has gone mauve means the same
thing as a battery that has gone mauve. Tray icons are flattened to one colour
(subtext, the accent on hover) for the same reason: app brand colours wreck the
palette faster than anything else in the shell. nm-applet and blueman are
hidden from the tray, since the rail already shows network and bluetooth, but
keep running as the secret and pairing agents.

## The rest of the desktop

- **Hyprland** — `hypr/lua/look.lua`. No rounding, no blur, both opacities at
  `1.0`. The active border runs blue into lavender and the inactive border is
  `surfaceAlt`. The window shadow is a sharp 4px crust offset, the same printed
  drop the shell's panels carry, not a soft glow.
- **Alacritty** — `alacritty/catppuccin-mocha.toml`, selected by the `import`
  in `alacritty.toml`. Stock Mocha except for the cursor, which is the accent.
  `takemi.toml` is left in place, unreferenced.
- **Neovim** — the `catppuccin` plugin, flavour mocha, configured in
  `nvim/lua/plugins/ui.lua`. Blue is the accent there too. `colors/takemi.lua`
  is left in place, unused.
- **Fish** — `fish/conf.d/takemi_theme.fish` is Catppuccin Mocha's fish theme
  with the Takemi selection rows: a solid accent block with crust punched out.
- **The launcher** — no external theming to keep in step, because it is part of
  this shell (`launcher/`). Fuzzel is gone; `takemi-dmenu` stands in for
  `fuzzel --dmenu` where a script needs a picker.
- **No glass anywhere.** Alacritty is `opacity = 1.0, blur = false`, and
  Hyprland's `decoration:blur` is disabled. Blur is the signature of the
  frosted-glass look, which is the opposite of flat ink on flat ground — and
  with nothing translucent left it was costing three render passes for no
  visible result.

There are **no gradients in this shell**; every fill is flat. `Theme.sheen`
still exists as a no-op property because a teal-to-transparent wash on every
panel was once the biggest source of murk in the design.

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
