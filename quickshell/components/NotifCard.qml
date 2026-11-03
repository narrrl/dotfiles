import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import "root:/config"
import "root:/components"
import "root:/services"

// One notification, used both in the history list and in the toast drawer.
//
// Laid out like an entry in NieR's message log rather than as a card: a dot
// and the sender's name running into a hairline, the summary, the body, and
// pill buttons for any actions. There is no panel of its own — both places it
// appears are already hull surfaces — so rest is bare, hover lifts the entry
// onto a soft rounded wash, and entries are divided by the hairline in their
// own header.
//
// Urgency is the dot: the light for normal, grey for low, red for critical.
// A critical entry also takes the red into its sender line, and nothing else.
Item {
    id: root

    required property var notif
    property bool showActions: true
    // Off inside a group in the log, whose header already names the sender:
    // the entry keeps only its urgency dot, the hairline and the close mark.
    property bool showSender: true
    // "toast" or "log": where this card is, so a reply field opened here is
    // the one that gets the keyboard.
    property string surface: "log"

    readonly property bool critical: root.notif?.urgency === NotificationUrgency.Critical
    readonly property color tone: root.notif
        ? Notifs.urgencyColor(root.notif.urgency)
        : Theme.primary

    // Kept for callers that size things to the card's edges; there is no lean
    // or chop under the YoRHa theme.
    readonly property real lean: 0
    readonly property real chop: 0

    readonly property bool hovered: hover.hovered

    // Apps that take an answer in place (chat clients) get a REPLY chip; it
    // opens a field under the entry. Enter sends, Escape puts it away.
    readonly property bool canReply: root.showActions && !Notifs.isRetracted(root.notif)
        && (root.notif?.hasInlineReply ?? false)
    readonly property bool replying: root.canReply && Notifs.replying === root.notif
        && Notifs.replySurface === root.surface

    signal dismissed()

    implicitHeight: layout.implicitHeight + Theme.padM * 2

    // Hover wash. Inset by padS and rounded by radiusL, which is the frame's
    // radius less that inset: an entry in the bottom corner of the drawer gets
    // a corner concentric with the drawer's own, instead of a square one that
    // ran out past the drawer's curve.
    Rectangle {
        anchors.fill: parent
        anchors.margins: Theme.padS / 2
        radius: Theme.radiusL
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
                radius: width / 2
                color: root.tone
            }

            Icon {
                id: glyph
                visible: root.showSender && text !== ""
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
                anchors.leftMargin: root.showSender ? Theme.padS : 0
                anchors.verticalCenter: parent.verticalCenter
                width: root.showSender ? implicitWidth : 0
                visible: root.showSender
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

        // Inline image, when the sender supplied one, rounded in a hairline frame.
        ClippingRectangle {
            x: Theme.marker + Theme.padS
            visible: inline.source != "" && inline.status === Image.Ready
            width: inline.width + 2
            height: inline.height + 2
            radius: Theme.radiusM
            color: "transparent"
            border.width: 1
            border.color: Theme.overlay

            Image {
                id: inline
                x: 1
                y: 1
                // A path given as an image hint (notify-send -h image-path:…)
                // comes back routed through the icon provider, which treats
                // it as an icon name and returns a placeholder. Load the file.
                source: {
                    const img = root.notif?.image || "";
                    if (img.startsWith("image://icon//")) return "file://" + img.slice("image://icon/".length);
                    return img.startsWith("/") ? "file://" + img : img;
                }
                sourceSize.height: 90
                fillMode: Image.PreserveAspectFit
                asynchronous: true
            }
        }

        Row {
            x: Theme.marker + Theme.padS
            // Gone once the app has closed the notification: nothing is
            // listening for the action any more.
            visible: root.showActions && !Notifs.isRetracted(root.notif)
                && ((root.notif?.actions?.length ?? 0) > 0 || root.canReply)
            spacing: Theme.padS
            topPadding: 4

            Repeater {
                // "inline-reply" is how the reply itself is announced, not a
                // button of its own; the REPLY chip below stands for it.
                model: (root.notif?.actions ?? []).filter(a => a.identifier !== "inline-reply")

                // A hairline pill. Hover lifts and lights it; it never inverts.
                Item {
                    id: actionChip
                    required property var modelData

                    implicitWidth: chipRow.implicitWidth + Theme.padM * 2
                    implicitHeight: 24

                    Rectangle {
                        anchors.fill: parent
                        radius: height / 2
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
                            radius: 2
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
                        onTapped: Notifs.invoke(root.notif, actionChip.modelData)
                    }
                }
            }

            Item {
                id: replyChip
                visible: root.canReply && !root.replying
                implicitWidth: replyRow.implicitWidth + Theme.padM * 2
                implicitHeight: 24

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: replyHover.hovered ? Theme.treatmentHoverFill : "transparent"
                    border.width: 1
                    border.color: replyHover.hovered ? Theme.treatmentHoverMark : Theme.overlay
                }

                Row {
                    id: replyRow
                    anchors.centerIn: parent
                    spacing: Theme.padS

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰑚"
                        color: replyLabel.color
                        font.pixelSize: Theme.fsSmall
                    }

                    Text {
                        id: replyLabel
                        anchors.verticalCenter: parent.verticalCenter
                        text: "REPLY"
                        color: replyHover.hovered ? Theme.accent : Theme.text
                        font.family: Theme.fontDisplay
                        font.pixelSize: Theme.fsMicro
                        font.letterSpacing: Theme.tracking
                        renderType: Text.NativeRendering
                    }
                }

                HoverHandler {
                    id: replyHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: Notifs.startReply(root.notif, root.surface)
                }
            }
        }

        // The reply field: a hairline capsule with the cursor in it, the same
        // shape as the chips it replaces.
        Item {
            x: Theme.marker + Theme.padS
            width: parent.width - x
            height: root.replying ? 30 : 0
            visible: root.replying

            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 4
                radius: height / 2
                color: Theme.surface
                border.width: 1
                border.color: replyInput.activeFocus ? Theme.accent : Theme.overlay
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: Theme.padM
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 2
                visible: replyInput.text === ""
                text: root.notif?.inlineReplyPlaceholder || "Reply…"
                color: Theme.muted
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fsSmall
                renderType: Text.NativeRendering
            }

            TextInput {
                id: replyInput
                anchors.left: parent.left
                anchors.right: sendMark.left
                anchors.leftMargin: Theme.padM
                anchors.rightMargin: Theme.padS
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 2
                clip: true
                color: Theme.accent
                selectionColor: Theme.accent
                selectedTextColor: Theme.ink
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fsSmall
                renderType: Text.NativeRendering

                onAccepted: Notifs.sendReply(root.notif, text)
                Keys.onEscapePressed: Notifs.cancelReply()
            }

            Icon {
                id: sendMark
                anchors.right: parent.right
                anchors.rightMargin: Theme.padM
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 2
                text: "󰒊"
                color: replyInput.text !== "" ? Theme.accent : Theme.muted
                font.pixelSize: Theme.fsBody

                TapHandler {
                    onTapped: Notifs.sendReply(root.notif, replyInput.text)
                }
            }
        }
    }

    HoverHandler {
        id: hover
    }

    // The window takes the keyboard a moment after `replying` turns on, so
    // ask for focus once more when it does.
    onReplyingChanged: {
        replyInput.text = "";
        if (root.replying) focusLater.restart();
    }
    Timer {
        id: focusLater
        interval: 50
        onTriggered: replyInput.forceActiveFocus()
    }

    // Middle click dismisses, matching the old dunst muscle memory.
    TapHandler {
        acceptedButtons: Qt.MiddleButton
        onTapped: root.dismissed()
    }
}
