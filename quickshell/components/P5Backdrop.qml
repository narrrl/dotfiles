import QtQuick
import QtQuick.Shapes
import "root:/config"
import "root:/components"

// The shared ground for the two full-screen surfaces: a crimson wedge leaning
// at the house angle, a tiled stripe field that sweeps in from the left, and a
// halftone dot wash over the top.
//
// The lock screen and the power menu each used to draw their own version of
// this. They disagreed — the power menu had a wedge and a full stripe field,
// the lock had a 42px stripe band and no wedge, and the wedge leaned at 0.32
// where every panel in the shell leans at Theme.skew. Building both on one
// component is what makes them read as the same object seen twice rather than
// as two guesses at the same brief.
Item {
    id: root

    // 0 = withdrawn, 1 = fully present. Drives the stripe slide, the stripe
    // opacity and the wedge together, so a caller animates one number instead
    // of keeping three in sync. The power menu runs it both ways on open and
    // close; the lock runs it once on entry.
    property real reveal: 1

    property color tone: Theme.accent

    property bool wedge: true
    property real wedgeOpacity: 0.35
    // Bottom-left corner of the wedge and its span, as fractions of width. The
    // wedge leans right going up, like every other edge in the shell, so its
    // top edge sits `leanOffset` further right than its bottom.
    property real wedgeLeft: 0
    property real wedgeSpan: 0.34

    property bool stripes: true
    property real stripeOpacity: 0.10

    property bool halftone: true
    property real halftoneOpacity: 0.05
    property color halftoneColor: Theme.primary

    // ONE angle, everywhere — the same rule the panels follow.
    readonly property real leanOffset: root.height * Theme.skew

    // Diagonal stripe field, sliding in from off-screen left.
    Image {
        anchors.fill: parent
        visible: root.stripes && root.reveal > 0
        source: Theme.texStripes
        fillMode: Image.Tile
        opacity: root.stripeOpacity * root.reveal
        smooth: false

        layer.enabled: true
        layer.effect: TintEffect {
            tintColor: root.tone
        }

        transform: Translate {
            x: -root.width * (1 - root.reveal)
        }
    }

    // The wedge. Drawn after the stripes so it reads as a slab laid over them.
    Shape {
        anchors.fill: parent
        visible: root.wedge && root.reveal > 0
        opacity: root.reveal
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: Theme.alpha(Theme.accentDim, root.wedgeOpacity)
            strokeColor: "transparent"
            joinStyle: ShapePath.MiterJoin

            PathPolyline {
                path: {
                    const x = root.wedgeLeft * root.width;
                    const span = root.wedgeSpan * root.width;
                    const off = root.leanOffset;
                    return Geom.closed([
                        Qt.point(x + off, 0),
                        Qt.point(x + off + span, 0),
                        Qt.point(x + span, root.height),
                        Qt.point(x, root.height)
                    ]);
                }
            }
        }
    }

    // Screen-printed dot wash over the whole thing.
    Image {
        anchors.fill: parent
        visible: root.halftone
        source: Theme.texHalftone
        fillMode: Image.Tile
        opacity: root.halftoneOpacity
        smooth: false
        layer.enabled: true
        layer.effect: TintEffect { tintColor: root.halftoneColor }
    }
}
