import QtQuick
import QtQuick.Shapes
import "root:/config"
import "root:/components"

// A leaning block — the small-scale counterpart to P5Panel.
//
// Every tick, rule, meter segment and slider rail in this shell leans at
// Theme.skew. Shearing a plain Rectangle with a Matrix4x4 does that, but Qt
// rasterises a Rectangle's geometry with no antialiasing at all, so the slanted
// edges come out as a hard pixel staircase — at 18px tall that staircase is
// most of what you see, and it reads as broken rendering rather than as a
// deliberate angle. Drawing the parallelogram as a Shape with the curve
// renderer gets analytic coverage AA on the diagonals instead.
//
// Drop-in for a sheared Rectangle: set width/height as before and use `color`,
// `borderColor` and `borderWidth` the same way.
Shape {
    id: root

    property color color: "transparent"
    property color borderColor: "transparent"
    property real borderWidth: 0

    // Lean of the vertical edges as a fraction of height, matching P5Panel.
    property real lean: Theme.skew
    property bool leanLeft: false

    // Wide, short pieces — the rail's hairline rules — slant their horizontal
    // edges by a fraction of width instead, exactly as P5Panel does for the
    // rail slab.
    property bool vertical: false

    preferredRendererType: Shape.CurveRenderer
    asynchronous: false

    ShapePath {
        fillColor: root.color
        strokeColor: root.borderWidth > 0 ? root.borderColor : "transparent"
        strokeWidth: root.borderWidth
        joinStyle: ShapePath.MiterJoin
        capStyle: ShapePath.FlatCap

        PathPolyline {
            path: {
                const w = root.width, h = root.height, l = root.lean;
                if (root.vertical)
                    return Geom.closed(root.leanLeft ? Geom.parallelogramVL(w, h, l)
                                                     : Geom.parallelogramV(w, h, l));
                return Geom.closed(root.leanLeft ? Geom.parallelogramL(w, h, l)
                                                 : Geom.parallelogram(w, h, l));
            }
        }
    }
}
