# Takemi — YoRHa dark

A NieR:Automata flavoured Quickshell desktop for Hyprland, kept dark and lit
like its wallpaper: a lone figure at a porthole, the void outside, one planet's
light. The planet white for anything live, the hull red for anything wrong,
grey-green for everything else. Hairlines, square markers, corner ticks,
letter-spaced capitals, and selection shown by inverting the row. The bar, the
rail and a thin border are one hull around the desktop, and the desktop is the
porthole cut out of it.

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
████████████████████████████████████████████████
█ ◉ │ 1 2 3 │ window title  ♪ TRACK │ CPU │ 20:04 █  bar   — 40px, part of the hull
█╭──────────────────────────────────────────╮ ▐▌█
█│                                          │ ▐▌█  rail  — 48px, part of the hull
█│                 windows                  │ ▐▌█
█│                                          │ ▐▌█
█╰──────────────────────────────────────────╯   █  frame — 8px left and bottom
████████████████████████████████████████████████
```

- **hull** — `bar/Frame.qml`: one surface round the whole screen, with the
  desktop as a rounded opening. The bar and the rail sit on it.
- **bar** — identity and workspaces on the left; the focused window, the
  player, the CPU/MEM/GPU readout and the clock on the right.
- **rail** — network, bluetooth, audio, mic, backlight, battery, tray,
  notifications, power. Popouts grow leftward out of it, into the screen.

Modules are divided by hairlines. `BarPill` is chromeless by default — a module
is *content inside* the hull, not a surface of its own — and marks hover with
an accent underline. Pass `standalone: true` for the rare thing that really is
its own panel.

The shell uses three deliberate surface tiers. **Chrome** (the hull and
`ChromeSurface`) is the calm, texture-free bar, rail, and tooltip layer. **Transient**
(`PopoutSurface`) is reserved for expressive menus and detail panels, with one
clear composition and stronger separation from the desktop. **Cinematic**
(`P5Backdrop`) belongs only to scene-scale experiences such as power and lock;
it is never used as decoration inside ordinary chrome or popouts.

```
shell.qml        entrypoint — hull, bar, rail, dashboard, power menu, toasts, OSD per screen
config/          palette, type scale, geometry, motion curves
components/      the primitives: panels, sliders, list rows, display text
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

## Popouts

Hover panels (`components/Popout.qml`) are part of the hull, not cards
floating near their trigger. Each one sits flush against the frame edge it
opens from, is painted in the hull colour, joins the frame through concave
fillets, carries the rim round its open side, and slides out from behind the
frame. `PopoutSurface` notices it is inside a `Popout` and leaves the fill and
the frame to the hull; in the launcher and the ask panel it is still a
free-standing panel with corner ticks.

Placement is explicit: centred on the trigger, then — if that would land the
panel within `dockReach` of one of the opening's corners — docked into the
corner instead, attached to the bar and the rail at once (`dock` is `top`,
`right`, `topRight` or `bottomRight`). Without docking, a panel near the rail
left a thin strip of opening between itself and the rail.

## Dashboard

