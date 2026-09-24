import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "root:/config"
import "root:/components"
import "root:/popouts"

// StatusNotifier tray, as a vertical column for the right-hand rail. Left click
// activates, right click opens the app's own menu, middle click is the
// secondary action. The surrounding slab is the caller's business — this is
// just the stack of icons.
Column {
    id: root

    spacing: Theme.padS + 2
    visible: root.shownItems.length > 0

    // Applets whose whole job the rail already does. nm-applet and blueman keep
    // running — they are the Wi-Fi secret agent and the pairing agent — but
    // their icons were a second network and a second bluetooth glyph a few
    // slots below the rail's own.
    readonly property var hiddenIds: ["nm-applet", "blueman"]

    readonly property var shownItems: SystemTray.items.values
        .filter(item => root.hiddenIds.indexOf(item.id) === -1)

    Repeater {
        model: root.shownItems

        Item {
            id: entry

            required property SystemTrayItem modelData

            width: 18
            height: 18
            anchors.horizontalCenter: parent.horizontalCenter

            // App icons arrive in their own brand colours, which wrecks the
            // two-hue palette faster than anything else in the shell. Flatten
            // every one of them to a single-colour silhouette: subtext at rest,
            // a notch under the rail's own glyphs, and accent under the pointer. Detail inside the glyph is lost on
            // purpose — that flattening *is* the screen-printed look.
            IconImage {
                id: img
                anchors.fill: parent
                source: entry.modelData.icon
                asynchronous: true

                layer.enabled: true
                layer.effect: TintEffect {
                    tintColor: itemHover.hovered
                        ? Theme.accent
                        : Theme.subtext

                    Behavior on tintColor {
                        ColorAnimation { duration: Theme.durFast }
                    }
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
                        menu.toggle();
                    } else {
                        entry.modelData.activate();
                    }
                }
            }

            TapHandler {
                acceptedButtons: Qt.RightButton
                onTapped: {
                    if (entry.modelData.hasMenu) menu.toggle();
                }
            }

            TapHandler {
                acceptedButtons: Qt.MiddleButton
                onTapped: entry.modelData.secondaryActivate()
            }

            // Menus open to the left, into the screen rather than off its edge.
            TrayMenu {
                id: menu
                anchorItem: entry
                menuHandle: entry.modelData.menu
            }
        }
    }
}
