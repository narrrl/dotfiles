import QtQuick
import "root:/config"
import "root:/components"

// Title bar for a popout: glyph, print-shadowed heading, right-aligned status
// text, and a rule with a chopped accent tail.
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
        }
    }

    Text {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 6
        visible: root.subtitle !== ""
        text: root.subtitle
        color: Theme.subtext
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

    Skew {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 16
        height: 2
        color: Theme.accent
        lean: 1.4
    }
}