`dashboard/Dashboard.qml` is a drawer that slides down out of the underside of
the bar — clock click, `SUPER + I`, or `qs ipc call shell dashboard`. It is
painted in the hull colour and joins the bar through two concave fillets, so it
reads as more of the hull rather than as a floating card (caelestia's idea).
Four columns divided by hairlines: operator and time, the month, the system
meters, and what is playing. Escape or focusing anything else puts it away; a
`HyprlandFocusGrab` handles the latter, and `Actions.dashboardClosedAt` stops
the clock click that cleared the grab from opening it straight back up.

## Modules

| Module | Where | Left click | Right click | Middle | Scroll | Hover |
|---|---|---|---|---|---|---|
| Sigil | bar | app menu | reload shell | | | |
| Workspaces | bar | switch | | | | |
| Clock | bar | dashboard | | | | calendar |
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

The display face is Noto Sans, upright and widely tracked — the nearest free
face to NieR's FOT-Rodin that is already installed. Change `Theme.fontDisplay`
and everything follows.

## Palette discipline

YoRHa dark: NieR:Automata's interface language, painted from the wallpaper
(`~/.wallpapers/space-1.jpg`) rather than from the game's beige. Two hues, and
**hue is meaning**; nothing gets a colour for decoration.

- **Light (`accent`, `#eef1ea`)** means live: the focused workspace, the
  selected row, the hovered control, a channel that is on, an unread badge. It
  is the planet's white, barely a colour at all — NieR marks attention with
  brightness and inversion, not with hue.
- **Red (`alarm`, `#c8684f`)** means wrong or destructive: critical battery, an
  urgent workspace, a critical notification, reboot and shut down. It is the
  hull's indicator lights, the only warm thing in the wallpaper.
- **Grey-green** is everything else, and that includes *off*. A muted speaker,
  a muted mic and Do Not Disturb drop to `muted` grey with their off glyph.
- **Ink** is the text on an inverted slab and the faint drop under display
  type.

**Selection is the NieR cursor.** Focus and selection invert the row: a slab of
the light with ink punched out of it. Hover lifts the surface one step and
brings the marker up to full light, but never inverts. Destructive-active is
the same slab in red. The `treatment*` tokens in `Theme.qml` encode all of
this; use them rather than picking colours per widget.

**Markers, not slashes.** The current row, a button under the pointer and the
end of a header rule carry a small square (`Theme.marker`). Popouts are framed
by corner ticks (`Theme.tick`) in their tone colour; the border itself is
structure and stays neutral.

**Flicker, not print.** Display text (`SplitText`) is upright, tracked by
`Theme.tracking`, on a one-pixel soft drop. The two ghosts either side of it
appear only while `glitch()` runs — NieR's brief data-corruption flicker.

**Texture is tiered.** Chrome (bar, rail, tooltips) and transient panels
(popouts, OSD, toasts) are flat. The hairline grid and the dot wash live only in
`P5Backdrop`, behind the lock screen and the power menu.

**Type has a floor.** Nothing renders below `Theme.fsMicro` (10px).

**Changing the palette.** The colours are written once per program:

| File | Covers |
|---|---|
| `quickshell/config/Theme.qml` | the shell: `accent`, `alarm`, the neutral ramp, the hull |
| `hypr/lua/palette.lua` | window borders, groups |
| `alacritty/yorha.toml` | the terminal |
| `fish/conf.d/yorha_theme.fish` | the prompt and pager |

Everything else derives. `glow` *is* `accent`, and `primary` is plain `text`.
`Theme.heat()` is a continuous text → light → red ramp, so a CPU figure that
has gone red means the same thing as a battery that has gone red. Tray icons
are flattened to one colour (subtext, the accent on hover) for the same reason:
app brand colours wreck the palette faster than anything else in the shell.
nm-applet and blueman are hidden from the tray, since the rail already shows
network and bluetooth, but keep running as the secret and pairing agents.

## The rest of the desktop

- **Hyprland** — `hypr/lua/look.lua`. No rounding, no blur, both opacities at
  `1.0`, 1px borders. The active border runs from the light into the suit's
  grey; the inactive border is `overlay`. The shadow is soft and wide, so
  windows float in the opening rather than being printed onto it. `gaps_out`
  is measured from the hull's opening, since the hull reserves its own zones.
- **Alacritty** — `alacritty/yorha.toml`, selected by the `import` in
  `alacritty.toml`. Muted earth hues on the void; selection inverts.
  The Catppuccin and `takemi.toml` files are left in place, unreferenced.
- **Neovim** — still the `catppuccin` plugin, flavour mocha, configured in
  `nvim/lua/plugins/ui.lua`. Not yet moved to the YoRHa palette.
- **GTK and Qt** — still `catppuccin-mocha-blue`. Not yet moved either.
- **Fish** — `fish/conf.d/yorha_theme.fish`.
- **The launcher** — no external theming to keep in step, because it is part of
  this shell (`launcher/`). Fuzzel is gone; `takemi-dmenu` stands in for
  `fuzzel --dmenu` where a script needs a picker.
- **No glass anywhere.** Alacritty is `opacity = 1.0, blur = false`, and
  Hyprland's `decoration:blur` is disabled.

There are **no gradients in the chrome**; every fill is flat. `Theme.sheen`
still exists as a no-op property so old call sites need not be chased down.

## Geometry discipline

**The hull.** Borrowed from caelestia's screen border: the bar, the rail and a
thin band down the left and along the bottom (`Theme.frame`) are one surface,
drawn by `bar/Frame.qml` on the bottom layer, and the desktop is a rounded
opening cut out of it (`Theme.frameRadius`). Read against the wallpaper, you are
inside the ship and the windows sit in the porthole. The bar and the rail draw
no surface of their own and ignore exclusive zones; Frame reserves all four
zones itself, so every piece is placed from the screen edge.

**Rectangles, everywhere else.** NieR panels are plain boxes. `Theme.skew` and
`Theme.cut` are both `0`, so `P5Panel`, `Skew` and `Geom` all collapse to
rectangles; the knobs are kept so a shape can be brought back on purpose. The
porthole's curve is the only one on screen, which is what lets it read.

**Motion glides.** No overshoot anywhere: things ease in on `OutCubic` or
`OutExpo` and settle. NieR's interface is calm and mechanical.

Each surface is **one continuous slab**, with modules divided by hairline rules
rather than by gaps. A row of separate floating cards reads as clutter; that is
what the dividers exist to avoid.
