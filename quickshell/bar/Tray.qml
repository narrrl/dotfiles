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

    // Applets whose whole job the rail already does. blueman keeps running as
    // the pairing agent and nm-applet as the secrets agent, but their icons
    // were a second bluetooth and network glyph a few slots below the rail's
    // own.
    readonly property var hiddenIds: ["blueman", "nm-applet"]

    readonly property var shownItems: SystemTray.items.values
        .filter(item => root.hiddenIds.indexOf(item.id) === -1)

    // Electron and Chromium apps send only a full-colour pixmap, and flattening
    // that loses everything inside the outline: Brave's lion became a plain
    // shield. The icon theme often ships a panel glyph drawn for exactly this
    // job, so look one up by the app's name and use the pixmap only when none
    // exists. The id is no help here ("chrome_status_icon_1" for Brave and
    // Proton Pass alike), so the tooltip title is the name we go by.
    function themedIcon(item: SystemTrayItem): string {
        if (item.icon.startsWith("image://icon/")) return item.icon;

        const name = (item.tooltipTitle || item.title || item.id)
            .toLowerCase().replace(/[^a-z0-9]+/g, "-");
        for (const suffix of ["-tray", "-panel", "-symbolic"]) {
            const path = Quickshell.iconPath(name + suffix, true);
            if (path !== "") return path;
        }
        return item.icon;
    }

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
                source: root.themedIcon(entry.modelData)
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
