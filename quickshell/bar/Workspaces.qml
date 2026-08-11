import QtQuick
import Quickshell
import Quickshell.Hyprland
import "root:/config"
import "root:/components"

// Workspace indicator: leaning ticks that stretch open when focused. Occupied
// workspaces glow teal, urgent ones snap to crimson.
Item {
    id: root

    required property var screenRef

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screenRef)
    readonly property int focusedId: monitor?.activeWorkspace?.id ?? -1

    // Live workspaces on this monitor, keyed by id, ignoring special workspaces.
    readonly property var occupancy: {
        const map = {};
        for (const w of (Hyprland.workspaces?.values ?? [])) {
            if (w.id < 1) continue;
            if (root.monitor && w.monitor && w.monitor.id !== root.monitor.id) continue;
            map[w.id] = {
                count: w.toplevels?.values?.length ?? 0,
                urgent: w.urgent,
                fullscreen: w.hasFullscreen
            };
        }
        return map;
    }

    // Always show 1..5, plus anything beyond that which is actually in use.
    readonly property var slots: {
        const ids = [1, 2, 3, 4, 5];
        for (const key in root.occupancy) {
            const id = parseInt(key);
            if (ids.indexOf(id) === -1) ids.push(id);
        }
        return ids.sort((a, b) => a - b);
    }

    implicitWidth: row.implicitWidth
    implicitHeight: 24

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter

        spacing: 6

        Repeater {
            model: root.slots

            Item {
                id: pip

                required property var modelData
                required property int index
                readonly property int wsId: modelData
                readonly property var info: root.occupancy[wsId]
                readonly property bool occupied: info !== undefined && info.count > 0
                readonly property bool urgent: info !== undefined && info.urgent
                readonly property bool focused: root.focusedId === wsId
                readonly property bool hovered: pipHover.hovered

                // Every tick is the same height and the same shear. Only the
                // width changes, and only to say which workspace is focused.
                width: focused ? 32 : (occupied ? 16 : 9)
                height: 18

                Behavior on width {
                    NumberAnimation {
                        duration: Theme.durSlow
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.6
                    }
                }

                Skew {
                    id: tick
                    anchors.fill: parent

                    // Focused is a solid crimson block. Occupied is a white
                    // block at half weight. Empty is an outline. Three states,
                    // two colours, no ambiguity.
                    color: {
                        if (pip.focused || pip.urgent) return Theme.accent;
                        if (pip.hovered) return Theme.text;
                        if (pip.occupied) return Theme.alpha(Theme.text, 0.5);
                        return "transparent";
                    }
                    borderColor: pip.occupied || pip.focused
                        ? "transparent"
                        : Theme.alpha(Theme.text, 0.35)
                    borderWidth: 1

                    Behavior on color {
                        ColorAnimation { duration: Theme.durBase }
                    }
                }

                // The focused workspace wears its number.
                Text {
                    anchors.centerIn: parent
                    opacity: pip.focused ? 1 : 0
                    visible: opacity > 0.01
                    text: pip.wsId
                    color: Theme.ink
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.fsBody
                    font.weight: Theme.weightDisplay
                    font.italic: true
                    renderType: Text.NativeRendering

                    Behavior on opacity {
                        NumberAnimation { duration: Theme.durBase }
                    }
                }

                // Fullscreen marker.
                Rectangle {
                    visible: pip.info !== undefined && pip.info.fullscreen && !pip.focused
                    width: 4; height: 4
                    color: Theme.accent
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.bottom
                    anchors.topMargin: 1
                }

                HoverHandler {
                    id: pipHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: Hyprland.dispatch("workspace " + pip.wsId)
                }
            }
        }
    }
}
