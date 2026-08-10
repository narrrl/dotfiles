import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import "root:/config"
import "root:/components"

// The base surface for everything in this shell: a leaning, corner-chopped slab
// with an optional halftone wash and a crimson slash along its leading edge.
Item {
    id: root

    property color fill: Theme.surface
    property real fillOpacity: 0.94
    property color border: Theme.outline
    property real borderWidth: Theme.stroke

    // Lean of the vertical edges, as a fraction of height. 0 = upright.
    property real lean: Theme.skew
    property bool leanLeft: false

    // Tall panels (the right-hand rail) slant their horizontal edges instead,
    // by a fraction of width, and inset their content top/bottom rather than
    // left/right.
    property bool vertical: false

    // Corner chop size, and which corners get chopped (indices into the
    // polygon, clockwise from the top-left). Default chops the two corners that
    // read as "cut" against the lean.
    property real chop: Theme.cut
    property var chopCorners: [1, 3]

    // Crimson slash down the leading edge — the Persona 5 tell.
    property bool slash: false
    property color slashColor: Theme.accent
    property real slashWidth: 4

    // Screen-printed dot wash.
    property bool halftone: false
    property color halftoneColor: Theme.primary
    property real halftoneOpacity: 0.07

    // Inner glow along the top edge, for panels that should feel backlit.
    property bool sheen: false

    // The screen-print stack. A pure-black copy of the silhouette sits behind
    // the fill, offset down-and-right, and the fill carries a black keyline
    // outside its coloured border. Together these are what stop the panel from
    // reading as a flat clip-path.
    property bool drop: true
    property real dropOffset: Theme.dropOffset
    property color dropColor: Theme.ink
    property bool keyline: true
    property real keylineWidth: Theme.keylineWidth

    readonly property real leanInset:
        (vertical ? width : height) * Math.abs(lean)

    readonly property var polygon: vertical
        ? (leanLeft ? Geom.parallelogramVL(width, height, lean)
                    : Geom.parallelogramV(width, height, lean))
        : (leanLeft ? Geom.parallelogramL(width, height, lean)
                    : Geom.parallelogram(width, height, lean))

    // Child content lives inside `contentItem`, inset on both sides far enough
    // to clear the slanted edges. Panels do not auto-size: callers set implicit
    // sizes from their own layout (`row.implicitWidth + contentPad * 2`), which
    // keeps the shape maths out of every binding loop.
    default property alias content: contentHolder.data
    readonly property alias contentItem: contentHolder
    property real padding: Theme.padM

    readonly property real contentPad: padding + leanInset

    // Offset black copy of the silhouette, behind everything.
    Loader {
        anchors.fill: parent
        active: root.drop && root.dropOffset > 0
        sourceComponent: Shape {
            preferredRendererType: Shape.CurveRenderer
            asynchronous: false

            transform: Translate {
                x: root.dropOffset * (root.leanLeft ? -1 : 1)
                y: root.dropOffset
            }

            ShapePath {
                fillColor: root.dropColor
                strokeColor: "transparent"
                joinStyle: ShapePath.MiterJoin

                PathPolyline {
                    path: Geom.chamfer(root.polygon, root.chop, root.chopCorners)
                }
            }
        }
    }

    Shape {
        id: body
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        asynchronous: false

        // Fill, carrying the black keyline. The stroke is centred on the path,
        // so half of it sits outside the silhouette — which is exactly the
        // heavy outer contour the style wants.
        ShapePath {
            fillColor: Theme.alpha(root.fill, root.fillOpacity)
            strokeColor: root.keyline ? root.dropColor : "transparent"
            strokeWidth: root.keyline
                ? root.borderWidth + root.keylineWidth * 2
                : 0
            joinStyle: ShapePath.MiterJoin
            capStyle: ShapePath.FlatCap

            PathPolyline {
                path: Geom.chamfer(root.polygon, root.chop, root.chopCorners)
            }
        }

        // Coloured border, drawn on top of the keyline so it reads as an inlay.
        ShapePath {
            fillColor: "transparent"
            strokeColor: root.borderWidth > 0 ? root.border : "transparent"
            strokeWidth: root.borderWidth
            joinStyle: ShapePath.MiterJoin
            capStyle: ShapePath.FlatCap

            PathPolyline {
                path: Geom.chamfer(root.polygon, root.chop, root.chopCorners)
            }
        }
    }

    // Halftone wash, masked to the panel silhouette.
    Loader {
        anchors.fill: parent
        active: root.halftone
        asynchronous: true
        sourceComponent: Item {
            Shape {
                id: maskShape
                anchors.fill: parent
                visible: false
                layer.enabled: true
                layer.smooth: true
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                    fillColor: "white"
                    strokeColor: "transparent"
                    PathPolyline {
                        path: Geom.chamfer(root.polygon, root.chop, root.chopCorners)
                    }
                }
            }

            Image {
                anchors.fill: parent
                source: Theme.texHalftone
                fillMode: Image.Tile
                opacity: root.halftoneOpacity
                smooth: false
                layer.enabled: true
                layer.effect: MultiEffect {
                    colorization: 1.0
                    colorizationColor: root.halftoneColor
                    maskEnabled: true
                    maskSource: maskShape
                }
            }
        }
    }

    // Backlit top edge.
    Loader {
        anchors.fill: parent
        active: root.sheen
        sourceComponent: Shape {
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                strokeColor: "transparent"
                fillGradient: LinearGradient {
                    x1: 0; y1: 0; x2: 0; y2: root.height
                    GradientStop { position: 0.0; color: Theme.alpha(Theme.primary, 0.16) }
                    GradientStop { position: 0.55; color: "transparent" }
                }
                PathPolyline {
                    path: Geom.chamfer(root.polygon, root.chop, root.chopCorners)
                }
            }
        }
    }

    // Leading-edge slash.
    Loader {
        anchors.fill: parent
        active: root.slash
        sourceComponent: Shape {
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                fillColor: root.slashColor
                strokeColor: "transparent"
                PathPolyline {
                    path: {
                        const t = root.slashWidth;

                        // On a rail slab the slash runs along the slanted top
                        // edge instead of down a side.
                        if (root.vertical) {
                            const voff = root.width * root.lean;
                            return root.leanLeft
                                ? Geom.closed([Qt.point(0, 0), Qt.point(root.width, voff),
                                               Qt.point(root.width, voff + t), Qt.point(0, t)])
                                : Geom.closed([Qt.point(0, voff), Qt.point(root.width, 0),
                                               Qt.point(root.width, t), Qt.point(0, voff + t)]);
                        }

                        const off = root.height * root.lean;
                        return root.leanLeft
                            ? Geom.closed([Qt.point(0, 0), Qt.point(t, 0),
                                           Qt.point(off + t, root.height), Qt.point(off, root.height)])
                            : Geom.closed([Qt.point(off, 0), Qt.point(off + t, 0),
                                           Qt.point(t, root.height), Qt.point(0, root.height)]);
                    }
                }
            }
        }
    }

    Item {
        id: contentHolder
        anchors.fill: parent
        anchors.leftMargin: root.vertical ? root.padding : root.contentPad
        anchors.rightMargin: root.vertical ? root.padding : root.contentPad
        anchors.topMargin: root.vertical ? root.contentPad : root.padding
        anchors.bottomMargin: root.vertical ? root.contentPad : root.padding
    }
}
