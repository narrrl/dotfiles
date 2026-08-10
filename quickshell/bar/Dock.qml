import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import "root:/config"
import "root:/components"
import "root:/services"

// The floating bottom-left cluster: now playing, plus the CPU/MEM/GPU readout.
//
// This one reserves no space at all. Windows tile the full height of the screen
// underneath it, and the input mask is clipped to the cluster itself so clicks
// anywhere else in the corner fall straight through to whatever is below.
//
// At rest it sits at a quarter opacity — present enough to read at a glance,
// faint enough to ignore — and snaps to full weight when the pointer arrives.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "takemi-dock"

    anchors {
        bottom: true
        left: true
    }

    margins {
        bottom: Theme.dockMargin
        left: Theme.dockMargin
    }

    implicitWidth: cluster.implicitWidth
    implicitHeight: cluster.implicitHeight

    exclusiveZone: 0
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    // Only the cluster takes pointer input; the rest of the surface is
    // transparent to clicks.
    mask: Region { item: cluster }

    readonly property bool awake: clusterHover.hovered || Media.playing

    // A crimson wedge pinned to the corner. This is the one part of the dock
    // that never fades — it marks where the cluster lives so a nearly
    // invisible idle state is still something you can aim at, and it doubles
    // as the corner furniture the layout was missing.
    Shape {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: 26
        height: 26
        z: -1
        preferredRendererType: Shape.CurveRenderer
        opacity: root.awake ? 0.0 : 0.9

        Behavior on opacity {
            NumberAnimation { duration: Theme.durBase }
        }

        ShapePath {
            fillColor: Theme.accent
            strokeColor: "transparent"
            PathPolyline {
                path: [
                    Qt.point(0, 26),
                    Qt.point(0, 6),
                    Qt.point(26, 26),
                    Qt.point(0, 26)
                ]
            }
        }
    }

    Row {
        id: cluster
        spacing: Theme.barGap

        opacity: root.awake ? 1.0 : Theme.dockIdleOpacity

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.durSlow
                easing.type: Easing.OutExpo
            }
        }

        // Lift off the corner as it wakes.
        transform: Translate {
            y: root.awake ? 0 : 4

            Behavior on y {
                NumberAnimation {
                    duration: Theme.durSlow
                    easing.type: Easing.OutBack
                }
            }
        }

        HoverHandler {
            id: clusterHover
        }

        MediaPill {
            screenRef: root.modelData
        }

        Resources {
            screenRef: root.modelData
        }
    }
}
