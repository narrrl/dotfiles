import QtQuick
import QtQuick.Shapes
import Quickshell
import "root:/config"
import "root:/components"
import "root:/services"

// Full player: cover art, transport, seek bar, and a picker when more than one
// player is running.
Popout {
    id: root

    contentWidth: 400

    // The seek row used to sit flush against the bottom edge, where the slab's
    // chamfer cuts the corner away — the elapsed time was half outside the
    // panel. The extra height is the room that row needs to clear the cut.
    contentHeight: 224 + (Media.players.length > 1 ? 34 : 0)

    PopoutSurface {
        id: surface
        anchors.fill: parent
        tone: Theme.primary

        PopoutHeader {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            title: "Now Playing"
            icon: Media.sourceIcon
            subtitle: Media.identity
        }

        // Cover art, chopped.
        Item {
            id: artFrame
            anchors.top: header.bottom
            anchors.topMargin: Theme.padM
            anchors.left: parent.left
            width: 108
            height: 108

            Shape {
                id: artMask
                anchors.fill: parent
                visible: false
                layer.enabled: true
                // Without this the mask texture is point-sampled, so the
                // antialiased pixels along the cuts get snapped back to hard
                // steps before MultiEffect ever sees them — see MaskedArt.
                layer.smooth: true
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                    fillColor: "white"
                    strokeColor: "transparent"
                    PathPolyline {
                        path: Geom.chamfer(Geom.parallelogram(108, 108, 0.1), 18, [1, 3])
                    }
                }
            }

            Image {
                id: art
                anchors.fill: parent
                source: Media.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                visible: status === Image.Ready
                layer.enabled: true
                layer.smooth: true
                layer.effect: MaskedArt { maskItem: artMask }
            }

            // Placeholder when the player exposes no artwork.
            Shape {
                anchors.fill: parent
                visible: art.status !== Image.Ready
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                    fillColor: Theme.surface
                    strokeColor: Theme.alpha(Theme.primary, 0.5)
                    strokeWidth: 2
                    PathPolyline {
                        path: Geom.chamfer(Geom.parallelogram(108, 108, 0.1), 18, [1, 3])
                    }
                }
            }

            Icon {
                anchors.centerIn: parent
                visible: art.status !== Image.Ready
                text: Media.sourceIcon
                font.pixelSize: 42
                color: Theme.alpha(Theme.primary, 0.7)
            }

            // Spinning rule around the art while playing.
            Rectangle {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                width: 30
                height: 3
                color: Theme.accent
                visible: Media.playing
            }
        }

        Column {
            id: info
            anchors.top: header.bottom
            anchors.topMargin: Theme.padM
            anchors.left: artFrame.right
            anchors.leftMargin: Theme.padM
            anchors.right: parent.right
            spacing: 2

            Marquee {
                width: parent.width
                height: 24
                text: Media.title || "Nothing playing"
                color: Theme.text
                pixelSize: Theme.fsLarge
                family: Theme.fontDisplay
                weight: Font.Black
                italic: true
            }

            Marquee {
                width: parent.width
                height: 16
                text: Media.artist
                color: Theme.primary
                pixelSize: Theme.fsSmall
                family: Theme.fontDisplay
                italic: true
                weight: Font.DemiBold
            }

            Marquee {
                width: parent.width
                height: 14
                text: Media.album
                color: Theme.muted
                pixelSize: Theme.fsMicro
                family: Theme.fontMono
            }

            Item { width: 1; height: Theme.padS }

            // Transport
            Row {
                spacing: Theme.padM

                TransportButton {
                    glyph: "󰒮"
                    enabledControl: Media.canGoPrevious
                    onClicked: Media.previous()
                }

                TransportButton {
                    glyph: Media.playing ? "󰏤" : "󰐊"
                    primary: true
                    enabledControl: Media.hasPlayer
                    onClicked: Media.playPause()
                }

                TransportButton {
                    glyph: "󰒭"
                    enabledControl: Media.canGoNext
                    onClicked: Media.next()
                }

                TransportButton {
                    glyph: "󰐒"
                    enabledControl: Media.hasPlayer
                    onClicked: Media.raise()
                }
            }
        }

        // Seek bar across the bottom.
        Item {
            id: seekArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.padS
            anchors.rightMargin: Theme.padS
            anchors.bottom: picker.visible ? picker.top : parent.bottom
            anchors.bottomMargin: picker.visible ? Theme.padS : Theme.padM
            height: 26
            visible: Media.hasPlayer

            Text {
                id: elapsed
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: Media.timeString(Media.position)
                color: Theme.subtext
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsMicro
                renderType: Text.NativeRendering
            }

            Text {
                id: total
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: Media.timeString(Media.length)
                color: Theme.subtext
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsMicro
                renderType: Text.NativeRendering
            }

            P5Slider {
                anchors.left: elapsed.right
                anchors.right: total.left
                anchors.leftMargin: Theme.padS
                anchors.rightMargin: Theme.padS
                anchors.verticalCenter: parent.verticalCenter
                value: Media.progress
                accent: Theme.accent
                enabledControl: Media.canSeek
                onMoved: v => Media.seekTo(v)
            }
        }

        // Player picker, only when it matters.
        Row {
            id: picker
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            spacing: Theme.padS
            visible: Media.players.length > 1

            Repeater {
                model: Media.players

                Item {
                    id: chip
                    required property var modelData

                    readonly property bool current: Media.active === modelData

                    implicitWidth: chipLabel.implicitWidth + Theme.padM
                    implicitHeight: 22

                    Skew {
                        anchors.fill: parent
                        color: chip.current
                            ? Theme.alpha(Theme.primary, 0.22)
                            : (chipHover.hovered ? Theme.alpha(Theme.primary, 0.1) : "transparent")
                        borderWidth: 1
                        borderColor: chip.current ? Theme.primary : Theme.alpha(Theme.outline, 0.7)
                    }

                    Text {
                        id: chipLabel
                        anchors.centerIn: parent
                        text: chip.modelData.identity
                        color: chip.current ? Theme.text : Theme.muted
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fsMicro
                        renderType: Text.NativeRendering
                    }

                    HoverHandler {
                        id: chipHover
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: Media.select(chip.modelData)
                    }
                }
            }
        }
    }

    component TransportButton: Item {
        id: tb

        property string glyph: ""
        property bool primary: false
        property bool enabledControl: true

        signal clicked()

        implicitWidth: primary ? 38 : 30
        implicitHeight: primary ? 38 : 30

        Skew {
            anchors.fill: parent
            color: {
                if (!tb.enabledControl) return "transparent";
                if (tbHover.hovered) return tb.primary ? Theme.accent : Theme.alpha(Theme.primary, 0.22);
                return tb.primary ? Theme.alpha(Theme.primary, 0.18) : "transparent";
            }
            borderWidth: tb.primary ? 2 : 1
            borderColor: tb.enabledControl
                ? (tbHover.hovered ? Theme.text : Theme.alpha(Theme.primary, 0.6))
                : Theme.alpha(Theme.outline, 0.4)

            Behavior on color {
                ColorAnimation { duration: Theme.durFast }
            }
        }

        Icon {
            anchors.centerIn: parent
            text: tb.glyph
            font.pixelSize: tb.primary ? Theme.fsTitle : Theme.fsLarge
            color: {
                if (!tb.enabledControl) return Theme.alpha(Theme.muted, 0.5);
                if (tbHover.hovered && tb.primary) return Theme.text;
                return Theme.primary;
            }
        }

        scale: tbHover.hovered && tb.enabledControl ? 1.12 : 1.0
        Behavior on scale {
            NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutBack }
        }

        HoverHandler {
            id: tbHover
            enabled: tb.enabledControl
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            enabled: tb.enabledControl
            onTapped: tb.clicked()
        }
    }
}
