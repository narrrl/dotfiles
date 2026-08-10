import QtQuick
import "root:/config"
import "root:/components"

// Title bar for a popout: glyph, split-ink heading, right-aligned status text,
// and a crimson rule with a chopped tail.
Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property string icon: ""
    property color accent: Theme.primary

    implicitHeight: 34

    Row {
        anchors.left: parent.left
        anchors.top: parent.top
        spacing: Theme.padS

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon !== ""
            text: root.icon
            color: root.accent
            font.pixelSize: Theme.fsTitle
        }

        SplitText {
            anchors.verticalCenter: parent.verticalCenter
            text: root.title.toUpperCase()
            pixelSize: Theme.fsLarge
            letterSpacing: 1.5
            split: 1.3
            splitOpacity: 0.7
        }
    }

    Text {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 6
        visible: root.subtitle !== ""
        text: root.subtitle
        color: Theme.muted
        font.family: Theme.fontMono
        font.pixelSize: Theme.fsMicro
        font.letterSpacing: 1
        renderType: Text.NativeRendering
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: 22
        height: 2
        color: Theme.alpha(root.accent, 0.8)
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 16
        height: 2
        color: Theme.accent
        transform: Matrix4x4 {
            matrix: Qt.matrix4x4(1, -1.4, 0, 2.8,
                                 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
        }
    }
}
