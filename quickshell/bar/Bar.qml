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

    // Flush with the screen edge and drawn on nothing: the hull behind it is
    // painted by Frame, which is what joins the bar, the rail and the border
    // into one surface. Exclusive zones are Frame's job too, so every piece
    // of the hull is placed from the screen edge rather than from whichever
    // piece the compositor happened to arrange first.
    exclusionMode: ExclusionMode.Ignore
    implicitHeight: Theme.barHeight
    color: "transparent"

    readonly property real edgeInset: Theme.padM

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

    // A hairline rule between modules. This is what divides the bar — gaps
    // between cards are what made it look scattered.
    component Divider: Item {
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: Theme.padM * 2
        implicitHeight: Theme.barHeight

        Rectangle {
            anchors.centerIn: parent
            width: 1
            height: 16
            color: Theme.alpha(Theme.outline, 0.6)
        }
    }
}
