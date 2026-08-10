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
    implicitHeight: 20

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Repeater {
            model: root.slots

            Item {
                id: pip

                required property var modelData
                readonly property int wsId: modelData
                readonly property var info: root.occupancy[wsId]
                readonly property bool occupied: info !== undefined && info.count > 0
                readonly property bool urgent: info !== undefined && info.urgent
                readonly property bool focused: root.focusedId === wsId
                readonly property bool hovered: pipHover.hovered

                width: focused ? 34 : (occupied ? 16 : 10)
                height: 18

                Behavior on width {
                    NumberAnimation {
                        duration: Theme.durSlow
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.6
                    }
                }

                Rectangle {
                    id: tick
                    anchors.fill: parent
                    color: {
                        if (pip.urgent) return Theme.accent;
                        if (pip.focused) return Theme.primary;
                        if (pip.hovered) return Theme.glow;
                        if (pip.occupied) return Theme.alpha(Theme.primary, 0.55);
                        return Theme.alpha(Theme.outline, 0.75);
                    }

                    transform: Matrix4x4 {
                        matrix: Qt.matrix4x4(
                            1, -Theme.skew, 0, pip.height * Theme.skew,
                            0, 1, 0, 0,
                            0, 0, 1, 0,
                            0, 0, 0, 1)
                    }

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
                    color: Theme.base
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.fsSmall
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
