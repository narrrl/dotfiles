pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Live audio state straight from PipeWire, so the bar and OSD react the instant
// a volume key is pressed rather than on the next poll.
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    // Binding node.audio.* only works while the node is tracked.
    PwObjectTracker {
        objects: [root.sink, root.source].filter(n => n !== null)
    }

    readonly property bool ready: sink !== null && sink.audio !== null

    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? true
    readonly property int volumePercent: Math.round(volume * 100)
    readonly property string sinkName: sink?.nickname || sink?.description || sink?.name || "No output"

    readonly property real micVolume: source?.audio?.volume ?? 0
    readonly property bool micMuted: source?.audio?.muted ?? true
    readonly property int micPercent: Math.round(micVolume * 100)
    readonly property string sourceName: source?.nickname || source?.description || source?.name || "No input"

    // Every sink on the box, for the output picker in the audio popout.
    readonly property var sinks: Pipewire.nodes.values.filter(n =>
        n.isSink && !n.isStream && n.audio !== null)

    // Application streams, for the per-app mixer.
    readonly property var streams: Pipewire.nodes.values.filter(n =>
        n.isStream && n.audio !== null && n.isSink === false)

    PwObjectTracker {
        objects: root.streams
    }

    signal volumeBumped()
    signal micBumped()

    onVolumePercentChanged: volumeBumped()
    onMutedChanged: volumeBumped()
    onMicPercentChanged: micBumped()
    onMicMutedChanged: micBumped()

    // Capped at 100%: past it PipeWire only amplifies in software, and clips.
    function setVolume(v: real) {
        if (!sink?.audio) return;
        sink.audio.volume = Math.max(0, Math.min(1, v));
    }

    function changeVolume(delta: real) {
        setVolume(volume + delta);
    }

    function toggleMute() {
        if (!sink?.audio) return;
        sink.audio.muted = !sink.audio.muted;
    }

    function setMicVolume(v: real) {
        if (!source?.audio) return;
        source.audio.volume = Math.max(0, Math.min(1, v));
    }

    function toggleMicMute() {
        if (!source?.audio) return;
        source.audio.muted = !source.audio.muted;
    }

    function setSink(node: PwNode) {
        Pipewire.preferredDefaultAudioSink = node;
    }

    function streamName(node: PwNode): string {
        if (!node) return "";
        return node.properties?.["application.name"]
            || node.properties?.["media.name"]
            || node.nickname
            || node.description
            || node.name;
    }

    // Nerd Font glyph for the current output level.
    readonly property string icon: {
        if (muted) return "󰝟";
        if (volumePercent === 0) return "󰕿";
        if (volumePercent < 34) return "󰕿";
        if (volumePercent < 67) return "󰖀";
        return "󰕾";
    }

    readonly property string micIcon: micMuted ? "󰍭" : "󰍬"
}
