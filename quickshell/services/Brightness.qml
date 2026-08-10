pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Backlight control. Reads the sysfs value directly so the OSD is exact, and
// writes through brightnessctl, which already owns the udev permissions here.
Singleton {
    id: root

    readonly property string device: "amdgpu_bl1"

    property int raw: 0
    property int maxRaw: 65535
    readonly property real percent: maxRaw > 0 ? raw / maxRaw * 100 : 0
    readonly property bool available: maxRaw > 0

    signal bumped()

    FileView {
        id: maxFile
        path: "/sys/class/backlight/" + root.device + "/max_brightness"
        watchChanges: false
        onLoaded: {
            const v = parseInt(text().trim());
            if (v > 0) root.maxRaw = v;
        }
    }

    FileView {
        id: currentFile
        path: "/sys/class/backlight/" + root.device + "/brightness"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const v = parseInt(text().trim());
            if (!isNaN(v) && v !== root.raw) {
                root.raw = v;
                root.bumped();
            }
        }
    }

    // sysfs writes do not always fire inotify for backlight, so poll gently too.
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: currentFile.reload()
    }

    Process {
        id: setter
    }

    function setPercent(p: real) {
        const clamped = Math.max(1, Math.min(100, Math.round(p)));
        setter.running = false;
        setter.command = ["brightnessctl", "-d", root.device, "-q", "set", clamped + "%"];
        setter.running = true;
    }

    function change(delta: real) {
        setPercent(percent + delta);
    }

    readonly property string icon: {
        const p = root.percent;
        if (p >= 80) return "󰃠";
        if (p >= 55) return "󰃝";
        if (p >= 30) return "󰃟";
        return "󰃞";
    }
}
