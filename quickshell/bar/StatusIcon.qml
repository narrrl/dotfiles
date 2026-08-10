import QtQuick
import "root:/config"
import "root:/components"

// One indicator inside the status cluster: a glyph, an optional readout, and a
// crimson underline that wipes in on hover.
Item {
    id: root

    property string icon: ""
    property string label: ""
    property color tint: Theme.primary
    property bool alert: false
    property bool dim: false
    property bool pulsing: false

    // Fixed label width. Readouts that change width constantly (throughput,
    // percentages) would otherwise shove the whole cluster around.
    property real labelWidth: 0

    readonly property bool hovered: hover.hovered

    signal clicked()
    signal rightClicked()
    signal middleClicked()
    signal scrolled(real delta)

    implicitWidth: layout.implicitWidth
    implicitHeight: Theme.barHeight - Theme.padS * 2

    Row {
        id: layout
        anchors.centerIn: parent
        spacing: 5

        Icon {
            id: glyph
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            pulsing: root.pulsing
            color: {
                if (root.alert) return Theme.accent;
                if (root.dim) return Theme.muted;
                if (root.hovered) return Theme.glow;
                return root.tint;
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.label !== ""
            text: root.label
            width: root.labelWidth > 0 ? root.labelWidth : implicitWidth
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
            color: root.dim ? Theme.muted : Theme.subtext
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsSmall
            font.weight: Font.DemiBold
            renderType: Text.NativeRendering

            Behavior on color {
                ColorAnimation { duration: Theme.durBase }
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        height: 2
        width: root.hovered ? layout.implicitWidth : 0
        color: root.alert ? Theme.accent : root.tint

        Behavior on width {
            NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutExpo }
        }
    }

    scale: root.hovered ? 1.06 : 1.0
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
    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: root.rightClicked()
    }
    TapHandler {
        acceptedButtons: Qt.MiddleButton
        onTapped: root.middleClicked()
    }
    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => root.scrolled(event.angleDelta.y)
    }
}
