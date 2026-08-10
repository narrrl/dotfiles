pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "root:/config"

// The wallpaper currently on screen, per monitor.
//
// The lock screen used to point at a hardcoded path in Theme.qml, which meant
// it showed whatever picture was correct on the day that line was written —
// takemi_2 while hyprpaper had been switched to takemi_1. Anything that puts
// the wallpaper on screen should ask hyprpaper what it is actually displaying,
// which is what this does.
//
// hyprpaper is the source of truth at runtime; hyprpaper.conf is the fallback
// for the window between the shell starting and hyprpaper answering, and for
// the case where hyprpaper is not running at all.
Singleton {
    id: root

    // monitor name -> file path. Monitors hyprpaper set with a blank `monitor =`
    // come back under the empty-string key.
    property var byMonitor: ({})

    // The wallpaper to use when no particular monitor is being asked about.
    property string path: ""

    readonly property url source: root.path !== ""
        ? Qt.resolvedUrl("file://" + root.path)
        : Theme.fallbackWallpaper

    // Path set from hyprpaper.conf, used until (and unless) hyprctl answers.
    property string configPath: ""

    signal changed()

    function forMonitor(name: string): url {
        const p = root.byMonitor[name];
        return p ? Qt.resolvedUrl("file://" + p) : root.source;
    }

    function refresh() {
        reader.running = true;
    }

    function _expand(p: string): string {
        const s = p.trim();
        if (s.startsWith("~/")) return Quickshell.env("HOME") + s.slice(1);
        return s;
    }

    function _adopt(map: var, fallback: string) {
        root.byMonitor = map;

        // Prefer the focused monitor's wallpaper, then any monitor's, then the
        // config. Object.values order is insertion order here, which is the
        // order hyprpaper listed them in.
        const vals = Object.keys(map).map(k => map[k]).filter(v => v !== "");
        const next = vals.length > 0 ? vals[0] : fallback;

        if (next !== root.path) {
            root.path = next;
            root.changed();
        }
    }

    Process {
        id: reader
        command: ["hyprctl", "hyprpaper", "listactive"]

        stdout: StdioCollector {
            onStreamFinished: {
                const map = {};
                for (const line of text.split("\n")) {
                    // "eDP-1: /home/narl/.wallpapers/takemi_1.jpg". Split on the
                    // first colon only — the path may contain one.
                    const at = line.indexOf(":");
                    if (at === -1) continue;
                    const mon = line.slice(0, at).trim();
                    const file = line.slice(at + 1).trim();
                    if (file === "" || file.startsWith("invalid")) continue;
                    map[mon] = file;
                }
                root._adopt(map, root.configPath);
            }
        }

        // hyprpaper down, or hyprctl missing. Fall back to the config file.
        onExited: code => {
            if (code !== 0 && root.path === "") root._adopt({}, root.configPath);
        }
    }

    // hyprpaper has no change signal to subscribe to, so poll — but slowly. A
    // wallpaper changes when a person decides to change it, not continuously.
    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // Editing the config is the other way the wallpaper changes here, and that
    // one we can watch properly.
    FileView {
        id: conf
        path: Quickshell.env("HOME") + "/.config/hypr/hyprpaper.conf"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const m = /^\s*path\s*=\s*(.+)$/m.exec(text());
            if (m) root.configPath = root._expand(m[1]);
            // A config edit is usually followed by a hyprpaper reload, so go
            // ask what actually took effect rather than trusting the file.
            root.refresh();
        }
    }
}
