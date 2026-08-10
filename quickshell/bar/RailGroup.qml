import QtQuick
import "root:/config"
import "root:/components"

// A slab on the right-hand rail. The vertical counterpart to BarPill: it sizes
// itself to a stacked column rather than a row, and pulls its lean and chamfer
// from the shape-variance tables by `variant`, so no two slabs on the rail are
// congruent.
Item {
    id: root

    property color accent: Theme.primary
    property int variant: 0
    property bool active: false
    property real padding: Theme.padS
    property bool interactive: false
    property bool halftone: false

    readonly property bool hovered: hover.hovered
    readonly property real contentPad: panel.contentPad
    readonly property alias panelItem: panel

    default property alias content: holder.data

    signal clicked()

    implicitWidth: Theme.railWidth

    P5Panel {
        id: panel
        anchors.fill: parent
        vertical: true

        // Scaled down from the horizontal tables: a rail slab leans by a
        // fraction of its 48px width, so the raw values would be far too steep.
        lean: Theme.leanFor(root.variant) * 0.6
        leanLeft: Theme.leanLeftFor(root.variant)
        chop: Math.min(Theme.chopFor(root.variant), 10)
        chopCorners: Theme.cornersFor(root.variant)

        padding: root.padding
        halftone: root.halftone
        halftoneColor: root.accent
        sheen: true

        fill: root.active ? Theme.surfaceAlt : Theme.surface
        fillOpacity: root.hovered ? 0.98 : 0.88
        border: root.hovered || root.active
            ? Theme.alpha(root.accent, 0.9)
            : Theme.alpha(Theme.outline, 0.7)
        borderWidth: root.hovered || root.active ? Theme.stroke : 1

        slash: root.active
        slashColor: root.accent

        Behavior on fillOpacity {
            NumberAnimation { duration: Theme.durFast }
        }
        Behavior on border {
            ColorAnimation { duration: Theme.durBase }
        }

        Item {
            id: holder
            anchors.fill: parent
        }
    }

    // Slabs lift toward the pointer, away from the screen edge.
    transform: Translate {
        x: root.hovered && root.interactive ? -3 : 0

        Behavior on x {
            NumberAnimation {
                duration: Theme.durBase
                easing.type: Easing.OutBack
            }
        }
    }

    HoverHandler {
        id: hover
        enabled: root.interactive
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        enabled: root.interactive
        acceptedButtons: Qt.LeftButton
        onTapped: root.clicked()
    }
}
