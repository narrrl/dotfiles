import QtQuick
import QtQuick.Shapes
import "root:/config"
import "root:/components"

// A small block — the small-scale counterpart to Panel. Upright and rounded
// under the YoRHa theme; it still leans if given a lean.
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

    // Lean of the vertical edges as a fraction of height, matching Panel.
    property real lean: Theme.skew
    property bool leanLeft: false

    // Wide, short pieces — the rail's hairline rules — slant their horizontal
    // edges by a fraction of width instead, exactly as Panel does for the
    // rail slab.
    property bool vertical: false

    // Corner radius for an upright piece, clamped to a pill. Small by default,
    // so a meter segment or a hover wash reads soft rather than as a block;
    // a hairline stays a hairline.
    property real radius: Theme.radiusS

    // NOTE ON SIZING. The lean shifts one edge by `lean * height` (or by
    // `lean * width` when vertical), and the piece that actually gets painted is
    // what is left: a Skew declared 1px wide and 20px tall does not draw a 1px
    // rule at an angle, it draws a rule |1 - 20 * 0.249| = 4px thick that hangs
    // 4px to the *left* of the box it was given. That is why the bar's and the
    // rail's hairlines came out fat and off-centre. A thin leaning rule has to be
    // declared with room for its own lean — `height * Theme.skew + weight` — and
    // the call sites that draw one now do exactly that.
    //
    // Zero-sized pieces still have a lean offset, so a collapsed hover wipe or a
    // meter at 0 drew a sub-pixel wedge of pure accent — the stray red dot under
    // the metrics. Nothing with no extent should paint at all.
    visible: root.width > 0 && root.height > 0

    preferredRendererType: Shape.CurveRenderer
    asynchronous: false

    ShapePath {
        fillColor: root.color
        strokeColor: root.borderWidth > 0 ? root.borderColor : "transparent"
        strokeWidth: root.borderWidth
        joinStyle: ShapePath.MiterJoin
        capStyle: ShapePath.FlatCap

        PathSvg {
            path: {
                const w = root.width, h = root.height, l = root.lean;
                if (l === 0)
                    return Geom.roundedRect(w, h, root.radius);
                if (root.vertical)
                    return Geom.svg(root.leanLeft ? Geom.parallelogramVL(w, h, l)
                                                  : Geom.parallelogramV(w, h, l));
                return Geom.svg(root.leanLeft ? Geom.parallelogramL(w, h, l)
                                              : Geom.parallelogram(w, h, l));
            }
        }
    }
}
