import QtQuick
import "root:/config"

// One row of a popout list — a Wi-Fi network, a bluetooth device, an audio
// output. The pickers used to draw their own rows, each with its own height and
// its own translucent white wash for hover, which on Mocha's blue-grey ground
// came out as a faint milky film. This is the one row they share now.
//
// Rest is bare. Hover lifts the row onto the surface tone. The current item —
// connected, in use — carries a dot at its leading edge and
// an accent glyph, and its label goes to full weight.
Item {
    id: root

    property string icon: ""
    property string label: ""
    // Optional mono line under the label: a device state, an address.
    property string detail: ""
    property bool current: false

    // Right-aligned trailing content — a lock, a battery level, a tag.
    default property alias trailing: trailingRow.data

    readonly property bool hovered: hover.hovered

    signal clicked()
    signal rightClicked()

    implicitHeight: root.detail !== "" ? 36 : 30

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusM
        color: root.hovered ? Theme.treatmentHoverFill : "transparent"

        Behavior on color {
            ColorAnimation { duration: Theme.durFast }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 2
        width: root.current ? Theme.marker : 0
        height: width
        radius: width / 2
        color: Theme.accent

        Behavior on width {
            NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutCubic }
        }
    }

    Icon {
        id: glyph
        anchors.left: parent.left
        anchors.leftMargin: Theme.padM
        anchors.verticalCenter: parent.verticalCenter
        width: 18
        visible: root.icon !== ""
        text: root.icon
        color: root.current ? Theme.accent : (root.hovered ? Theme.text : Theme.subtext)
        font.pixelSize: Theme.fsLarge
    }

    Column {
        anchors.left: glyph.visible ? glyph.right : parent.left
        anchors.leftMargin: glyph.visible ? Theme.padS : Theme.padM
        anchors.right: trailingRow.left
        anchors.rightMargin: Theme.padS
        anchors.verticalCenter: parent.verticalCenter
        spacing: -1

        Text {
            width: parent.width
            text: root.label
            elide: Text.ElideRight
            color: root.current || root.hovered ? Theme.text : Theme.subtext
            font.family: Theme.fontDisplay
            font.pixelSize: Theme.fsSmall
            font.weight: root.current ? Font.DemiBold : Font.Medium
            renderType: Text.NativeRendering
        }

        Text {
            width: parent.width
            visible: text !== ""
            text: root.detail
            elide: Text.ElideRight
            color: Theme.muted
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            renderType: Text.NativeRendering
        }
    }

    Row {
        id: trailingRow
        anchors.right: parent.right
        anchors.rightMargin: Theme.padS
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4
    }

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
}
