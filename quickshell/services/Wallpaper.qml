pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "root:/config"

// The wallpaper, owned by the shell. backdrop/Backdrop.qml draws it and the lock
// screen fades in from the same picture, so there is one answer to "what is
// on screen" and nothing to ask a separate daemon (this used to poll
// hyprpaper every ten seconds).
//
// The choice lives in ~/.config/quickshell/wallpaper — one line, a path, `~`
// allowed — so it survives restarts and can be edited by hand. Change it live
// with `qs ipc call shell wallpaper ~/.wallpapers/other.jpg`.
Singleton {
    id: root

    // The wallpaper to use when no particular monitor is being asked about.
    property string path: ""

    readonly property url source: root.path !== ""
        ? Qt.resolvedUrl("file://" + root.path)
        : Theme.fallbackWallpaper

    signal changed()

    // Every monitor shows the same picture. Kept as a per-monitor lookup so
    // callers do not have to change if that stops being true.
    function forMonitor(name: string): url {
        return root.source;
    }

    function set(p: string) {
        const next = root._expand(p);
        if (next === "") return;
        store.setText("# The wallpaper the shell draws (services/Wallpaper.qml). One path; ~ allowed.\n"
            + next + "\n");
    }

    function _expand(p: string): string {
        const s = p.trim();
        if (s.startsWith("~/")) return Quickshell.env("HOME") + s.slice(1);
        return s;
    }

    FileView {
        id: store
        path: Quickshell.env("HOME") + "/.config/quickshell/wallpaper"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            const line = text().split("\n").map(l => l.trim()).find(l => l !== "" && !l.startsWith("#"));
            const next = line ? root._expand(line) : "";
            if (next !== root.path) {
                root.path = next;
                root.changed();
            }
        }
    }
}
