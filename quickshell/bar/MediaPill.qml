import QtQuick
import QtQuick.Shapes
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
    progress: Media.canSeek ? Media.progress : -1

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

        // Album art, chopped into the house shape.
        Item {
            id: artFrame
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            height: 24

            Shape {
                id: artMask
                anchors.fill: parent
                visible: false
                layer.enabled: true
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                    fillColor: "white"
                    strokeColor: "transparent"
                    PathPolyline {
                        path: Geom.chamfer(Geom.parallelogram(24, 24, 0.18), 5, [1, 3])
                    }
                }
            }

            Image {
                id: art
                anchors.fill: parent
                source: Media.artUrl
                fillMode: Image.PreserveAspectCrop
                cache: true
                asynchronous: true
                visible: status === Image.Ready
                layer.enabled: true
                layer.effect: MaskedArt { maskItem: artMask }
            }

            // Fallback: the source app's glyph.
            Icon {
                anchors.centerIn: parent
                visible: art.status !== Image.Ready
                text: Media.sourceIcon
                font.pixelSize: Theme.fsLarge
                color: Theme.primary
                pulsing: Media.playing
                pulseScale: 1.12
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

            Marquee {
                width: Math.min(meta.cap, implicitWidth)
                height: 14
                text: Media.title || Media.identity
                color: Theme.text
                pixelSize: Theme.fsSmall
                family: Theme.fontDisplay
                weight: Font.DemiBold
                italic: true
            }

            Marquee {
                width: Math.min(meta.cap, implicitWidth)
                height: 12
                text: Media.artist || Media.album || Media.identity
                color: Theme.muted
                pixelSize: Theme.fsMicro
                family: Theme.fontMono
            }
        }

        // Play state, as a two-bar equaliser that freezes when paused.
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Repeater {
                model: 3

                Rectangle {
                    required property int index
                    width: 3
                    height: 6
                    anchors.verticalCenter: parent.verticalCenter
                    color: Media.playing ? Theme.primary : Theme.muted

                    SequentialAnimation on height {
                        running: Media.playing
                        loops: Animation.Infinite
                        NumberAnimation {
                            to: 4 + (index * 5) % 13
                            duration: 320 + index * 90
                            easing.type: Easing.InOutSine
                        }
                        NumberAnimation {
                            to: 14 - (index * 4) % 9
                            duration: 280 + index * 70
                            easing.type: Easing.InOutSine
                        }
                    }

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

    SequentialAnimation {
        id: titleGlitch
        NumberAnimation {
            target: artFrame; property: "rotation"
            from: -8; to: 0; duration: Theme.durSlow; easing.type: Easing.OutBack
        }
    }

    MediaPopout {
        id: popout
        anchorItem: root
        triggerHovered: root.hovered && Media.hasPlayer
    }
}
