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

        // Uneven gaps. An evenly spaced row of identical ticks reads as a
        // progress bar; the whole point here is that it should not.
        spacing: 5

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

                // Each tick pulls its own shear and its own height off the
                // variance tables, and sits a little off the baseline, so the
                // row is a ragged run of marks rather than a repeating comb.
                readonly property real shear: Theme.leanFor(pip.index)
                readonly property int baseHeight: [18, 14, 20, 16][pip.index % 4]
                readonly property int drift: [0, 2, -1, 1][pip.index % 4]

                width: focused ? 36 : (occupied ? 16 : 9)

                // The focused tick grows past its neighbours and past the row's
                // own height, so it breaks the line instead of sitting in it.
                height: focused ? 24 : pip.baseHeight
                y: focused ? -2 : pip.drift

                Behavior on width {
                    NumberAnimation {
                        duration: Theme.durSlow
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.6
                    }
                }
                Behavior on height {
                    NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutBack }
                }
                Behavior on y {
                    NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutBack }
                }

                // Black offset copy behind the focused tick — the same
                // screen-print stack the panels use, at tick scale.
                Rectangle {
                    visible: pip.focused
                    anchors.fill: parent
                    x: 3
                    y: 3
                    color: Theme.ink

                    transform: Matrix4x4 {
                        matrix: Qt.matrix4x4(
                            1, -pip.shear, 0, pip.height * pip.shear,
                            0, 1, 0, 0,
                            0, 0, 1, 0,
                            0, 0, 0, 1)
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
                            1, -pip.shear, 0, pip.height * pip.shear,
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
