import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "root:/config"
import "root:/services"

// The wallpaper, seen through the porthole. It is drawn a little larger than
// the screen and drifts when the workspace changes: windows slide past
// vertically (hypr/lua/animations.lua) and the scene behind them moves a few
// pixels the same way and a little later, the way distant things do out of a
// moving window. Only on switches — it never moves on its own, so an idle
// desktop costs the compositor nothing.
//
// It also settles a shade darker while the workspace holds windows, so the
// band of wallpaper round them reads as the far side of the glass rather than
// as part of the desktop.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "takemi-backdrop"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: Theme.ink
    mask: Region {}

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
    readonly property HyprlandWorkspace workspace: root.monitor?.activeWorkspace ?? null

    // Overscan: how much bigger than the screen the picture is drawn, which is
    // the room it has to drift in.
    readonly property real overscan: 1.08
    readonly property real slack: root.height * (root.overscan - 1)

    // Workspaces 1–10 spread across the slack, so 1 sits at the top of the
    // picture and each step down moves it a fixed distance. Special and
    // named workspaces (negative ids) leave it where it was.
    property real drift: 0
    readonly property int wsId: root.workspace?.id ?? 1
    onWsIdChanged: if (root.wsId > 0) root.drift = Math.min(root.wsId - 1, 9) / 9

    readonly property bool occupied: (root.workspace?.toplevels?.values?.length ?? 0) > 0

    Image {
        id: picture
        width: root.width * root.overscan
        height: root.height * root.overscan
        x: -(width - root.width) / 2
        y: -root.drift * root.slack
        source: Wallpaper.forMonitor(root.screen?.name ?? "")
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
        cache: false

        opacity: status === Image.Ready ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.durLazy; easing.type: Easing.OutCubic }
        }

        // Longer than Hyprland's 550ms workspace slide, on the same curve, so
        // the windows arrive first and the scene catches up.
        Behavior on y {
            NumberAnimation {
                duration: 900
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.35, 0.0, 0.15, 1.0, 1.0, 1.0]
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.ink
        opacity: root.occupied ? 0.18 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.durLazy; easing.type: Easing.InOutSine }
        }
    }

    Component.onCompleted: root.drift = Math.min(Math.max(root.wsId, 1) - 1, 9) / 9
}
