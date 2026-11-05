pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Screen brightness, for whichever screen is actually lit.
//
//   backlight  the built-in panel, while it is enabled. Read straight from
//              sysfs so the OSD is exact; written through brightnessctl,
//              which owns the udev permissions.
//   ddc        an external monitor over DDC/CI (ddcutil, VCP 0x10), when the
//              built-in panel is off — docked with the lid shut. Each call
//              takes a few hundred ms on the i2c bus, so writes queue the same
//              way and reads happen rarely.
//
// With neither, `available` is false and the rail hides the control.
Singleton {
    id: root

    // ---------------------------------------------------------- the panel
    // First device under /sys/class/backlight; empty on a desktop.
    property string device: ""

    readonly property bool panelLit: Hyprland.monitors.values.some(m =>
        /^(eDP|LVDS|DSI)/.test(m.name) && !(m.lastIpcObject?.disabled ?? false))

    // ---------------------------------------------------------- external
    // i2c bus number of the first DDC-capable output Hyprland has enabled,
    // and that output's name. -1 when there is none.
    property int ddcBus: -1
    property string ddcOutput: ""

    readonly property string backend: root.panelLit && root.device !== "" ? "backlight"
        : root.ddcBus >= 0 ? "ddc" : ""
    readonly property string outputName: root.backend === "backlight" ? "Built-in"
        : root.backend === "ddc" ? root.ddcOutput : ""

    property int raw: 0
    property int maxRaw: 0
    readonly property real percent: maxRaw > 0 ? raw / maxRaw * 100 : 0
    readonly property bool available: root.backend !== "" && maxRaw > 0

    signal bumped()

    onBackendChanged: {
        root.maxRaw = 0;
        root.target = -1;
        root.pending = -1;
        if (root.backend === "backlight") { maxFile.reload(); currentFile.reload(); }
        else if (root.backend === "ddc") ddcRead.running = true;
    }

    Process {
        running: true
        command: ["sh", "-c", "ls -1 /sys/class/backlight | head -n1"]
        stdout: SplitParser {
            onRead: line => { if (line.trim() !== "") root.device = line.trim(); }
        }
    }

    // ------------------------------------------------------- backlight io
    FileView {
        id: maxFile
        path: root.device ? "/sys/class/backlight/" + root.device + "/max_brightness" : ""
        watchChanges: false
        onLoaded: {
            if (root.backend !== "backlight") return;
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
            if (root.backend !== "backlight") return;
            root._settle(parseInt(text().trim()));
        }
    }

    // sysfs writes do not always fire inotify for backlight, so poll gently too.
    Timer {
        interval: 1000
        running: root.backend === "backlight" && !GameMode.active
        repeat: true
        onTriggered: currentFile.reload()
    }

    // ------------------------------------------------------------- ddc io
    // `ddcutil detect --terse` lists "I2C bus: /dev/i2c-N" then
    // "DRM connector: cardX-NAME" for each display; invalid ones (the
    // laptop's own panel) are headed "Invalid display" and skipped.
    Process {
        id: ddcDetect
        command: ["ddcutil", "detect", "--terse"]
        property var found: []
        property var current: null
        stdout: SplitParser {
            onRead: line => {
                const l = line.trim();
                if (/^Display \d+/.test(l)) {
                    ddcDetect.current = { bus: -1, output: "" };
                    ddcDetect.found.push(ddcDetect.current);
                } else if (/^Invalid display/.test(l)) {
                    ddcDetect.current = null;
                } else if (ddcDetect.current) {
                    let m = /^I2C bus:\s*\/dev\/i2c-(\d+)/.exec(l);
                    if (m) ddcDetect.current.bus = parseInt(m[1]);
                    m = /^DRM connector:\s*card\d+-(.+)$/.exec(l);
                    if (m) ddcDetect.current.output = m[1];
                }
            }
        }
        onStarted: { found = []; current = null; }
        onExited: {
            const enabled = Hyprland.monitors.values
                .filter(m => !(m.lastIpcObject?.disabled ?? false))
                .map(m => m.name);
            const pick = found.find(d => d.bus >= 0 && enabled.indexOf(d.output) >= 0);
            root.ddcBus = pick ? pick.bus : -1;
            root.ddcOutput = pick ? pick.output : "";
        }
    }

    // Outputs come and go when docking; look again a moment after they
    // settle. Detection probes every bus, so it is not run more than that.
    Connections {
        target: Hyprland.monitors
        function onValuesChanged() { redetect.restart(); }
    }
    Timer {
        id: redetect
        interval: 1500
        onTriggered: if (!ddcDetect.running) ddcDetect.running = true
    }
    Component.onCompleted: ddcDetect.running = true

    // "VCP 10 C <current> <max>"
    Process {
        id: ddcRead
        command: ["ddcutil", "--bus", String(root.ddcBus), "getvcp", "10", "--brief"]
        stdout: SplitParser {
            onRead: line => {
                const m = /^VCP 10 C (\d+) (\d+)/.exec(line.trim());
                if (!m || root.backend !== "ddc") return;
                root.maxRaw = parseInt(m[2]);
                root._settle(parseInt(m[1]));
            }
        }
    }

    // The monitor's own buttons can change it too; catch up now and then.
    Timer {
        interval: 30000
        running: root.backend === "ddc" && !GameMode.active
        repeat: true
        onTriggered: if (!ddcRead.running && !setter.running) ddcRead.running = true
    }

    // ------------------------------------------------------------- writes
    // The level last asked for, until the screen reports it. Steps build on
    // it rather than on `percent`, which only catches up on the next read, so
    // a fast scroll adds up instead of repeating one step.
    property int target: -1
    // A level asked for while a write is still running. Restarting the write
    // would kill it half done, so the newest request waits and the rest drop.
    property int pending: -1

    function _settle(v: int) {
        if (isNaN(v) || v === root.raw) return;
        root.raw = v;
        // Settled, or moved by something else: step from here again.
        if (!setter.running && root.pending < 0) root.target = -1;
        root.bumped();
    }

    Process {
        id: setter
        property int wrote: -1
        onExited: {
            if (root.backend === "backlight") currentFile.reload();
            // --noverify: the monitor is not asked back, so take the write
            // as the new level.
            else if (root.backend === "ddc") root._settle(Math.round(wrote / 100 * root.maxRaw));
            if (root.pending < 0) return;
            const next = root.pending;
            root.pending = -1;
            root._write(next);
        }
    }

    function _write(p: int) {
        setter.wrote = p;
        setter.command = root.backend === "ddc"
            ? ["ddcutil", "--bus", String(root.ddcBus), "--noverify", "setvcp", "10",
               String(Math.round(p / 100 * root.maxRaw))]
            : ["brightnessctl", "-d", root.device, "-q", "set", p + "%"];
        setter.running = true;
    }

    function setPercent(p: real) {
        if (!root.available) return;
        const clamped = Math.max(root.backend === "ddc" ? 0 : 1, Math.min(100, Math.round(p)));
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
