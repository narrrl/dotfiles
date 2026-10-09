import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "root:/config"
import "root:/components"
import "root:/services"

// Notification drawer, docked in the top-right corner of the opening.
// Replaces dunst.
//
// Not a stack of floating cards: one hull surface lowered out of the bar and
// out of the rail at once, the same construction as a corner-docked popout,
// with each notification an entry in it divided by its own header hairline.
// The drawer grows and shrinks with the entries and slides back behind the
// frame when the last one goes.
//
// A fullscreen window covers the bar and the rail, so there is no frame to
// lower the drawer out of. Then it floats free in the corner as a plain
// rounded panel instead.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    // A toast window exists on every screen, but each notification lands only
    // on the monitor that had focus when it arrived. Latched per toast rather
    // than live, so an entry does not hop screens while it is being read.

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "takemi-toasts"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
    readonly property bool floating: root.monitor?.activeWorkspace?.hasFullscreen ?? false

    // One pixel over the bar and the rail, so the drawer covers the rim the
    // hull draws along both edges instead of sitting inside it.
    anchors { top: true; right: true }
    margins {
        top: root.floating ? Theme.padM : Theme.barHeight - 1
        right: root.floating ? Theme.padM : Theme.railWidth - 1
    }

    readonly property real fillet: root.floating ? 0 : Theme.frameRadius
    readonly property real corner: Theme.frameRadius
    readonly property real seam: root.floating ? 0 : 1
    readonly property real drawerWidth: 400

    // Height of the entries, eased, so the drawer grows rather than jumps.
    property real bodyHeight: stack.implicitHeight
    Behavior on bodyHeight {
        NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutCubic }
    }

    // 0 = behind the frame, 1 = out. Follows whether anything is live.
    property real reveal: root.live.length > 0 ? 1 : 0
    Behavior on reveal {
        NumberAnimation {
            duration: Theme.durSlow
            easing.type: root.live.length > 0 ? Easing.OutCubic : Easing.InCubic
        }
    }

    implicitWidth: root.drawerWidth + root.fillet + root.seam
    implicitHeight: Math.max(1, root.bodyHeight + root.fillet + root.seam)
    color: "transparent"
    visible: root.live.length > 0 || root.reveal > 0

    mask: Region { item: stack }

    // Toasts currently on screen, newest first.
    property list<Notification> live: []
    property int maxLive: 5

    Connections {
        target: Notifs
        function onPopupRequested(notif) {
            if (Actions.focusedScreenName() !== root.modelData.name) return;
            root.live = [notif, ...root.live].slice(0, root.maxLive);
        }
        // Closed by its app or from the log: take it off screen too.
        function onNotifRetracted(notif) {
            root.retire(notif);
        }
    }

    function retire(notif) {
        const idx = root.live.indexOf(notif);
        if (idx === -1) return;
        const next = root.live.slice();
        next.splice(idx, 1);
        root.live = next;
    }

    Item {
        anchors.fill: parent
        clip: true

        Item {
            id: sheet
            width: parent.width
            height: parent.height
            y: -height * (1 - root.reveal)

            // Off the bar through the left fillet, round the one free corner,
            // onto the rail through the bottom fillet — Popout's "topRight".
            Shape {
                id: silhouette
                visible: !root.floating
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer

                readonly property real w: width
                readonly property real h: height
                readonly property real f: root.fillet
                readonly property real r: Math.min(root.corner, Math.max(0, (h - f) / 2))
                readonly property string edge:
                    `M 0 0 A ${f} ${f} 0 0 1 ${f} ${f}`
                    + ` V ${h - f - r} A ${r} ${r} 0 0 0 ${f + r} ${h - f}`
                    + ` H ${w - f} A ${f} ${f} 0 0 1 ${w} ${h}`

                ShapePath {
                    fillColor: Theme.hull
                    strokeColor: "transparent"
                    PathSvg { path: silhouette.edge + ` L ${silhouette.w} 0 Z` }
                }

                ShapePath {
                    fillColor: "transparent"
                    strokeColor: Theme.rim
                    strokeWidth: 1
                    PathSvg { path: silhouette.edge }
                }
            }

            Rectangle {
                visible: root.floating
                anchors.fill: parent
                radius: root.corner
                color: Theme.hull
                border.width: 1
                border.color: Theme.rim
            }

            Column {
                id: stack
                x: root.fillet
                y: root.seam
                width: root.drawerWidth
                bottomPadding: Theme.padS

                // A ScriptModel, not the bare list: it hands the Repeater only
                // what changed, so a new toast does not rebuild the others and
                // restart their fuses.
                Repeater {
                    model: ScriptModel { values: [...root.live] }

                    Item {
                        id: toast
                        required property var modelData

                        width: stack.width
                        height: card.implicitHeight

                        NotifCard {
                            id: card
                            width: parent.width
                            notif: toast.modelData
                            // Closing it retracts it, which retires the toast;
                            // nothing may run here after that, the entry is gone.
                            onDismissed: Notifs.dismiss(toast.modelData)
                        }

                        // Countdown: a hairline draining along the entry's
                        // foot, inset to the text column.
                        Rectangle {
                            id: fuse
                            anchors.bottom: parent.bottom
                            x: Theme.padM + Theme.marker + Theme.padS
                            height: 1
                            width: 0
                            color: Theme.alpha(card.tone, 0.5)
                            visible: life.running
                        }

                        readonly property real fuseSpan:
                            width - Theme.padM * 2 - Theme.marker - Theme.padS

                        NumberAnimation {
                            id: life
                            target: fuse
                            property: "width"
                            from: toast.fuseSpan
                            to: 0
                            running: false
                            duration: Notifs.timeoutFor(toast.modelData)
                            easing.type: Easing.Linear
                            onFinished: root.retire(toast.modelData)
                        }

                        // A new entry resolves in place: a fade, no shove.
                        opacity: 0

                        Component.onCompleted: {
                            enter.start();
                            const ms = Notifs.timeoutFor(toast.modelData);
                            if (ms > 0) life.start();
                        }

                        NumberAnimation {
                            id: enter
                            target: toast; property: "opacity"
                            to: 1; duration: Theme.durSlow; easing.type: Easing.OutCubic
                        }

                        // Hovering an entry pauses its fuse.
                        HoverHandler {
                            onHoveredChanged: {
                                if (!life.duration) return;
                                if (hovered) life.pause();
                                else if (life.paused) life.resume();
                            }
                        }

                        TapHandler {
                            acceptedButtons: Qt.LeftButton
                            onTapped: root.retire(toast.modelData)
                        }
                    }
                }
            }
        }
    }
}
