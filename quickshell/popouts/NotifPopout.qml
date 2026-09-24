import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "root:/config"
import "root:/components"
import "root:/services"

// Notification history and the do-not-disturb switch.
Popout {
    id: root

    contentWidth: 400
    contentHeight: 380

    PopoutSurface {
        anchors.fill: parent
        tone: Notifs.dnd ? Theme.muted : Theme.primary

        PopoutHeader {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            title: "Notifications"
            icon: Notifs.icon
            accent: Notifs.dnd ? Theme.muted : Theme.primary
            subtitle: Notifs.count + " HELD"
        }

        Row {
            id: controls
            anchors.top: header.bottom
            anchors.topMargin: Theme.padM
            anchors.left: parent.left
            spacing: Theme.padS

            P5Button {
                text: Notifs.dnd ? "Silenced" : "Silence"
                icon: Notifs.dnd ? "󰂛" : "󰂚"
                accent: Notifs.dnd ? Theme.treatmentOffText : Theme.primary
                onClicked: Notifs.toggleDnd()
            }

            P5Button {
                text: "Clear"
                icon: "󰎟"
                destructive: true
                onClicked: Notifs.clearAll()
            }
        }

        Text {
            anchors.centerIn: parent
            visible: Notifs.count === 0
            text: "NOTHING TO REPORT"
            color: Theme.muted
            font.family: Theme.fontDisplay
            font.pixelSize: Theme.fsBody
            font.italic: true
            font.weight: Font.Black
            font.letterSpacing: 3
            renderType: Text.NativeRendering
        }

        ListView {
            anchors.top: controls.bottom
            anchors.topMargin: Theme.padM
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true
            spacing: Theme.padS
            model: Notifs.history

            delegate: NotifCard {
                required property var modelData
                width: ListView.view.width
                notif: modelData
                onDismissed: Notifs.dismiss(modelData)
            }

            add: Transition {
                NumberAnimation {
                    properties: "x"
                    from: 40
                    duration: Theme.durSlow
                    easing.type: Easing.OutBack
                }
                NumberAnimation {
                    property: "opacity"
                    from: 0; to: 1
                    duration: Theme.durBase
                }
            }

            remove: Transition {
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: Theme.durFast
                }
            }

            displaced: Transition {
                NumberAnimation {
                    properties: "y"
                    duration: Theme.durBase
                    easing.type: Easing.OutExpo
                }
            }
        }
    }
}
