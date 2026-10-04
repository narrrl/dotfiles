import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "root:/config"
import "root:/components"
import "root:/services"

// One notification, used both in the history list and in the toast drawer.
//
// Laid out like an entry in NieR's message log rather than as a card: a square
// marker and the sender's name running into a hairline, the summary, the body,
// and hairline buttons for any actions. There is no panel of its own — both
// places it appears are already hull surfaces — so rest is bare, hover lifts
// the row onto the surface tone, and entries are divided by the hairline in
// their own header.
//
// Urgency is the marker: the light for normal, grey for low, red for critical.
// A critical entry also takes the red into its sender line, and nothing else.
Item {
    id: root

    required property var notif
    property bool showActions: true

    readonly property bool critical: root.notif?.urgency === NotificationUrgency.Critical
    readonly property color tone: root.notif
        ? Notifs.urgencyColor(root.notif.urgency)
        : Theme.primary

    // Kept for callers that size things to the card's edges; there is no lean
    // or chop under the YoRHa theme.
    readonly property real lean: 0
    readonly property real chop: 0

    readonly property bool hovered: hover.hovered

    signal dismissed()

    implicitHeight: layout.implicitHeight + Theme.padM * 2

    Rectangle {
        anchors.fill: parent
        color: root.hovered ? Theme.treatmentHoverFill : "transparent"

        Behavior on color {
            ColorAnimation { duration: Theme.durFast }
        }
    }

    Column {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.padM
        spacing: 4

        // Sender: marker, glyph, name, then the hairline to the edge.
        Item {
            width: parent.width
            height: 16

            Rectangle {
                id: marker
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.marker
                height: Theme.marker
                color: root.tone
            }

            Icon {
                id: glyph
                visible: text !== ""
                anchors.left: marker.right
                anchors.leftMargin: Theme.padS
                anchors.verticalCenter: parent.verticalCenter
                text: Notifs.appIconFor(root.notif)
                color: root.critical ? Theme.alarm : Theme.muted
                font.pixelSize: Theme.fsBody
            }

            Text {
                id: sender
                anchors.left: glyph.visible ? glyph.right : marker.right
                anchors.leftMargin: Theme.padS
                anchors.verticalCenter: parent.verticalCenter
                text: (root.notif?.appName || "System").toUpperCase()
                color: root.critical ? Theme.alarm : Theme.muted
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsMicro
                font.letterSpacing: 2
                renderType: Text.NativeRendering
            }

            Rectangle {
                anchors.left: sender.right
                anchors.leftMargin: Theme.padS
                anchors.right: close.left
                anchors.rightMargin: Theme.padS
                anchors.verticalCenter: parent.verticalCenter
                height: 1
                color: Theme.alpha(Theme.outline, 0.5)
            }

            // Close affordance: always there, quiet until the row is hovered.
            Icon {
                id: close
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: "󰅖"
                opacity: root.hovered ? 1 : 0.0
                color: closeHover.hovered ? Theme.accent : Theme.muted
                font.pixelSize: Theme.fsBody

                Behavior on opacity {
                    NumberAnimation { duration: Theme.durFast }
                }

                HoverHandler {
                    id: closeHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: root.dismissed()
                }
            }
        }

        Text {
            width: parent.width
            leftPadding: Theme.marker + Theme.padS
            text: root.notif?.summary || ""
            color: root.hovered ? Theme.accent : Theme.text
            elide: Text.ElideRight
            maximumLineCount: 2
            wrapMode: Text.WordWrap
            font.family: Theme.fontDisplay
            font.pixelSize: Theme.fsBody
            font.weight: Theme.weightDisplay
            renderType: Text.NativeRendering

            Behavior on color {
                ColorAnimation { duration: Theme.durFast }
            }
        }

        Text {
            width: parent.width
            leftPadding: Theme.marker + Theme.padS
            visible: text !== ""
            text: root.notif?.body || ""
            color: Theme.subtext
            elide: Text.ElideRight
            maximumLineCount: 4
            wrapMode: Text.WordWrap
            textFormat: Text.StyledText
            font.family: Theme.fontDisplay
            font.pixelSize: Theme.fsSmall
            lineHeight: 1.1
            renderType: Text.NativeRendering
        }

        // Inline image, when the sender supplied one, in a hairline frame.
        Rectangle {
            x: Theme.marker + Theme.padS
            visible: inline.source != "" && inline.status === Image.Ready
            width: inline.width + 2
            height: inline.height + 2
            color: "transparent"
            border.width: 1
            border.color: Theme.overlay

            Image {
                id: inline
                x: 1
                y: 1
                source: root.notif?.image || ""
                sourceSize.height: 90
                fillMode: Image.PreserveAspectFit
                asynchronous: true
            }
        }

        Row {
            x: Theme.marker + Theme.padS
            visible: root.showActions && (root.notif?.actions?.length ?? 0) > 0
            spacing: Theme.padS
            topPadding: 4

            Repeater {
                model: root.notif?.actions ?? []

                // A hairline button with a marker, the P5Button pattern at a
                // smaller size. Hover lifts and lights it; it never inverts.
                Item {
                    id: actionChip
                    required property var modelData

                    implicitWidth: chipRow.implicitWidth + Theme.padM * 2
                    implicitHeight: 24

                    Rectangle {
                        anchors.fill: parent
                        color: actionHover.hovered ? Theme.treatmentHoverFill : "transparent"
                        border.width: 1
                        border.color: actionHover.hovered ? Theme.treatmentHoverMark : Theme.overlay

                        Behavior on color {
                            ColorAnimation { duration: Theme.durFast }
                        }
                    }

                    Row {
                        id: chipRow
                        anchors.centerIn: parent
                        spacing: Theme.padS

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 4
                            height: 4
                            color: actionLabel.color
                            opacity: actionHover.hovered ? 1 : 0.4
                        }

                        Text {
                            id: actionLabel
                            anchors.verticalCenter: parent.verticalCenter
                            text: actionChip.modelData.text.toUpperCase()
                            color: actionHover.hovered ? Theme.accent : Theme.text
                            font.family: Theme.fontDisplay
                            font.pixelSize: Theme.fsMicro
                            font.letterSpacing: Theme.tracking
                            renderType: Text.NativeRendering
                        }
                    }

                    HoverHandler {
                        id: actionHover
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: {
                            actionChip.modelData.invoke();
                            root.dismissed();
                        }
                    }
                }
            }
        }
    }

    HoverHandler {
        id: hover
    }

    // Middle click dismisses, matching the old dunst muscle memory.
    TapHandler {
        acceptedButtons: Qt.MiddleButton
        onTapped: root.dismissed()
    }
}
