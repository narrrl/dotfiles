import QtQuick
import "root:/config"
import "root:/components"

// The shared ground for the two full-screen surfaces, in the NieR menu
// pattern: a hairline grid that sweeps in from the left, a darker column down
// the left-hand side for the menu or the clock to stand in, and a dot wash
// over the top.
//
// The lock screen and the power menu both stand on this one component, which
// is what makes them read as the same object seen twice rather than as two
// guesses at the same brief.
Item {
    id: root

    // 0 = withdrawn, 1 = fully present. Drives the grid slide, the grid
    // opacity and the column together, so a caller animates one number instead
    // of keeping three in sync. The power menu runs it both ways on open and
    // close; the lock runs it once on entry.
    property real reveal: 1

    property color tone: Theme.accent

    // The column: a band of the void, edged by a hairline of the light.
    // `wedge*` names are kept from the Persona layout so callers did not have
    // to move; there is nothing wedge-shaped left.
    property bool wedge: true
    property real wedgeOpacity: 0.35
    property real wedgeLeft: 0
    property real wedgeSpan: 0.34

    property bool stripes: true
    property real stripeOpacity: 0.05

    property bool halftone: true
    property real halftoneOpacity: 0.05
    property color halftoneColor: Theme.primary

    // Hairline grid, sliding in from off-screen left.
    Image {
        anchors.fill: parent
        visible: root.stripes && root.reveal > 0
        source: Theme.texGrid
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

    // The column. Drawn after the grid so it reads as a panel laid over it.
    Item {
        x: root.wedgeLeft * root.width
        width: root.wedgeSpan * root.width
        height: root.height
        visible: root.wedge && root.reveal > 0
        opacity: root.reveal

        Rectangle {
            anchors.fill: parent
            color: Theme.alpha(Theme.ink, root.wedgeOpacity)
        }

        // Its edge, drawn top-down as the column arrives.
        Rectangle {
            anchors.right: parent.right
            width: 1
            height: parent.height * root.reveal
            color: Theme.alpha(root.tone, 0.35)
        }
    }

    // Dot wash over the whole thing.
    Image {
        anchors.fill: parent
        visible: root.halftone
        source: Theme.texDots
        fillMode: Image.Tile
        opacity: root.halftoneOpacity
        smooth: false
        layer.enabled: true
        layer.effect: TintEffect { tintColor: root.halftoneColor }
    }
}
