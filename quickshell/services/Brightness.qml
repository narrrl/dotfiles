pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Backlight control. Reads the sysfs value directly so the OSD is exact, and
// writes through brightnessctl, which already owns the udev permissions here.
//
// The backlight belongs to the built-in panel. Docked with the lid shut that
// panel is disabled, and the slider would move a screen nobody can see, so the
// control only exists while an internal output is actually lit.
Singleton {
    id: root

    // First device under /sys/class/backlight; empty on a desktop.
    property string device: ""

    property int raw: 0
    property int maxRaw: 0
    readonly property real percent: maxRaw > 0 ? raw / maxRaw * 100 : 0

    readonly property bool panelLit: Hyprland.monitors.values.some(m =>
        /^(eDP|LVDS|DSI)/.test(m.name) && !(m.lastIpcObject?.disabled ?? false))
    readonly property bool available: device !== "" && maxRaw > 0 && panelLit

    Process {
        running: true
        command: ["sh", "-c", "ls -1 /sys/class/backlight | head -n1"]
        stdout: SplitParser {
            onRead: line => { if (line.trim() !== "") root.device = line.trim(); }
        }
    }

    signal bumped()

    FileView {
        id: maxFile
        path: root.device ? "/sys/class/backlight/" + root.device + "/max_brightness" : ""
        watchChanges: false
        onLoaded: {
            const v = parseInt(text().trim());
            if (v > 0) root.maxRaw = v;
        }
    }

    FileView {
        id: currentFile
        path: root.device ? "/sys/class/backlight/" + root.device + "/brightness" : ""
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const v = parseInt(text().trim());
            if (!isNaN(v) && v !== root.raw) {
                root.raw = v;
                // Settled, or moved by something else: step from here again.
                if (!setter.running && root.pending < 0) root.target = -1;
                root.bumped();
            }
        }
    }

    // sysfs writes do not always fire inotify for backlight, so poll gently too.
    Timer {
        interval: 1000
        running: root.available && !GameMode.active
        repeat: true
        onTriggered: currentFile.reload()
    }

    // The level last asked for, until the backlight reports it. Steps build on
    // it rather than on `percent`, which only catches up on the next read, so
    // a fast scroll adds up instead of repeating one step.
    property int target: -1
    // A level asked for while a write is still running. Restarting the write
    // would kill it half done, so the newest request waits and the rest drop.
    property int pending: -1

    Process {
        id: setter
        onExited: {
            currentFile.reload();
            if (root.pending < 0) return;
            const next = root.pending;
            root.pending = -1;
            root._write(next);
        }
    }

    function _write(p: int) {
        setter.command = ["brightnessctl", "-d", root.device, "-q", "set", p + "%"];
        setter.running = true;
    }

    function setPercent(p: real) {
        if (!root.available) return;
        const clamped = Math.max(1, Math.min(100, Math.round(p)));
        root.target = clamped;
        if (setter.running) root.pending = clamped;
        else root._write(clamped);
    }

    function change(delta: real) {
        setPercent((root.target >= 0 ? root.target : percent) + delta);
    }

    readonly property string icon: {
        const p = root.percent;
        if (p >= 80) return "󰃠";
        if (p >= 55) return "󰃝";
        if (p >= 30) return "󰃟";
        return "󰃞";
    }
}
