# YoRHa dark — dotfiles

A NieR:Automata-flavoured Hyprland desktop on Arch, kept dark and lit like its
wallpaper: grey-green void, one planet's white for anything live, the hull's
red for anything wrong. The bar, a status rail and a thin border are one hull
around the desktop, drawn by a [Quickshell](https://quickshell.org) shell that
also does notifications, the launcher, the lock screen, idle and the wallpaper.

![Desktop](screenshots/desktop.jpg)

![Working](screenshots/work.jpg)

| | |
|---|---|
| ![Dashboard](screenshots/dashboard.jpg) | ![Launcher](screenshots/launcher.jpg) |
| Dashboard (`SUPER+D`) — time, month, meters, player, quick switches | Launcher (`SUPER+SPACE`) — apps, `>` shell, `=` calc, `:` clipboard, `;` emoji, `?` keys, `@` wallpaper |
| ![Notifications](screenshots/toasts.jpg) | ![Overview](screenshots/overview.jpg) |
| Notifications, grouped by sender in the bell's log | Overview (`ALT+TAB`, `SUPER+W`) — every workspace, live |
| ![Power menu](screenshots/power.jpg) | ![Lock screen](screenshots/lock.jpg) |
| Power menu (`SUPER+P`) | Lock screen |

## What is here

| Path | What |
|---|---|
| [`hypr/`](hypr/README.md) | Hyprland 0.57, Lua config: binds, rules, look, monitors, scripts |
| [`quickshell/`](quickshell/README.md) | the shell: bar, rail, popouts, dashboard, launcher, notifications, OSD, lock, overview, ask panel |
| `alacritty/`, `fish/`, `nvim/` (submodule), `btop/`, `zathura/` | terminal, shell, editor, monitor, PDF — all on the YoRHa palette |
| `gtk-3.0/`, `gtk-4.0/`, `qt6ct/` | GTK (adw-gtk3-dark + css) and Qt (Darkly + colour scheme) |
| `fluxo/` | the system-stats daemon the bar reads CPU/MEM/GPU from |
| `systemd/` | user units (mounts, agents, the dunst mask) |
| `packages` | `pacman -Qq` of the machine |

The palette is written once per program; the two shell colours live in
`quickshell/config/Theme.qml` and `hypr/lua/palette.lua`. See
[Palette discipline](quickshell/README.md#palette-discipline) for the full list.

## Keys

`SUPER` is the modifier, and the other modifiers each mean one thing:

| Modifier | Means |
|---|---|
| `SUPER` + key | open or go to what the key names |
| `+SHIFT` | the same, but take the window along (or the bigger version) |
| `+CTRL` | a switch for the session |
| `+ALT` | resize |
| `PRINT` | pictures: `+SHIFT` to a file, `+CTRL` without selecting, `+SUPER` video |

`ALT` on its own is left to the apps, except `ALT+TAB`. Letters resolve by
symbol, so they mean the same on Dvorak and QWERTY.

| Open | | Window | | Session (`SUPER+CTRL`) | |
|---|---|---|---|---|---|
| `RETURN` | terminal | `H/J/K/L` | focus; `+SHIFT` move, `+ALT` resize | `L` | lock |
| `SPACE` | launcher | `1…0` | workspace; `+SHIFT` move window | `N` | do not disturb |
| `E` | file explorer | `S` | scratchpad; `+SHIFT` send window | `I` | stay awake |
| `R` | read a PDF | `F` / `M` | fullscreen / maximize | `M` | mirror the laptop |
| `B` | bluetooth | `V` | float; `+SHIFT` float and pin | `W` | wallpaper |
| `C` | clipboard; `+SHIFT` pick a colour | `G` | group; `TAB` cycles it | `SPACE` | keyboard layout |
| `.` / `/` | emoji / keybind cheatsheet | `SHIFT+Q` | close | `C` | phone camera |
| `D` / `W` | dashboard / overview | | | `R` | reload the shell |
| `A` | ask Claude | | | | |
| `N` | notifications; `+SHIFT` clear | | | | |
| `P` | power menu | | | | |

| Capture | |
|---|---|
| `PRINT` | screenshot an area (`+CTRL` the window, `+SHIFT` to a file) |
| `SUPER+PRINT` | record an area (`+CTRL` the monitor); again to stop |
| `SUPER+Z` / `SUPER+SHIFT+Z` | replay buffer on/off / save the last two minutes |
| `ALT+TAB` | switch windows across every workspace |

`SUPER+/` shows every bind, read live from Hyprland.

## Setup

Arch, with `hyprland`, `uwsm`, `quickshell`, and from `packages`: `grim`,
`slurp`, `satty`, `wf-recorder`, `hyprpicker`, `wl-clipboard`, `cliphist`,
`brightnessctl`, `playerctl`, `hyprpolkitagent`, `adw-gtk-theme`, `darkly-bin`,
`papirus-icon-theme`, `bibata-cursor-theme-bin`, `noto-fonts`,
`ttf-jetbrains-mono-nerd`. `fluxo` is a cargo install. Optional:
`hyprsunset` (night light switch), `gpu-screen-recorder` (`SUPER+Z` replay).

Clone into `~/.config` (the `.gitignore` is an allowlist), start Hyprland
through uwsm, and `hypr/lua/autostart.lua` brings up the shell. The wallpaper
path is the one line in `quickshell/wallpaper`.
