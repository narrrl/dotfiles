import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import "root:/config"

// The hull: one surface for the bar, the rail and the thin band down the left
// and along the bottom, with the desktop as a rounded opening cut out of it.
// The idea is caelestia's screen border; the reading is the wallpaper's — you
// are inside the ship, and the windows sit in the porthole.
//
// The hull lives on the bottom layer, under every window. Hyprland's gaps keep
// tiled windows inside the opening, so nothing ever has to be drawn over a
// window; a floating window dragged onto the frame simply covers it, and a
// fullscreen one hides it, which is what should happen in both cases.
//
// The bar and the rail draw no surface of their own and ignore exclusive
// zones, so every piece is placed from the screen edge. The four zones are
// reserved here instead, by windows that draw nothing — that way the usable
// area is exactly the opening, whichever surface the compositor arranges
// first.
Scope {
    id: root

    required property var modelData

    PanelWindow {
        id: hull

        screen: root.modelData

        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "takemi-frame"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "transparent"
        mask: Region {}

        // The opening, in window coordinates.
        readonly property real x0: Theme.frame
        readonly property real y0: Theme.barHeight
        readonly property real x1: width - Theme.railWidth
        readonly property real y1: height - Theme.frame
        readonly property real r: Theme.frameRadius

        readonly property string opening: {
            const x0 = hull.x0, y0 = hull.y0, x1 = hull.x1, y1 = hull.y1, r = hull.r;
            return `M ${x0 + r} ${y0} H ${x1 - r} A ${r} ${r} 0 0 1 ${x1} ${y0 + r}`
                 + ` V ${y1 - r} A ${r} ${r} 0 0 1 ${x1 - r} ${y1}`
                 + ` H ${x0 + r} A ${r} ${r} 0 0 1 ${x0} ${y1 - r}`
                 + ` V ${y0 + r} A ${r} ${r} 0 0 1 ${x0 + r} ${y0} Z`;
        }

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            // The hull itself: the whole screen, minus the opening.
            ShapePath {
                fillColor: Theme.hull
                fillRule: ShapePath.OddEvenFill
                strokeColor: "transparent"

                PathSvg {
                    path: `M 0 0 H ${hull.width} V ${hull.height} H 0 Z ` + hull.opening
                }
            }

            // The rim — a hairline round the opening, the lit edge of the
            // porthole in the wallpaper.
            ShapePath {
                fillColor: "transparent"
                strokeColor: Theme.rim
                strokeWidth: 1

                PathSvg {
                    path: hull.opening
                }
            }
        }
    }

    ExclusionZone {
        anchors.top: true
        exclusiveZone: Theme.barHeight
    }

    ExclusionZone {
        anchors.right: true
        exclusiveZone: Theme.railWidth
    }

    ExclusionZone {
        anchors.bottom: true
        exclusiveZone: Theme.frame
    }

    ExclusionZone {
        anchors.left: true
        exclusiveZone: Theme.frame
    }

    component ExclusionZone: PanelWindow {
        screen: root.modelData
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "takemi-frame-zone"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        color: "transparent"
        mask: Region {}
        implicitWidth: 1
        implicitHeight: 1
    }
}
