import QtQuick
import QtQuick.Shapes
import QtQuick.Window
import Quickshell
import "root:/config"
import "root:/components"
import "root:/services"
import "root:/popouts"

// Now-playing module. Collapses to nothing when no player is around.
BarPill {
    id: root

    required property var screenRef

    accent: Theme.primary
    padding: Theme.padS
    visible: Media.hasPlayer || width > 1

    // Track position, drawn by the pill in its own rule band.
    progress: Media.hasTimeline ? Media.progress : -1

    implicitWidth: Media.hasPlayer
        ? layout.implicitWidth + contentPad * 2
        : 0

    Behavior on implicitWidth {
        NumberAnimation { duration: Theme.durSlow; easing.type: Easing.OutExpo }
    }

    clip: true

    onClicked: Media.playPause()
    onRightClicked: Media.next()
    onMiddleClicked: Media.raise()
    onScrolled: delta => delta > 0 ? Media.next() : Media.previous()

    Row {
        id: layout
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        spacing: Theme.padS

        // Album art in a hairline frame.
        Rectangle {
            id: artFrame
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            height: 24
            color: Theme.surface
            border.width: 1
            border.color: Theme.overlay

            Image {
                id: art
                anchors.fill: parent
                anchors.margins: 1
                source: Media.artUrl
                fillMode: Image.PreserveAspectCrop
                cache: true
                asynchronous: true
                visible: status === Image.Ready
                sourceSize.width: 48
                sourceSize.height: 48
            }

            // Fallback: the source app's glyph.
            Icon {
                anchors.centerIn: parent
                visible: art.status !== Image.Ready
                text: Media.sourceIcon
                font.pixelSize: Theme.fsLarge
                color: Theme.primary
            }
        }

        // Title and artist size to the text, up to a cap.
        //
        // These used to be a flat 130px wide each, which meant a short title
        // still reserved 130px and left a hand-sized hole between the artist and
        // the equaliser — the pill looked broken rather than compact. They take
        // what they need now and only start scrolling past the cap.
        Column {
            id: meta
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            readonly property real cap: 150

            Text {
                width: Math.min(meta.cap, implicitWidth)
                height: 14
                text: Media.title || Media.identity
                color: Theme.text
                elide: Text.ElideRight
                font.pixelSize: Theme.fsSmall
                font.family: Theme.fontDisplay
                font.weight: Font.DemiBold
                renderType: Text.NativeRendering
            }

            Text {
                width: Math.min(meta.cap, implicitWidth)
                height: 12
                text: Media.artist || Media.album || Media.identity
                color: Theme.muted
                elide: Text.ElideRight
                font.pixelSize: Theme.fsMicro
                font.family: Theme.fontMono
                renderType: Text.NativeRendering
            }
        }

        // Signal meter: five hairline bars, NieR's audio readout rather than a
        // chunky equaliser. It moves only while audio is playing and settles
        // into a row of square dots when paused — the channel is open, there
        // is just nothing on it.
        //
        // Sampled from a timer rather than tweened by an infinite
        // NumberAnimation. DP-1 runs at 240 Hz, and a frame-synced animation
        // here repainted the entire bar 240 times a second: this pill sits
        // inside ancestors that use layer.enabled together with
        // Shape.CurveRenderer, and the album art carries a MultiEffect pass, so
        // every one of those frames re-rendered several layer textures. Measured
        // on its own, this one animation cost about two thirds of a CPU core
        // whenever anything was playing.
        //
        // The timer samples a sine, it does not step through arbitrary levels: a
        // low tick rate only looks like the original if consecutive ticks stay
        // near each other. Each bar keeps the eased breathing motion and the
        // period it had before — the curve is just read 25 times a second
        // instead of 240.
        Row {
            id: eq
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            // Sampling interval — the one knob trading smoothness against cost.
            // Frames are the whole expense: a full-bar repaint runs about 0.3% of
            // a core (the bar spans 2544x40 on a 240 Hz output), so cost scales
            // linearly with this rate. 16 ms holds 60 Hz, which is visually
            // indistinguishable from the original frame-synced tween at a quarter
            // of its ~75%.
            readonly property int tickMs: 16
            property int phase: 0

            // Reproduces the original per-bar tween exactly, sampled instead of
            // frame-synced. Each bar eased between two heights with its own pair
            // of durations, so the three differed in both swing and period — the
            // middle bar moved barely a pixel while the outer two ran in
            // opposition. Giving all three the full swing, as a single symmetric
            // sine would, is three times the motion and reads far busier than
            // this meter is supposed to.
            function level(i: int): real {
                const lo = 2 + (i * 3) % 5;
                const hi = 14 - (i * 4) % 7;
                const d1 = 320 + i * 90;        // ...and their durations
                const d2 = 280 + i * 70;

                const t = (eq.phase * eq.tickMs) % (d1 + d2);
                // Easing.InOutSine, which is what both halves used.
                const ease = x => (1 - Math.cos(Math.PI * x)) / 2;

                return t < d1
                    ? hi + (lo - hi) * ease(t / d1)
                    : lo + (hi - lo) * ease((t - d1) / d2);
            }

            Timer {
                interval: eq.tickMs
                running: Media.playing && eq.visible && (eq.Window.window?.visible ?? true)
                repeat: true
                onTriggered: eq.phase++
                // Restart the cycle from its trough, so playback always begins
                // from a settled meter rather than mid-swing.
                onRunningChanged: if (!running) eq.phase = 0
            }

            Repeater {
                model: 5

                Rectangle {
                    required property int index
                    width: 1
                    height: Media.playing ? eq.level(index) : 2
                    anchors.verticalCenter: parent.verticalCenter
                    color: Media.playing ? Theme.primary : Theme.muted

                    Behavior on color {
                        ColorAnimation { duration: Theme.durBase }
                    }
                }
            }
        }
    }

    onVisibleChanged: if (visible) titleGlitch.restart()

    Connections {
        target: Media
        function onTrackChanged() { titleGlitch.restart(); }
    }

    // A new track resolves in, the way NieR text does: a brief dip and back.
    SequentialAnimation {
        id: titleGlitch
        NumberAnimation {
            target: meta; property: "opacity"
            to: 0.25; duration: 60
        }
        NumberAnimation {
            target: meta; property: "opacity"
            to: 1; duration: Theme.durSlow; easing.type: Easing.OutCubic
        }
    }

    MediaPopout {
        id: popout
        anchorItem: root
        triggerHovered: root.hovered && Media.hasPlayer
    }
}
