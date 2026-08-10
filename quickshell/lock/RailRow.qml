import QtQuick
import "root:/config"
import "root:/components"

// One line of the lock screen's status rail.
Item {
    id: rail

    property string glyph: ""
    property string label: ""
    property string detail: ""
    property color tone: Theme.primary

    implicitHeight: visible ? 38 : 0

    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 3
        height: 26
        color: rail.tone
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: Theme.padM
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.padS

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            text: rail.glyph
            color: rail.tone
            font.pixelSize: Theme.fsLarge
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: -2

            Text {
                text: rail.label
                color: Theme.text
                elide: Text.ElideRight
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fsSmall
                font.italic: true
                font.weight: Font.DemiBold
                renderType: Text.NativeRendering
            }

            Text {
                visible: rail.detail !== ""
                text: rail.detail
                color: Theme.muted
                elide: Text.ElideRight
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsMicro
                renderType: Text.NativeRendering
            }
        }
    }
}
