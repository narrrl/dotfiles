import QtQuick
import "root:/config"
import "root:/components"

// Shared chrome for every bar module: a leaning slab that lifts and lights up
// under the pointer, and forwards clicks and scrolls to the widget.
Item {
    id: root

    property color accent: Theme.primary
    property bool active: false
    property bool slash: false
    property real lean: Theme.skew
    property bool leanLeft: false
    property real padding: Theme.padM
    property bool interactive: true
    property bool halftone: false

    // Chamfer, forwarded so modules can differ from one another instead of all
    // sharing the panel default.
    property real chop: Theme.cut
    property var chopCorners: [1, 3]

    readonly property bool hovered: hover.hovered
    readonly property real leanInset: panel.leanInset

    // Total horizontal inset a pill must add on top of its content width.
    readonly property real contentPad: panel.contentPad
    readonly property alias panelItem: panel

    default property alias content: holder.data

    signal clicked()
    signal rightClicked()
    signal middleClicked()
    signal scrolled(real delta)

    implicitHeight: Theme.barHeight

    P5Panel {
        id: panel
        anchors.fill: parent
        lean: root.lean
        leanLeft: root.leanLeft
        chop: root.chop
        chopCorners: root.chopCorners
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

        slash: root.slash || root.active
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

    // Lift toward the pointer. Subtle, but it makes the bar feel alive.
    transform: Translate {
        y: root.hovered && root.interactive ? -2 : 0

        Behavior on y {
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

    TapHandler {
        enabled: root.interactive
        acceptedButtons: Qt.RightButton
        onTapped: root.rightClicked()
    }

    TapHandler {
        enabled: root.interactive
        acceptedButtons: Qt.MiddleButton
        onTapped: root.middleClicked()
    }

    WheelHandler {
        enabled: root.interactive
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => root.scrolled(event.angleDelta.y)
    }
}
