import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "root:/config"
import "root:/components"

// StatusNotifier tray, as a vertical column for the right-hand rail. Left click
// activates, right click opens the app's own menu, middle click is the
// secondary action. The surrounding slab is the caller's business — this is
// just the stack of icons.
Column {
    id: root

    spacing: Theme.padS + 2
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items

        Item {
            id: entry

            required property SystemTrayItem modelData

            width: 18
            height: 18
            anchors.horizontalCenter: parent.horizontalCenter

            // App icons arrive in their own brand colours, which wrecks the
            // two-hue palette faster than anything else in the shell. Flatten
            // every one of them to a single-colour silhouette: white at rest,
            // crimson under the pointer. Detail inside the glyph is lost on
            // purpose — that flattening *is* the screen-printed look.
            IconImage {
                id: img
                anchors.fill: parent
                source: entry.modelData.icon
                asynchronous: true

                layer.enabled: true
                layer.effect: MultiEffect {
                    colorization: 1.0
                    colorizationColor: itemHover.hovered
                        ? Theme.accent
                        : Theme.text

                    Behavior on colorizationColor {
                        ColorAnimation { duration: Theme.durFast }
                    }
                }

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

            // Menus open to the left, into the screen rather than off its edge.
            QsMenuAnchor {
                id: menuAnchor
                menu: entry.modelData.menu
                anchor.item: entry
                anchor.edges: Edges.Left
                anchor.gravity: Edges.Left
                anchor.margins.right: Theme.popoutGap
            }
        }
    }
}
