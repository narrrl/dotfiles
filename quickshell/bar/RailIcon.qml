import QtQuick
import "root:/config"
import "root:/components"

// One slot on the right-hand rail: a glyph with an optional micro readout
// stacked beneath it, and a crimson bar that wipes down the leading edge on
// hover. The rail is only 48px wide, so unlike StatusIcon the readout sits
// under the glyph rather than beside it, and anything longer than a percentage
// belongs in the popout instead.
Item {
    id: root

    property string icon: ""
    property string readout: ""
    property string label: ""
    property string statusText: ""
    property string hint: ""
    property bool suppressTooltip: false
    property color tint: Theme.primary
    property bool alert: false
    property bool dim: false
    property bool pulsing: false

    readonly property bool hovered: hover.hovered

    // Clearance between the wipe and the rail's left edge, chosen so the bar
    // stays inside the slab once `scale` has expanded the icon about its centre.
    readonly property real wipeInset: 5

    signal clicked()
    signal scrolled(real delta)

    implicitWidth: Theme.railWidth
    implicitHeight: root.readout !== "" ? 42 : 32

    Column {
        id: layout
        anchors.centerIn: parent
        spacing: 1

        Icon {
            id: glyph
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.icon
            pulsing: root.pulsing
            font.pixelSize: Theme.fsLarge
            color: {
                if (root.alert) return Theme.accent;
                if (root.dim) return Theme.muted;
                if (root.hovered) return Theme.glow;
                return root.tint;
            }

            Behavior on color {
                ColorAnimation { duration: Theme.durBase }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.readout !== ""
            text: root.readout
            color: root.dim ? Theme.muted : Theme.subtext
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            font.weight: Font.DemiBold
            renderType: Text.NativeRendering

            Behavior on color {
                ColorAnimation { duration: Theme.durBase }
            }
        }
    }

    // Leading-edge wipe. On the rail this runs vertically down the left side,
    // mirroring the slash P5Panel puts on horizontal modules.
    //
    // Held off the edge by `wipeInset`: the icon spans the rail's full width, so
    // at x = 0 this landed exactly on the slab's own border, and the 1.08 hover
    // scale then pushed it out past the silhouette onto the desktop. The inset
    // has to survive that scale, which is why it is not simply 1 or 2.
    //
    // It is crimson rather than `tint` because it only ever appears on hover,
    // and hover is crimson everywhere else in the shell (Theme.glow). Painting
    // it white put a white bar on the rail's edge for no stated reason.
    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: root.wipeInset
        anchors.verticalCenter: parent.verticalCenter
        width: 2
        height: root.hovered ? layout.implicitHeight : 0
        color: Theme.glow

        Behavior on height {
            NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutExpo }
        }
    }

    scale: root.hovered ? 1.08 : 1.0
    Behavior on scale {
        NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutBack }
    }

    onAlertChanged: if (alert) glyph.bump()

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: root.clicked()
    }
    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => root.scrolled(event.angleDelta.y)
    }

    P5Tooltip {
        anchorItem: root
        triggerHovered: root.hovered
        title: root.label
        status: root.statusText
        hint: root.hint
        suppressed: root.suppressTooltip
    }
}
