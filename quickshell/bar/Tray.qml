import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "root:/config"
import "root:/components"

// StatusNotifier tray. Left click activates, right click opens the app's own
// menu, middle click is the secondary action.
BarPill {
    id: root

    required property var screenRef

    accent: Theme.blue
    padding: Theme.padS
    interactive: false
    visible: SystemTray.items.values.length > 0
    implicitWidth: visible ? layout.implicitWidth + contentPad * 2 : 0

    Row {
        id: layout
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        spacing: Theme.padM

        Repeater {
            model: SystemTray.items

            Item {
                id: entry

                required property SystemTrayItem modelData

                width: 18
                height: 18
                anchors.verticalCenter: parent.verticalCenter

                IconImage {
                    id: img
                    anchors.fill: parent
                    source: entry.modelData.icon
                    asynchronous: true
                    opacity: itemHover.hovered ? 1.0 : 0.82

                    Behavior on opacity {
                        NumberAnimation { duration: Theme.durFast }
                    }
                }

                scale: itemHover.hovered ? 1.18 : 1.0
                Behavior on scale {
                    NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutBack }
                }

                HoverHandler {
                    id: itemHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onTapped: {
                        if (entry.modelData.onlyMenu) {
                            menuAnchor.open();
                        } else {
                            entry.modelData.activate();
                        }
                    }
                }

                TapHandler {
                    acceptedButtons: Qt.RightButton
                    onTapped: menuAnchor.open()
                }

                TapHandler {
                    acceptedButtons: Qt.MiddleButton
                    onTapped: entry.modelData.secondaryActivate()
                }

                QsMenuAnchor {
                    id: menuAnchor
                    menu: entry.modelData.menu
                    anchor.item: entry
                    anchor.edges: Edges.Bottom
                    anchor.gravity: Edges.Bottom
                    anchor.margins.top: Theme.popoutGap
                }
            }
        }
    }
}
