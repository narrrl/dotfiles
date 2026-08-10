pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Hardware telemetry, sourced from the user's `fluxo` daemon. fluxo's hardware
// modules are configured to emit raw pipe-delimited values (see
// ~/.config/fluxo/config.toml); everything here is parsing and formatting.
Singleton {
    id: root

    // Poll interval. The bar reads these continuously, so keep it modest.
    property int interval: 2000

    // ------------------------------------------------------------------ cpu
    property real cpuUsage: 0
    property real cpuTemp: 0
    property string cpuModel: ""

    // ------------------------------------------------------------------ mem
    property real memUsed: 0        // GB
    property real memTotal: 0       // GB
    readonly property real memPercent: memTotal > 0 ? memUsed / memTotal * 100 : 0

    // ------------------------------------------------------------------ gpu
    property bool gpuAvailable: false
    property real gpuUsage: 0
    property real gpuVramUsed: 0
    property real gpuVramTotal: 0
    property real gpuTemp: 0
    property string gpuModel: ""

    // ----------------------------------------------------------------- disk
    property real diskUsed: 0       // GB
    property real diskTotal: 0      // GB
    property real diskPercent: 0
    property string diskFree: ""

    // ------------------------------------------------------------------ sys
    property string uptime: ""
    property real load1: 0
    property real load5: 0
    property real load15: 0
    property int procs: 0

    // ------------------------------------------------------------------ net
    property string netInterface: ""
    property string netIp: ""
    property real netRx: 0          // MB/s
    property real netTx: 0          // MB/s
    readonly property bool netUp: netInterface !== "" && netInterface !== "none"
    readonly property bool netWireless: netInterface.startsWith("wl")

    // -------------------------------------------------------------- battery
    // UPower drives the battery UI; fluxo supplies the TLP/AC detail line.
    property string powerDetail: ""

    // fluxo wraps values in zero-width spaces for Waybar's benefit.
    function _clean(s: string): string {
        return (s || "").replace(/​/g, "").trim();
    }

    function _fields(json: string): var {
        try {
            const o = JSON.parse(json);
            return { parts: root._clean(o.text).split("|"), obj: o };
        } catch (e) {
            return null;
        }
    }

    function _num(v): real {
        const n = parseFloat(v);
        return isNaN(n) ? 0 : n;
    }

    Timer {
        interval: root.interval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuReader.running = true;
            memReader.running = true;
            gpuReader.running = true;
            netReader.running = true;
            sysReader.running = true;
        }
    }

    // Disk and battery move slowly; poll them a tenth as often.
    Timer {
        interval: root.interval * 10
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            diskReader.running = true;
            powerReader.running = true;
        }
    }

    Process {
        id: cpuReader
        command: ["fluxo", "cpu"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = root._fields(text);
                if (!f) return;
                root.cpuUsage = root._num(f.parts[0]);
                root.cpuTemp = root._num(f.parts[1]);
                root.cpuModel = f.obj.tooltip || "";
            }
        }
    }

    Process {
        id: memReader
        command: ["fluxo", "mem"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = root._fields(text);
                if (!f) return;
                root.memUsed = root._num(f.parts[0]);
                root.memTotal = root._num(f.parts[1]);
            }
        }
    }

    Process {
        id: gpuReader
        command: ["fluxo", "gpu"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = root._fields(text);
                if (!f || f.parts.length < 4) {
                    root.gpuAvailable = false;
                    return;
                }
                root.gpuAvailable = true;
                root.gpuUsage = root._num(f.parts[0]);
                root.gpuVramUsed = root._num(f.parts[1]);
                root.gpuVramTotal = root._num(f.parts[2]);
                root.gpuTemp = root._num(f.parts[3]);
                const m = /Model:\s*(.+)/.exec(f.obj.tooltip || "");
                if (m) root.gpuModel = m[1];
            }
        }
    }

    Process {
        id: diskReader
        command: ["fluxo", "disk", "/"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = root._fields(text);
                if (!f) return;
                root.diskUsed = root._num(f.parts[1]);
                root.diskTotal = root._num(f.parts[2]);
                root.diskPercent = f.obj.percentage || 0;
                const m = /Free:\s*(\S+)/.exec(f.obj.tooltip || "");
                root.diskFree = m ? m[1] : "";
            }
        }
    }

    Process {
        id: netReader
        command: ["fluxo", "net"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = root._fields(text);
                if (!f) return;
                root.netInterface = f.parts[0] || "";
                root.netIp = f.parts[1] || "";
                root.netRx = root._num(f.parts[2]);
                root.netTx = root._num(f.parts[3]);
            }
        }
    }

    Process {
        id: sysReader
        command: ["fluxo", "sys"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = root._fields(text);
                if (!f) return;
                root.uptime = f.parts[0] || "";
                root.load1 = root._num(f.parts[1]);
                root.load5 = root._num(f.parts[2]);
                root.load15 = root._num(f.parts[3]);
                const m = /Processes:\s*(\d+)/.exec(f.obj.tooltip || "");
                if (m) root.procs = parseInt(m[1]);
            }
        }
    }

    Process {
        id: powerReader
        command: ["fluxo", "power"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.powerDetail = JSON.parse(text).tooltip || "";
                } catch (e) {}
            }
        }
    }

    // ------------------------------------------------------------ formatting
    function rate(mbps: real): string {
        if (mbps >= 1) return mbps.toFixed(1) + " MB/s";
        const kb = mbps * 1024;
        if (kb >= 1) return Math.round(kb) + " KB/s";
        return "idle";
    }

    function gb(v: real): string {
        return v >= 100 ? Math.round(v) + "G" : v.toFixed(1) + "G";
    }
}
