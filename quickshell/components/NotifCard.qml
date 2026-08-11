import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "root:/config"
import "root:/components"
import "root:/services"

// One notification, used both in the history list and as a floating toast.
Item {
    id: root

    required property var notif
    property bool showActions: true

    readonly property color tone: root.notif
        ? Notifs.urgencyColor(root.notif.urgency)
        : Theme.primary

    signal dismissed()

    // The card's own geometry, published so anything drawn along its edges —
    // the toast countdown rule — can stay inside the chopped corners instead of
    // running out past them.
    readonly property real lean: 0.05
    readonly property real chop: 12

    implicitHeight: panel.height

    P5Panel {
        id: panel
        width: parent.width
        height: layout.implicitHeight + Theme.padM * 2
        lean: root.lean
        chop: root.chop
        fill: Theme.surface
        fillOpacity: 0.97
        border: Theme.alpha(root.tone, hover.hovered ? 0.95 : 0.5)
        slash: true
        slashColor: root.tone
        slashWidth: 4
        halftone: root.notif?.urgency === NotificationUrgency.Critical
        halftoneColor: Theme.accent
        halftoneOpacity: 0.12
        padding: Theme.padM

        Column {
            id: layout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            // App line
            Row {
                spacing: Theme.padS

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Notifs.appIconFor(root.notif)
                    color: root.tone
                    font.pixelSize: Theme.fsBody
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: (root.notif?.appName || "System").toUpperCase()
                    color: root.tone
                    font.family: Theme.fontMono
                    font.pixelSize: 8
                    font.letterSpacing: 2
                    renderType: Text.NativeRendering
                }
            }

            Text {
                width: parent.width
                text: root.notif?.summary || ""
                color: Theme.text
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.WordWrap
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fsBody
                font.weight: Font.Black
                font.italic: true
                renderType: Text.NativeRendering
            }

            Text {
                width: parent.width
                visible: text !== ""
                text: root.notif?.body || ""
                color: Theme.subtext
                elide: Text.ElideRight
                maximumLineCount: 4
                wrapMode: Text.WordWrap
                textFormat: Text.StyledText
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fsSmall
                renderType: Text.NativeRendering
            }

            // Inline image, when the sender supplied one.
            Image {
                visible: source != "" && status === Image.Ready
                source: root.notif?.image || ""
                sourceSize.height: 90
                fillMode: Image.PreserveAspectFit
                asynchronous: true
            }

            Row {
                visible: root.showActions && (root.notif?.actions?.length ?? 0) > 0
                spacing: Theme.padS
                topPadding: Theme.padS

                Repeater {
                    model: root.notif?.actions ?? []

                    Item {
                        id: actionChip
                        required property var modelData

                        implicitWidth: actionLabel.implicitWidth + Theme.padM
                        implicitHeight: 22

                        Skew {
                            anchors.fill: parent
                            color: actionHover.hovered
                                ? Theme.alpha(root.tone, 0.3)
                                : Theme.alpha(root.tone, 0.1)
                            borderWidth: 1
                            borderColor: Theme.alpha(root.tone, 0.6)
                        }

                        Text {
                            id: actionLabel
                            anchors.centerIn: parent
                            text: actionChip.modelData.text
                            color: Theme.text
                            font.family: Theme.fontDisplay
                            font.pixelSize: Theme.fsMicro
                            font.italic: true
                            font.weight: Font.DemiBold
                            renderType: Text.NativeRendering
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

        // Close affordance.
        Icon {
            anchors.right: parent.right
            anchors.top: parent.top
            visible: hover.hovered
            text: "󰅖"
            color: closeHover.hovered ? Theme.accent : Theme.muted
            font.pixelSize: Theme.fsBody

            HoverHandler {
                id: closeHover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: root.dismissed()
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
