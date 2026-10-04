import QtQuick
import Quickshell
import Quickshell.Hyprland
import "root:/config"
import "root:/components"

// Workspace indicator: soft pills that stretch open when focused. Occupied
// workspaces fill in, urgent ones snap to the alarm colour.
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
                //
                // Kept well short of the bar's 20px divider rules. At 18px an
                // empty outline tick was the same height, lean and weight as a
                // divider, and the workspace strip read as a row of rules.
                width: focused ? 30 : (occupied ? 16 : 8)
                height: 14

                Behavior on width {
                    NumberAnimation {
                        duration: Theme.durSlow
                        easing.type: Easing.OutCubic
                    }
                }

                Skew {
                    id: tick
                    anchors.fill: parent
                    radius: height / 2

                    // Focused is a solid accent block. Urgent is a solid alarm
                    // block — it used to be the accent too, which made an
                    // urgent workspace indistinguishable from the focused one.
                    // Occupied is a subtext block. Empty is a flat recessed
                    // slot, filled rather than outlined so it cannot pass for a
                    // divider.
                    color: {
                        if (pip.focused) return Theme.accent;
                        if (pip.urgent) return Theme.alarm;
                        if (pip.hovered) return Theme.text;
                        if (pip.occupied) return Theme.subtext;
                        return Theme.surfaceAlt;
                    }

                    Behavior on color {
                        ColorAnimation { duration: Theme.durBase }
                    }

                    // Urgent is the one pip that has to be seen peripherally.
                    SequentialAnimation on opacity {
                        running: pip.urgent && !pip.focused
                        loops: Animation.Infinite
                        alwaysRunToEnd: true
                        NumberAnimation { to: 0.4; duration: 520; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 1.0; duration: 520; easing.type: Easing.InOutQuad }
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
                    font.pixelSize: Theme.fsSmall
                    font.weight: Theme.weightDisplay
                    renderType: Text.NativeRendering

                    Behavior on opacity {
                        NumberAnimation { duration: Theme.durBase }
                    }
                }

                // Fullscreen marker.
                Rectangle {
                    visible: pip.info !== undefined && pip.info.fullscreen && !pip.focused
                    width: 4; height: 4
                    radius: 2
                    color: Theme.accent
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.bottom
                    anchors.topMargin: 1
                }

                HoverHandler {
                    id: pipHover
                    cursorShape: Qt.PointingHandCursor
                }

                // Hyprland evaluates IPC `dispatch` payloads as Lua now that the
                // config is Lua (hyprland.lua rather than hyprland.conf), so the
                // old `dispatch workspace 3` string is a Lua syntax error and the
                // click silently does nothing. Dispatchers have to be called the
                // same way lua/binds/workspaces.lua calls them.
                TapHandler {
                    onTapped: Hyprland.dispatch("hl.dsp.focus({workspace = " + pip.wsId + "})")
                }
            }
        }

        // The Super+S scratchpad, after a gap: a ring while it holds windows,
        // filled with the light while it is open on this monitor. Absent when
        // it is empty, which is most of the time.
        Item {
            id: scratch
            readonly property var ws: {
                for (const w of (Hyprland.workspaces?.values ?? []))
                    if (w.name === "special:virtual") return w;
                return null;
            }
            readonly property int count: scratch.ws?.toplevels?.values?.length ?? 0
            readonly property bool shown: (root.monitor?.lastIpcObject?.specialWorkspace?.name ?? "")
                === "special:virtual"

            visible: scratch.count > 0
            width: 8 + 10
            height: 14

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 10
                height: 10
                radius: 5
                color: scratch.shown ? Theme.accent : "transparent"
                border.width: scratch.shown ? 0 : 1
                border.color: scratchHover.hovered ? Theme.text : Theme.subtext

                Behavior on color {
                    ColorAnimation { duration: Theme.durBase }
                }
            }

            HoverHandler {
                id: scratchHover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: Hyprland.dispatch("hl.dsp.workspace.toggle_special(\"virtual\")")
            }
        }
    }

    // The monitor snapshot carries which special workspace is open; it is only
    // refreshed on request.
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activespecial" || event.name === "activespecialv2")
                Hyprland.refreshMonitors();
        }
    }
}
