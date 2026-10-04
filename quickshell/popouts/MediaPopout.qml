import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Widgets
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

        // Cover art, rounded, in a hairline frame.
        ClippingRectangle {
            id: artFrame
            anchors.top: header.bottom
            anchors.topMargin: Theme.padM
            anchors.left: parent.left
            width: 108
            height: 108
            radius: Theme.radiusL
            color: Theme.surface
            border.width: 1
            border.color: Theme.overlay

            Image {
                id: art
                anchors.fill: parent
                anchors.margins: 1
                source: Media.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                visible: status === Image.Ready
            }

            // Placeholder when the player exposes no artwork.
            Icon {
                anchors.centerIn: parent
                visible: art.status !== Image.Ready
                text: Media.sourceIcon
                font.pixelSize: 42
                color: Theme.muted
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
                weight: Font.DemiBold
            }

            Marquee {
                width: parent.width
                height: 16
                text: Media.artist
                color: Theme.primary
                pixelSize: Theme.fsSmall
                family: Theme.fontDisplay
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
                    enabled: Media.canGoPrevious
                    onClicked: Media.previous()
                }

                TransportButton {
                    glyph: Media.playing ? "󰏤" : "󰐊"
                    primary: true
                    enabled: Media.hasPlayer
                    onClicked: Media.playPause()
                }

                TransportButton {
                    glyph: "󰒭"
                    enabled: Media.canGoNext
                    onClicked: Media.next()
                }

                TransportButton {
                    glyph: "󰐒"
                    enabled: Media.hasPlayer
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
                text: Media.positionSupported ? Media.timeString(Media.position) : "--:--"
                color: Theme.subtext
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsMicro
                renderType: Text.NativeRendering
            }

            Text {
                id: total
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: Media.lengthSupported ? Media.timeString(Media.length) : "LIVE"
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
                enabled: Media.canSeek
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

                FocusScope {
                    id: chip
                    required property var modelData

                    readonly property bool current: Media.active === modelData

                    implicitWidth: chipLabel.implicitWidth + Theme.padM
                    implicitHeight: 22
                    focusPolicy: chip.enabled ? Qt.TabFocus : Qt.NoFocus

                    function activate(): void {
                        if (chip.enabled)
                            Media.select(chip.modelData);
                    }

                    function activateFromKey(event): void {
                        if (!event.isAutoRepeat)
                            chip.activate();
                    }

                    Skew {
                        anchors.fill: parent
                        radius: height / 2
                        color: !chip.enabled
                            ? Theme.treatmentDisabledFill
                            : (chip.activeFocus
                            ? Theme.treatmentFocusFill
                            : (chip.current
                                ? Theme.treatmentActiveFill
                                : (chipHover.hovered ? Theme.treatmentHoverFill : "transparent")))
                        borderWidth: chip.activeFocus ? Theme.stroke : 1
                        borderColor: !chip.enabled
                            ? Theme.treatmentDisabledMark
                            : (chip.activeFocus
                            ? Theme.treatmentFocusMark
                            : (chip.current ? Theme.treatmentActiveMark : Theme.alpha(Theme.outline, 0.7)))
                    }

                    Text {
                        id: chipLabel
                        anchors.centerIn: parent
                        text: chip.modelData.identity
                        color: !chip.enabled
                            ? Theme.treatmentDisabledText
                            : (chip.activeFocus
                            ? Theme.treatmentFocusText
                            : (chip.current || chipHover.hovered ? Theme.text : Theme.subtext))
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fsMicro
                        renderType: Text.NativeRendering
                    }

                    HoverHandler {
                        id: chipHover
                        enabled: chip.enabled
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        enabled: chip.enabled
                        onTapped: chip.activate()
                    }

                    Keys.onReturnPressed: event => chip.activateFromKey(event)
                    Keys.onEnterPressed: event => chip.activateFromKey(event)
                    Keys.onSpacePressed: event => chip.activateFromKey(event)
                }
            }
        }
    }

    component TransportButton: FocusScope {
        id: tb

        property string glyph: ""
        property bool primary: false
        signal clicked()

        implicitWidth: primary ? 38 : 30
        implicitHeight: primary ? 38 : 30
        focusPolicy: tb.enabled ? Qt.TabFocus : Qt.NoFocus

        function activate(): void {
            if (tb.enabled)
                tb.clicked();
        }

        function activateFromKey(event): void {
            if (!event.isAutoRepeat)
                tb.activate();
        }

        Skew {
            anchors.fill: parent
            radius: width / 2
            color: {
                if (!tb.enabled) return "transparent";
                if (tb.activeFocus) return Theme.treatmentFocusFill;
                // The play button is the one solid control on the panel: a
                // surface slab at rest, the accent slab under the pointer. The
                // others stay bare until hovered.
                if (tbHover.hovered) return tb.primary ? Theme.accent : Theme.treatmentHoverFill;
                return tb.primary ? Theme.surface : "transparent";
            }
            borderWidth: tb.activeFocus ? Theme.stroke * 2 : (tb.primary ? 2 : 1)
            borderColor: tb.enabled
                ? (tb.activeFocus
                    ? Theme.treatmentFocusMark
                    : (tbHover.hovered ? Theme.treatmentHoverMark : (tb.primary ? Theme.overlay : Theme.surfaceAlt)))
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
                if (!tb.enabled) return Theme.alpha(Theme.muted, 0.5);
                if (tb.activeFocus) return Theme.treatmentFocusText;
                // Ink on the accent slab, for contrast.
                if (tbHover.hovered && tb.primary) return Theme.ink;
                return Theme.text;
            }
        }


        HoverHandler {
            id: tbHover
            enabled: tb.enabled
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            enabled: tb.enabled
            onTapped: tb.activate()
        }

        Keys.onReturnPressed: event => tb.activateFromKey(event)
        Keys.onEnterPressed: event => tb.activateFromKey(event)
        Keys.onSpacePressed: event => tb.activateFromKey(event)
    }
}
