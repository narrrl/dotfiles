pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Hardware telemetry, sourced from the user's `fluxo` daemon. fluxo's hardware
// modules are configured to emit raw pipe-delimited values (see
// ~/.config/fluxo/config.toml); everything here is parsing and formatting.
//
// Fed by a single long-lived `fluxo stream` subscription. This used to be two
// Timers driving seven separate `Process` objects, each forking a `fluxo
// <module>` client — five forks every 2 s plus two more every 20 s, so about
// 2.5 process spawns a second, each one exec'ing and dynamically linking a 13 MB
// binary to read a number the daemon already had in memory, and each metric
// still up to one interval stale. `fluxo stream` keeps one connection open and
// pushes a JSON line only when a module's output actually changes: no forks, and
// values land as soon as the daemon has them.
Singleton {
    id: root

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

    // The one-shot `fluxo <module>` client wraps text in zero-width spaces so
    // Waybar's proportional font stops reflowing. The stream deliberately does
    // not, but stripping them costs nothing and keeps this parser usable against
    // either source.
    function _clean(s: string): string {
        return (s || "").replace(/​/g, "").trim();
    }

    function _num(v): real {
        const n = parseFloat(v);
        return isNaN(n) ? 0 : n;
    }

    // ------------------------------------------------------------------ feed
    // Modules fluxo pushes to us. `disk` streams the default mount, which fluxo
    // resolves to "/" (see `signaler_default_args` in its registry).
    readonly property var modules: ["cpu", "mem", "gpu", "net", "sys", "disk", "power"]

    // One line of the stream: {"module":"cpu","text":"7.4|41.0","tooltip":...}.
    function _ingest(line: string): void {
        let ev;
        try {
            ev = JSON.parse(line);
        } catch (e) {
            return;
        }
        if (!ev || !ev.module)
            return;

        const parts = root._clean(ev.text).split("|");
        const tip = ev.tooltip || "";

        switch (ev.module) {
        case "cpu":
            root.cpuUsage = root._num(parts[0]);
            root.cpuTemp = root._num(parts[1]);
            root.cpuModel = tip;
            break;
        case "mem":
            root.memUsed = root._num(parts[0]);
            root.memTotal = root._num(parts[1]);
            break;
        case "gpu":
            // fluxo emits a single non-numeric field ("No GPU") when it cannot
            // find one, so field count is the availability test.
            if (parts.length < 4) {
                root.gpuAvailable = false;
                break;
            }
            root.gpuAvailable = true;
            root.gpuUsage = root._num(parts[0]);
            root.gpuVramUsed = root._num(parts[1]);
            root.gpuVramTotal = root._num(parts[2]);
            root.gpuTemp = root._num(parts[3]);
            const gm = /Model:\s*(.+)/.exec(tip);
            if (gm)
                root.gpuModel = gm[1];
            break;
        case "net":
            root.netInterface = parts[0] || "";
            root.netIp = parts[1] || "";
            root.netRx = root._num(parts[2]);
            root.netTx = root._num(parts[3]);
            break;
        case "sys":
            root.uptime = parts[0] || "";
            root.load1 = root._num(parts[1]);
            root.load5 = root._num(parts[2]);
            root.load15 = root._num(parts[3]);
            const pm = /Processes:\s*(\d+)/.exec(tip);
            if (pm)
                root.procs = parseInt(pm[1]);
            break;
        case "disk":
            root.diskUsed = root._num(parts[1]);
            root.diskTotal = root._num(parts[2]);
            root.diskPercent = ev.percentage || 0;
            const fm = /Free:\s*(\S+)/.exec(tip);
            root.diskFree = fm ? fm[1] : "";
            break;
        case "power":
            root.powerDetail = tip;
            break;
        }
    }

    Process {
        id: source
        command: ["fluxo", "stream"].concat(root.modules)
        running: true

        stdout: SplitParser {
            onRead: data => root._ingest(data)
        }

        // The daemon restarting (or not being up yet at login) drops us. Retry
        // on a slow cadence: this is a reconnect, not a poll, so it only ever
        // fires while the stream is actually down.
        onExited: retry.restart()
    }

    Timer {
        id: retry
        interval: 2000
        repeat: false
        onTriggered: source.running = true
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
