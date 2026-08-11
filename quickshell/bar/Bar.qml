import QtQuick
import Quickshell
import Quickshell.Wayland
import "root:/config"
import "root:/components"
import "root:/services"

// One bar per monitor, and one surface.
//
// Identity and workspaces on the left, the player, metrics and clock on the
// right, all inside a single continuous slab and separated by hairline rules
// rather than by gaps. Nothing floats and nothing has its own card. Status
// lives on the rail, which is likewise one slab — two surfaces, not a dozen
// islands.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "takemi-bar"

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: Theme.barMargin
        left: Theme.barMargin
        right: Theme.barMargin
    }

    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight + Theme.barMargin
    color: "transparent"

    // The slab. One panel, full width, flat fill, black keyline.
    P5Panel {
        id: slab
        anchors.fill: parent
        lean: Theme.skew
        chop: Theme.cut
        chopCorners: [1, 3]
        padding: 0
        fill: Theme.surface
        fillOpacity: 1.0
        border: Theme.alpha(Theme.outline, 0.9)
        borderWidth: 1
        slash: true
        slashColor: Theme.accent
        slashWidth: 5

        // No offset copy on the big slabs. The 3px black silhouette behind the
        // fill is a print-misregistration trick, and at this scale it stops
        // reading as one: on a 1900px bar you only ever see it at the chopped
        // corners, where it turns the single clean cut into a staggered double
        // edge that looks like a rendering fault. The black keyline still
        // carries the heavy outer contour, which is what the corner needs.
        drop: false
    }

    readonly property real edgeInset: Theme.barHeight * Theme.skew + Theme.padM

    // ------------------------------------------------------------------ left
    Row {
        id: leftGroup
        anchors.left: parent.left
        anchors.leftMargin: root.edgeInset
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Sigil {
            id: sigil
            screenRef: root.modelData
        }

        Divider {}

        Workspaces {
            id: spaces
            anchors.verticalCenter: parent.verticalCenter
            screenRef: root.modelData
        }

        Divider {}

        ActiveWindow {
            anchors.verticalCenter: parent.verticalCenter
            screenRef: root.modelData
            maxWidth: Math.max(120, root.width
                - leftGroup.x - rightGroup.width - sigil.implicitWidth
                - spaces.implicitWidth - root.edgeInset * 2 - Theme.padXL)
        }
    }

    // ----------------------------------------------------------------- right
    Row {
        id: rightGroup
        anchors.right: parent.right
        anchors.rightMargin: root.edgeInset
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        MediaPill {
            screenRef: root.modelData
        }

        Divider {}

        Resources {
            screenRef: root.modelData
        }

        Divider {}

        Clock {
            screenRef: root.modelData
        }
    }

    // A hairline rule between modules, sheared to the house angle. This is what
    // divides the bar now — gaps between cards are what made it look scattered.
    component Divider: Item {
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: Theme.padM * 2
        implicitHeight: Theme.barHeight

        Skew {
            anchors.centerIn: parent
            width: 1
            height: 20
            color: Theme.alpha(Theme.outline, 0.9)
        }
    }
}
