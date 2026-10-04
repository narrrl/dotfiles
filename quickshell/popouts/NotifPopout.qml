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

            ActionButton {
                text: Notifs.dnd ? "Silenced" : "Silence"
                icon: Notifs.dnd ? "󰂛" : "󰂚"
                accent: Notifs.dnd ? Theme.treatmentOffText : Theme.primary
                onClicked: Notifs.toggleDnd()
            }

            ActionButton {
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
            font.weight: Font.DemiBold
            font.letterSpacing: 3
            renderType: Text.NativeRendering
        }

        // The log, by sender. A sender with one notification is just that
        // entry. A sender with several gets a header — its name, how many, a
        // clear-all mark — over its newest entry, and opens to show the rest.
        ListView {
            id: log
            anchors.top: controls.bottom
            anchors.topMargin: Theme.padM
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true
            spacing: 0
            model: Notifs.groups

            // Which senders are open, by app name. Survives the list being
            // rebuilt when a notification arrives.
            property var expanded: ({})

            function toggle(app: string) {
                const next = Object.assign({}, log.expanded);
                next[app] = !next[app];
                log.expanded = next;
            }

            delegate: Column {
                id: group
                required property var modelData
                readonly property string app: group.modelData.app
                readonly property var items: group.modelData.items
                readonly property bool many: group.items.length > 1
                readonly property bool open: log.expanded[group.app] === true

                width: ListView.view.width

                Item {
                    id: groupHeader
                    visible: group.many
                    width: parent.width
                    height: group.many ? 30 : 0

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: Theme.padS / 2
                        radius: Theme.radiusL
                        color: headerHover.hovered ? Theme.treatmentHoverFill : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: Theme.durFast }
                        }
                    }

                    Row {
                        id: headerRow
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.padM
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.padS

                        Icon {
                            anchors.verticalCenter: parent.verticalCenter
                            text: Notifs.appIconFor(group.items[0])
                            color: Theme.subtext
                            font.pixelSize: Theme.fsBody
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: group.app.toUpperCase()
                            color: Theme.text
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fsMicro
                            font.letterSpacing: 2
                            renderType: Text.NativeRendering
                        }

                        // The count, in a small grey pill.
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: countText.implicitWidth + 10
                            height: countText.implicitHeight + 2
                            radius: height / 2
                            color: Theme.surfaceAlt

                            Text {
                                id: countText
                                anchors.centerIn: parent
                                text: group.items.length
                                color: Theme.subtext
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fsMicro
                                renderType: Text.NativeRendering
                            }
                        }
                    }

                    Rectangle {
                        anchors.left: headerRow.right
                        anchors.leftMargin: Theme.padS
                        anchors.right: chevron.left
                        anchors.rightMargin: Theme.padS
                        anchors.verticalCenter: parent.verticalCenter
                        height: 1
                        color: Theme.alpha(Theme.outline, 0.5)
                    }

                    Icon {
                        id: chevron
                        anchors.right: clearGroup.left
                        anchors.rightMargin: Theme.padS
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰅀"
                        rotation: group.open ? 180 : 0
                        color: headerHover.hovered ? Theme.accent : Theme.muted
                        font.pixelSize: Theme.fsBody

                        Behavior on rotation {
                            NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutCubic }
                        }
                    }

                    Icon {
                        id: clearGroup
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.padM
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰎟"
                        opacity: headerHover.hovered ? 1 : 0
                        color: clearHover.hovered ? Theme.alarm : Theme.muted
                        font.pixelSize: Theme.fsBody

                        Behavior on opacity {
                            NumberAnimation { duration: Theme.durFast }
                        }

                        HoverHandler {
                            id: clearHover
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                            onTapped: Notifs.dismissApp(group.app)
                        }
                    }

                    HoverHandler {
                        id: headerHover
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: log.toggle(group.app)
                    }
                }

                Repeater {
                    model: group.open ? group.items : group.items.slice(0, 1)

                    NotifCard {
                        required property var modelData
                        width: group.width
                        notif: modelData
                        showSender: !group.many
                        onDismissed: Notifs.dismiss(modelData)
                    }
                }

                // Folded: say how many more are behind the newest.
                Text {
                    visible: group.many && !group.open
                    leftPadding: Theme.padM + Theme.marker + Theme.padS
                    bottomPadding: Theme.padS
                    text: "+ " + (group.items.length - 1) + " more"
                    color: moreHover.hovered ? Theme.accent : Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsMicro
                    font.letterSpacing: 1
                    renderType: Text.NativeRendering

                    HoverHandler {
                        id: moreHover
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: log.toggle(group.app)
                    }
                }
            }

            add: Transition {
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
