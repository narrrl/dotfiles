pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// MPRIS. Prefers whichever player is actually playing, falling back to the last
// one that was, so the bar does not flip between Spotify and a stray browser tab.
Singleton {
    id: root

    property string preferredId: ""

    readonly property var players: Mpris.players?.values ?? []
    readonly property bool hasPlayer: active !== null

    readonly property MprisPlayer active: {
        if (players.length === 0) return null;

        // An explicit pick wins, while it still exists.
        if (root.preferredId !== "") {
            for (const p of players) if (p.dbusName === root.preferredId) return p;
        }
        for (const p of players) if (p.isPlaying) return p;
        return players[0];
    }

    readonly property string title: active?.trackTitle || ""
    readonly property string artist: active?.trackArtist || ""
    readonly property string album: active?.trackAlbum || ""
    readonly property string artUrl: active?.trackArtUrl || ""
    readonly property string identity: active?.identity || ""
    readonly property bool playing: active?.isPlaying ?? false

    readonly property bool canGoNext: active?.canGoNext ?? false
    readonly property bool canGoPrevious: active?.canGoPrevious ?? false
    readonly property bool positionSupported: active?.positionSupported ?? false
    readonly property bool lengthSupported: active?.lengthSupported ?? false
    readonly property bool hasTimeline: positionSupported && lengthSupported && length > 0
    readonly property bool canSeek: (active?.canSeek ?? false) && hasTimeline

    readonly property real length: lengthSupported ? (active?.length ?? 0) : 0
    readonly property real position: positionSupported ? (active?.position ?? 0) : 0
    readonly property real progress: hasTimeline ? Math.min(1, position / length) : 0

    readonly property string label: {
        if (!hasPlayer) return "Nothing playing";
        if (title === "") return identity || "Unknown track";
        if (artist === "") return title;
        return artist + " — " + title;
    }

    signal trackChanged()

    onTitleChanged: trackChanged()

    // MPRIS position is pull-only; tick it so the seek bar moves.
    Timer {
        interval: 1000
        running: root.playing && root.positionSupported
        repeat: true
        onTriggered: if (root.active) root.active.positionChanged()
    }

    function playPause() { if (active?.canTogglePlaying) active.togglePlaying(); }
    function next() { if (canGoNext) active.next(); }
    function previous() { if (canGoPrevious) active.previous(); }
    function seekTo(fraction: real) {
        if (!canSeek || length <= 0) return;
        active.position = Math.max(0, Math.min(length, fraction * length));
    }
    function raise() { if (active?.canRaise) active.raise(); }

    function select(player: MprisPlayer) {
        root.preferredId = player ? player.dbusName : "";
    }

    // Nerd Font glyph for the source app, so the bar reads at a glance.
    readonly property string sourceIcon: {
        const id = (identity || "").toLowerCase();
        if (id.includes("spotify")) return "";
        if (id.includes("firefox")) return "";
        if (id.includes("chrom") || id.includes("brave")) return "";
        if (id.includes("mpv")) return "";
        if (id.includes("vlc")) return "󰕼";
        if (id.includes("jellyfin")) return "󰋩";
        if (id.includes("youtube")) return "";
        return "󰝚";
    }

    // Quickshell exposes MPRIS position/length in seconds (with millisecond
    // precision), not the protocol's raw microseconds.
    function timeString(seconds: real): string {
        if (!(seconds > 0)) return "0:00";
        const total = Math.floor(seconds);
        const m = Math.floor(total / 60);
        const s = total % 60;
        if (m >= 60) {
            const h = Math.floor(m / 60);
            return h + ":" + String(m % 60).padStart(2, "0") + ":" + String(s).padStart(2, "0");
        }
        return m + ":" + String(s).padStart(2, "0");
    }
}
