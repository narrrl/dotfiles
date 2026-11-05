pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Whether anything is listening or watching: an app recording from a
// microphone, a camera in use, or the screen being shared. All three show up
// in PipeWire, so this needs no polling — a capture stream exists only while
// something records, and a video source has links only while something
// consumes it.
Singleton {
    id: root

    // Capture streams from other programs. The shell's own level meters are
    // capture streams too, and do not count.
    readonly property var micUsers: Pipewire.nodes.values.filter(n =>
        n.properties?.["media.class"] === "Stream/Input/Audio"
        && !root._isShell(n))

    readonly property var videoLinks: Pipewire.links.values.filter(l =>
        String(l.source?.properties?.["media.class"] ?? "").startsWith("Video/"))

    // xdg-desktop-portal-hyprland names its screencast nodes "xdph-…".
    readonly property bool screen: root.videoLinks.some(l => root._isScreencast(l.source))
    readonly property bool camera: root.videoLinks.some(l => !root._isScreencast(l.source))
    readonly property bool mic: root.micUsers.length > 0
    readonly property bool active: root.mic || root.camera || root.screen

    // Who is doing it, for the tooltip.
    readonly property string detail: {
        const parts = [];
        if (root.screen) parts.push("Screen shared");
        if (root.camera) parts.push("Camera on");
        if (root.mic) {
            const apps = [...new Set(root.micUsers.map(n =>
                n.properties?.["application.name"] || n.name || "an app"))];
            parts.push("Mic: " + apps.join(", "));
        }
        return parts.join(" · ");
    }

    function _isShell(n): bool {
        const who = (String(n.properties?.["application.process.binary"] ?? "") + " "
            + String(n.properties?.["application.name"] ?? "")).toLowerCase();
        return who.includes("quickshell") || /(^|\s)qs(\s|$)/.test(who);
    }

    function _isScreencast(n): bool {
        const name = String(n?.name ?? n?.properties?.["node.name"] ?? "");
        return name.startsWith("xdph");
    }

    // Node properties fill in only once a node is bound.
    PwObjectTracker {
        objects: Pipewire.nodes.values.filter(n => n.isStream || !n.isSink)
    }
}
