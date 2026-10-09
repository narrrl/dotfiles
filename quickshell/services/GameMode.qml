pragma Singleton

import QtQuick
import Quickshell

// A fullscreen game is on screen. Hyprland decides (~/.config/hypr/lua/gamemode.lua)
// and says so with `qs ipc call shell gameMode true|false`.
//
// The game covers the hull, but a covered surface still renders: Hyprland keeps
// sending it frame callbacks, so anything that moves keeps redrawing at the
// panel's refresh rate with nobody watching. While a game runs the shell stops
// what it does on its own:
//
//   Sys          the fluxo stream, so no telemetry wakes the shell
//   Brightness   the backlight poll
//   Media        the position tick, and the equaliser on the bar
//   Rail         the critical battery's pulse
//   Workspaces   the urgent pip's pulse
//   Notifs       toasts, except critical ones; everything still reaches the log
//
// Anything you ask for yourself, the OSD included, still shows.
Singleton {
    property bool active: false
}
