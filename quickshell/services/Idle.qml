pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "root:/services"

// What happens when nobody is at the machine. There is no hypridle: the shell
// already owns the lock screen, so it owns the clock that leads up to it.
//
//   dim      the screen slowly darkens, so the lock does not arrive unannounced
//   lock     the session lock (lock/Lock.qml)
//   off      the displays power down; any input wakes them
//   suspend  only on battery, and only after a long while
//
// Every stage respects idle inhibitors, so a fullscreen video or a call that
// asks the compositor to stay awake holds all of them off. `stayAwake` is the
// same thing by hand (`qs ipc call shell toggleStayAwake`).
Singleton {
    id: root

    // Seconds of no input before each stage.
    readonly property int dimAfter: 240
    readonly property int lockAfter: 300
    readonly property int offAfter: 360
    readonly property int suspendAfter: 900

    property bool stayAwake: false

    readonly property bool dimmed: dimMon.isIdle && !Actions.lockRequested

    function toggleStayAwake() { root.stayAwake = !root.stayAwake; }

    IdleMonitor {
        id: dimMon
        enabled: !root.stayAwake
        respectInhibitors: true
        timeout: root.dimAfter
    }

    IdleMonitor {
        id: lockMon
        enabled: !root.stayAwake
        respectInhibitors: true
        timeout: root.lockAfter
        onIsIdleChanged: if (isIdle) Actions.lock()
    }

    IdleMonitor {
        id: offMon
        enabled: !root.stayAwake
        respectInhibitors: true
        timeout: root.offAfter
        // Input ends the idle period, so the displays come back on the same
        // event that would have woken them anyway.
        onIsIdleChanged: Hyprland.dispatch(
            "hl.dsp.dpms({ action = \"" + (isIdle ? "off" : "on") + "\" })")
    }

    IdleMonitor {
        id: suspendMon
        enabled: !root.stayAwake && Battery.onBattery
        respectInhibitors: true
        timeout: root.suspendAfter
        onIsIdleChanged: if (isIdle) Actions.suspend()
    }
}
